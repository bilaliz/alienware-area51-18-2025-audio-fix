#!/bin/bash
# Quick fix script to reload audio after boot if needed
# Run this if audio is not working after reboot

set -e

echo "Reloading SOF audio drivers..."
sudo modprobe -r snd_sof_pci_intel_mtl
sleep 2
sudo modprobe snd_sof_pci_intel_mtl
sleep 3

echo "Enabling hardware switches..."
sudo /usr/local/bin/enable-sound-switches.sh



echo ""
echo "Audio card should now be available:"
cat /proc/asound/cards

echo ""
echo "Testing audio..."
pw-cat --playback /usr/share/sounds/freedesktop/stereo/bell.oga && echo "✓ Audio test successful!"
