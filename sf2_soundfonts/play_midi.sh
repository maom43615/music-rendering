#!/data/data/com.termux/files/usr/bin/bash

# Configuration
SF2_PATH="Jnsgm2.sf2"
DRIVER="pulseaudio"

if [ -z "$1" ]; then
    echo "Usage: bash play_midi.sh <midi_file>"
    exit 1
fi

if [ ! -f "$SF2_PATH" ]; then
    echo "Error: SoundFont $SF2_PATH not found!"
    exit 1
fi

echo "Playing $1 using $SF2_PATH..."
fluidsynth -a $DRIVER -i -g 1.5 "$SF2_PATH" "$1"

