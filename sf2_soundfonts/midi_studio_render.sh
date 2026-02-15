#!/bin/bash

# MIDI Studio Renderer
# Applies SoundFont + Audio Effects (Gain/Volume Boost) like the Greasemonkey YouTube Studio script
# Usage: ./midi_studio_render.sh "input.mid" "soundfont.sf2" [gain_value]

# ================================================================================
# CONFIGURATION
# ================================================================================

MIDI_FILE="$1"
SOUNDFONT="$2"
GAIN_VALUE="${3:-100}"  # Default 100% (range: 0-300 like the script)

# Output files
TEMP_WAV="temp_song.wav"
FINAL_WAV="output_with_effects.wav"
FINAL_MP3="output_with_effects.mp3"

# FluidSynth settings (matching your command)
FLUIDSYNTH_GAIN=2

# ================================================================================
# VALIDATION
# ================================================================================

if [ -z "$MIDI_FILE" ] || [ -z "$SOUNDFONT" ]; then
    echo "Usage: $0 <midi_file> <soundfont.sf2> [gain_value]"
    echo ""
    echo "Example: $0 'Loy Krathong.mid' 'Jnsgm2.sf2' 150"
    echo ""
    echo "Parameters:"
    echo "  midi_file     - Path to MIDI file"
    echo "  soundfont.sf2 - Path to SoundFont file"
    echo "  gain_value    - Volume boost 0-300 (default: 100)"
    echo "                  100 = normal, 200 = 2x louder, 300 = 3x louder"
    exit 1
fi

if [ ! -f "$MIDI_FILE" ]; then
    echo "Error: MIDI file '$MIDI_FILE' not found!"
    exit 1
fi

if [ ! -f "$SOUNDFONT" ]; then
    echo "Error: SoundFont file '$SOUNDFONT' not found!"
    exit 1
fi

# Check for required tools
for cmd in fluidsynth sox lame; do
    if ! command -v $cmd &> /dev/null; then
        echo "Error: $cmd is not installed!"
        echo "Install with: sudo apt-get install fluidsynth sox lame"
        exit 1
    fi
done

# ================================================================================
# STEP 1: RENDER MIDI TO WAV WITH FLUIDSYNTH
# ================================================================================

echo "🎵 MIDI STUDIO RENDERER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Input MIDI:    $MIDI_FILE"
echo "🎹 SoundFont:     $SOUNDFONT"
echo "🔊 Gain Boost:    ${GAIN_VALUE}% ($(echo "scale=2; $GAIN_VALUE/100" | bc)x)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo "Step 1/3: Rendering MIDI with FluidSynth..."
fluidsynth -ni -g $FLUIDSYNTH_GAIN -F "$TEMP_WAV" "$SOUNDFONT" "$MIDI_FILE"

if [ $? -ne 0 ]; then
    echo "Error: FluidSynth rendering failed!"
    exit 1
fi

echo "✅ MIDI rendered to WAV"
echo ""

# ================================================================================
# STEP 2: APPLY AUDIO EFFECTS (GAIN NODE FROM GREASEMONKEY)
# ================================================================================

echo "Step 2/3: Applying audio effects (Volume Boost)..."

# Calculate gain multiplier (matching the Greasemonkey gain node)
# The script uses: gainNode.gain.value = slider_value / 100
GAIN_MULTIPLIER=$(echo "scale=4; $GAIN_VALUE / 100" | bc)

# Apply gain using SoX (equivalent to Web Audio API GainNode)
sox "$TEMP_WAV" "$FINAL_WAV" vol $GAIN_MULTIPLIER

if [ $? -ne 0 ]; then
    echo "Error: SoX audio processing failed!"
    exit 1
fi

echo "✅ Effects applied (Gain: ${GAIN_MULTIPLIER}x)"
echo ""

# ================================================================================
# STEP 3: CONVERT TO MP3
# ================================================================================

echo "Step 3/3: Converting to MP3..."

# Convert to high-quality MP3 (320kbps CBR)
lame -b 320 "$FINAL_WAV" "$FINAL_MP3"

if [ $? -ne 0 ]; then
    echo "Error: MP3 conversion failed!"
    exit 1
fi

echo "✅ MP3 created"
echo ""

# ================================================================================
# CLEANUP & SUMMARY
# ================================================================================

# Optional: Remove temporary file
# rm -f "$TEMP_WAV"

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 RENDERING COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Output files:"
echo "   • WAV (with effects): $FINAL_WAV"
echo "   • MP3 (320kbps):      $FINAL_MP3"
echo ""
echo "🎛️ Effect settings:"
echo "   • FluidSynth Gain:    ${FLUIDSYNTH_GAIN}"
echo "   • Volume Boost:       ${GAIN_VALUE}% (${GAIN_MULTIPLIER}x)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
