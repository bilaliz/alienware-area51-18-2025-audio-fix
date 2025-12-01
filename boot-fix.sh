#!/bin/bash
# Alienware Audio Fix - Boot Script
# Ensures correct topology and reloads driver if needed

set -e

# 0. Check if audio is already working
if grep -q "sof-soundwire" /proc/asound/cards; then
    echo "Audio card already detected. Skipping fix."
    exit 0
fi

# 1. Ensure correct topology is in place
# We copy the MTL topology (which works) to the ARL path
if [ -f "/lib/firmware/intel/sof-ace-tplg/sof-mtl-rt722-l0.tplg" ]; then
    cp -f /lib/firmware/intel/sof-ace-tplg/sof-mtl-rt722-l0.tplg /lib/firmware/intel/sof-ace-tplg/sof-arl-rt722-l0_rt1320-l2.tplg
else
    echo "Error: Source topology not found!"
    exit 1
fi

# 2. Reload Audio Drivers
# We only reload if the card is NOT detected or if we want to force it
# But to be safe and ensure the new topology is picked up, we force reload
modprobe -r snd_sof_pci_intel_mtl || true
sleep 2
modprobe snd_sof_pci_intel_mtl

# 3. Enable Hardware Switches
/usr/local/bin/enable-sound-switches.sh

echo "Audio fix applied successfully."
