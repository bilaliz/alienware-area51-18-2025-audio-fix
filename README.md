# Alienware Audio Fix (Arrow Lake / RT722 / RT1320)

This repository contains a fix for audio issues on Alienware laptops (and potentially others) with **Intel Arrow Lake** processors and **Realtek RT722 + RT1320** audio codecs running Linux (Pop!_OS 22.04 / Ubuntu 22.04/24.04).

## The Problem
- No audio output from speakers
- "Dummy Output" or missing sound card
- Missing firmware for Arrow Lake (`sof-arl-s.ri`)
- Buggy official topology causing "Speaker Switch already present" error
- Missing ALSA UCM configuration for RT1320 amplifier

## The Solution
This fix installs:
1.  **Intel SOF Firmware v2.13** (Arrow Lake)
2.  **Topology Workaround**: Uses Meteor Lake topology to bypass the duplicate control bug
3.  **Custom ALSA UCM**: Adds support for RT1320 amplifier and RT722 codec
4.  **Hardware Switch Service**: Automatically enables amplifier switches on boot
5.  **Persistence**:
    - **Initramfs Hook**: Forces correct topology at boot
    - **Autostart Script**: Automatically restores audio on login (fallback)

## Installation

1.  Clone this repository:
    ```bash
    git clone https://github.com/YOUR_USERNAME/alienware-audio-fix.git
    cd alienware-audio-fix
    ```

2.  Run the installer:
    ```bash
    sudo ./install.sh
    ```

3.  **Reboot** your system.

## Manual Reload
If audio stops working after a reboot or update, you can run:
```bash
sudo ./reload-audio.sh
```

## Temporary Fix (Fallback)
If the permanent fix fails (e.g., after a kernel update breaks initramfs), you can use the temporary fix script to restore audio immediately:
```bash
sudo ./apply-temp-fix.sh
```

## Verified On
- **Hardware**: Alienware m16/m18 R2 (Intel Core Ultra / Arrow Lake)
- **OS**: Pop!_OS 22.04 LTS (Kernel 6.17+)

## Credits
- SOF Project for firmware
- ALSA Project for UCM configs
- Community for topology workarounds
