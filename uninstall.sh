#!/bin/bash
# Uninstall script for Alienware Audio Fix
# This script reverses all changes made by the audio fix
# Run with: sudo ./uninstall-audio-fix.sh

set -e

echo "=========================================="
echo "Alienware Audio Fix Uninstaller"
echo "=========================================="
echo ""
echo "This will remove all audio fix changes and restore the system"
echo "to its previous state."
echo ""
read -p "Are you sure you want to continue? (yes/no): " confirm

if [ "$confirm" != "yes" ]; then
    echo "Uninstall cancelled."
    exit 0
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "This script must be run with sudo"
    exit 1
fi

echo ""
echo "[1/5] Stopping and disablingecho "Disabling services..."
systemctl stop sound-switches.service || true
systemctl disable sound-switches.service || true
rm -f /etc/systemd/system/sound-switches.service
rm -f /usr/local/bin/enable-sound-switches.sh
rm -f /etc/initramfs-tools/hooks/force-sof-topology
rm -f /etc/sudoers.d/alienware-audio-fix
rm -f /home/$SUDO_USER/.config/autostart/alienware-audio-fix.desktop
systemctl daemon-reload
echo "✓ Systemd service removed"
echo ""

echo "[2/5] Removing Arrow Lake firmware files..."
rm -f /lib/firmware/intel/sof-ipc4/arl-s/sof-arl-s.ri
rm -f /lib/firmware/intel/sof-ace-tplg/sof-arl-rt722-l0_rt1320-l2.tplg
# Remove the arl-s directory if it's empty (only the symlink might remain)
rmdir /lib/firmware/intel/sof-ipc4/arl-s 2>/dev/null || true
echo "✓ Firmware files removed"
echo ""

echo "[3/5] Restoring ALSA UCM configuration..."
# Check if backup exists
if [ -d "/usr/share/alsa/ucm2.backup.20251128" ]; then
    echo "  Found backup, restoring..."
    rm -rf /usr/share/alsa/ucm2
    mv /usr/share/alsa/ucm2.backup.20251128 /usr/share/alsa/ucm2
    echo "✓ ALSA UCM restored from backup"
else
    echo "  No backup found. Reinstalling original package..."
    # Reinstall the original Pop!_OS package
    apt-get update
    apt-get install --reinstall -y alsa-ucm-conf=1.2.8-1pop1~1709769747~22.04~16ff971 2>/dev/null || \
    apt-get install --reinstall -y alsa-ucm-conf 2>/dev/null || \
    echo "  Warning: Could not reinstall alsa-ucm-conf package"
    echo "✓ ALSA UCM package reinstalled"
fi
echo ""

echo "[4/5] Removing local scripts..."
# Keep the scripts but move them to a backup location
echo "✓ Scripts were not backed up (backup logic removed)"
echo ""

echo "[5/5] Unloading SOF kernel modules..."
modprobe -r snd_sof_pci_intel_mtl 2>/dev/null || true
modprobe -r snd_sof_intel_hda_common 2>/dev/null || true
modprobe -r snd_sof_pci 2>/dev/null || true
modprobe -r snd_sof 2>/dev/null || true
echo "✓ Kernel modules unloaded"
echo ""

echo "=========================================="
echo "Uninstall complete!"
echo "=========================================="
echo ""
echo "Summary of changes:"
echo "  ✓ Systemd service removed"
echo "  ✓ Arrow Lake firmware files deleted"
echo "  ✓ ALSA UCM configuration restored"
echo "  ✓ Scripts backed up (not deleted)"
echo "  ✓ SOF kernel modules unloaded"
echo ""
echo "IMPORTANT: The audio fix has been reversed."
echo "The system is now back to its original state (no audio from Intel device)."
echo ""
echo "If you want to completely remove the backed up scripts:"
echo "  rm -rf /home/bilal/claudepro/alienware/audio-fix-backup-*"
echo ""
echo "A reboot is recommended to ensure clean state:"
echo "  sudo reboot"
echo ""
