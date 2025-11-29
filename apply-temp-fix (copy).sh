#!/bin/bash
# Temporary Audio Fix Script
# Run this after reboot to restore audio

set -e

echo "1. Restoring Topology File..."
# Force copy the working Meteor Lake topology to the Arrow Lake path
sudo cp -f /lib/firmware/intel/sof-ace-tplg/sof-mtl-rt722-l0.tplg /lib/firmware/intel/sof-ace-tplg/sof-arl-rt722-l0_rt1320-l2.tplg

echo "2. Reloading Audio Drivers..."
sudo modprobe -r snd_sof_pci_intel_mtl
sleep 2
sudo modprobe snd_sof_pci_intel_mtl
sleep 2

echo "3. Enabling Hardware Switches..."
sudo /home/bilal/claudepro/alienware/enable-sound-switches.sh

echo "4. Verifying Audio Card..."
if grep -q "sof-soundwire" /proc/asound/cards; then
    echo "SUCCESS: Audio card detected!"
    echo "You should have audio now."
else
    echo "ERROR: Audio card not detected. Check dmesg for errors."
fi
