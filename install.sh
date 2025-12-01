#!/bin/bash
# Alienware Audio Fix Installer
# For Intel Arrow Lake + RT722 + RT1320 (Pop!_OS 22.04 / Ubuntu 24.04)

set -e

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (sudo ./install.sh)"
    exit 1
fi

echo "==============================================="
echo "Alienware Audio Fix Installer"
echo "==============================================="

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# 1. Install Dependencies
echo "[1/6] Installing dependencies..."
apt-get update || true
apt-get install -y git alsa-utils pulseaudio-utils

# 2. Install Firmware (Arrow Lake)
echo "[2/6] Installing Intel SOF Firmware..."
# We use the official v2.13 firmware but with MTL topology workaround
mkdir -p /lib/firmware/intel/sof-ipc4/arl-s
mkdir -p /lib/firmware/intel/sof-ace-tplg

# Download firmware if not present (using curl/wget would be better but for now we assume internet)
# Actually, let's just clone the specific needed files or download them
# For this package, we will assume the user might want to download them fresh
# But to make this script standalone, we should probably include them or download them.
# Let's download them to be safe.

echo "  Downloading firmware..."
wget -q -O /lib/firmware/intel/sof-ipc4/arl-s/sof-arl-s.ri https://github.com/thesofproject/sof-bin/raw/main/v2.13.x/sof-ipc4-v2.13/arl-s/intel-signed/sof-arl-s.ri
# TOPOLOGY WORKAROUND: Use MTL topology for ARL
echo "  Applying Topology Workaround (using MTL topology)..."
wget -q -O /lib/firmware/intel/sof-ace-tplg/sof-arl-rt722-l0_rt1320-l2.tplg https://github.com/thesofproject/sof-bin/raw/main/v2.13.x/sof-ipc4-tplg-v2.13/sof-mtl-rt722-l0.tplg

# 3. Install ALSA UCM Configuration
echo "[3/6] Installing ALSA UCM Configuration..."
# We need the base UCM files first. If they are old (1.2.8), we should update them.
# But for now, let's just patch the specific files we need.
# Ideally we should install the full UCM 1.2.12 package, but let's just copy our fixes.
# If the directory doesn't exist, we might need to fetch the whole repo.
if [ ! -d "/usr/share/alsa/ucm2/sof-soundwire" ]; then
    echo "  Downloading full UCM package..."
    git clone -b v1.2.12 --depth 1 https://github.com/alsa-project/alsa-ucm-conf.git /tmp/alsa-ucm-conf
    cp -r /tmp/alsa-ucm-conf/ucm2/* /usr/share/alsa/ucm2/
    rm -rf /tmp/alsa-ucm-conf
fi

echo "  Applying custom UCM fixes..."
cp "$SCRIPT_DIR/ucm/sof-soundwire/rt722.conf" /usr/share/alsa/ucm2/sof-soundwire/
cp "$SCRIPT_DIR/ucm/sof-soundwire/rt1320.conf" /usr/share/alsa/ucm2/sof-soundwire/
cp "$SCRIPT_DIR/ucm/sof-soundwire/mic_fallback.conf" /usr/share/alsa/ucm2/sof-soundwire/
cp "$SCRIPT_DIR/ucm/sof-soundwire/sof-soundwire.conf" /usr/share/alsa/ucm2/sof-soundwire/

# 4. Install Hardware Switch Service
echo "[4/6] Installing Hardware Switch Service..."
cp "$SCRIPT_DIR/enable-sound-switches.sh" /usr/local/bin/
chmod +x /usr/local/bin/enable-sound-switches.sh
cp "$SCRIPT_DIR/sound-switches.service" /etc/systemd/system/

# 5. Install Initramfs Hook & Modprobe Config (Proper Permanent Fix)
echo "[5/6] Installing Initramfs Hook & Modprobe Config..."
cp "$SCRIPT_DIR/force-sof-topology" /etc/initramfs-tools/hooks/
chmod +x /etc/initramfs-tools/hooks/force-sof-topology
cp "$SCRIPT_DIR/sof-custom.conf" /etc/modprobe.d/


# 6. Install Autostart Fix (User Login Fix)
echo "[6/6] Installing Autostart Fix..."
echo "$SUDO_USER ALL=(ALL) NOPASSWD: /usr/local/bin/alienware-audio-boot-fix.sh" > /etc/sudoers.d/alienware-audio-fix
chmod 0440 /etc/sudoers.d/alienware-audio-fix

# Install for the current user
mkdir -p /home/$SUDO_USER/.config/autostart
cp "$SCRIPT_DIR/alienware-audio-fix.desktop" /home/$SUDO_USER/.config/autostart/
chown $SUDO_USER:$SUDO_USER /home/$SUDO_USER/.config/autostart/alienware-audio-fix.desktop

# 7. Persistence (Initramfs)
echo "[7/7] Updating initramfs..."
update-initramfs -u

# 6. Reload Audio
echo "[6/6] Reloading Audio Drivers..."
modprobe -r snd_sof_pci_intel_mtl || true
sleep 2
modprobe snd_sof_pci_intel_mtl || true

echo "==============================================="
echo "Installation Complete!"
echo "Please reboot your system to ensure everything loads correctly."
echo "==============================================="
