#!/bin/bash
# Enable hardware switches for Alienware Area 51 audio
# RT722 (headphone jack) and RT1320 (speaker amplifier) codecs

# Wait for sound system to initialize
sleep 2

# Enable speaker and amplifier switches
# Card 1 should be the Intel SOF soundwire device
amixer -c 1 sset 'Speaker' on 2>/dev/null
amixer -c 1 sset 'rt1320-1 FU' cap 2>/dev/null
amixer -c 1 sset 'rt1320-1 OT23 L' on 2>/dev/null
amixer -c 1 sset 'rt1320-1 OT23 R' on 2>/dev/null

echo "Sound switches enabled successfully"
