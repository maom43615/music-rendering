#!/bin/bash

# MIDI PROFESSIONAL STUDIO RENDERER
# Advanced version with multiple audio effects
# Based on YouTube Studio Greasemonkey script concept

# ================================================================================
# CONFIGURATION
# ================================================================================

MIDI_FILE="$1"
SOUNDFONT="$2"
GAIN_VALUE="${3:-100}"        # Volume boost (0-300)
ENABLE_REVERB="${4:-yes}"     # Add reverb effect
ENABLE_COMPRESS="${5:-yes}"   # Add compression
ENABLE_EQ="${6:-yes}"         # Add equalization

# Output files
TEMP_WAV="temp_song.wav"
PROCESSED_WAV="output_studio_processed.wav"
FINAL_MP3="output_studio_processed.mp3"

# FluidSynth settings
FLUIDSYNTH_GAIN=2

# Effect parameters
REVERB_AMOUNT=50              # Reverb percentage
COMPRESSION_RATIO=3           # Compression ratio
BASS_BOOST=3                  # Bass boost in dB
TREBLE_BOOST=2                # Treble boost in dB

# ================================================================================
# VALIDATION
# ================================================================================

if [ -z "$MIDI_FILE" ] || [ -z "$SOUNDFONT" ]; then
    cat << EOF
🎛️  MIDI PROFESSIONAL STUDIO RENDERER

Usage: $0 <midi_file> <soundfont.sf2> [gain] [reverb] [compress] [eq]

Example: $0 'Loy Krathong.mid' 'Jnsgm2.sf2' 150 yes yes yes

Parameters:
  midi_file      - Path to MIDI file
  soundfont.sf2  - Path to SoundFont file
  gain           - Volume boost 0-300 (default: 100)
  reverb         - Add reverb: yes/no (default: yes)
  compress       - Add compression: yes/no (default: yes)
  eq             - Add equalization: yes/no (default: yes)

Effects applied:
  ✓ GainNode (Volume Boost) - from Greasemonkey script
  ✓ Reverb - Professional studio ambience
  ✓ Compression - Dynamic range control
  ✓ EQ - Bass and treble enhancement

EOF
    exit 1
fi

if [ ! -f "$MIDI_FILE" ]; then
    echo "❌ Error: MIDI file '$MIDI_FILE' not found!"
    exit 1
fi

if [ ! -f "$SOUNDFONT" ]; then
    echo "❌ Error: SoundFont file '$SOUNDFONT' not found!"
    exit 1
fi

# Check for required tools
for cmd in fluidsynth sox lame bc; do
    if ! command -v $cmd &> /dev/null; then
        echo "❌ Error: $cmd is not installed!"
        echo "Install with: sudo apt-get install fluidsynth sox libsox-fmt-all lame bc"
        exit 1
    fi
done

# ================================================================================
# DISPLAY SETTINGS
# ================================================================================

GAIN_MULTIPLIER=$(echo "scale=4; $GAIN_VALUE / 100" | bc)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎵  MIDI PROFESSIONAL STUDIO RENDERER"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Input MIDI:      $MIDI_FILE"
echo "🎹 SoundFont:       $SOUNDFONT"
echo ""
echo "🎛️  Effect Chain:"
echo "   1. FluidSynth    Gain: ${FLUIDSYNTH_GAIN}"
echo "   2. Volume Boost  ${GAIN_VALUE}% (${GAIN_MULTIPLIER}x) [Greasemonkey GainNode]"
echo "   3. Reverb        $([ "$ENABLE_REVERB" = "yes" ] && echo "✅ ON ($REVERB_AMOUNT%)" || echo "⏸️  OFF")"
echo "   4. Compression   $([ "$ENABLE_COMPRESS" = "yes" ] && echo "✅ ON (${COMPRESSION_RATIO}:1)" || echo "⏸️  OFF")"
echo "   5. Equalization  $([ "$ENABLE_EQ" = "yes" ] && echo "✅ ON (Bass+${BASS_BOOST}dB, Treble+${TREBLE_BOOST}dB)" || echo "⏸️  OFF")"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ================================================================================
# STEP 1: RENDER MIDI TO WAV
# ================================================================================

echo "▶️  Step 1/4: Rendering MIDI with FluidSynth..."
fluidsynth -ni -g $FLUIDSYNTH_GAIN -F "$TEMP_WAV" "$SOUNDFONT" "$MIDI_FILE"

if [ $? -ne 0 ]; then
    echo "❌ Error: FluidSynth rendering failed!"
    exit 1
fi

echo "   ✅ MIDI rendered to WAV"
echo ""

# ================================================================================
# STEP 2: BUILD SOX EFFECT CHAIN
# ================================================================================

echo "▶️  Step 2/4: Building audio effect chain..."

# Start building SoX command
SOX_EFFECTS=""

# Effect 1: Volume Boost (GainNode from Greasemonkey)
SOX_EFFECTS="$SOX_EFFECTS vol $GAIN_MULTIPLIER"
echo "   ✅ Volume Boost added (${GAIN_MULTIPLIER}x)"

# Effect 2: Reverb
if [ "$ENABLE_REVERB" = "yes" ]; then
    SOX_EFFECTS="$SOX_EFFECTS reverb $REVERB_AMOUNT"
    echo "   ✅ Reverb added ($REVERB_AMOUNT%)"
fi

# Effect 3: Compression
if [ "$ENABLE_COMPRESS" = "yes" ]; then
    SOX_EFFECTS="$SOX_EFFECTS compand 0.3,1 6:-70,-60,-20 -5 -90 0.2"
    echo "   ✅ Compression added"
fi

# Effect 4: Equalization
if [ "$ENABLE_EQ" = "yes" ]; then
    SOX_EFFECTS="$SOX_EFFECTS bass $BASS_BOOST treble $TREBLE_BOOST"
    echo "   ✅ Equalization added (Bass+${BASS_BOOST}dB, Treble+${TREBLE_BOOST}dB)"
fi

echo ""

# ================================================================================
# STEP 3: APPLY EFFECTS
# ================================================================================

echo "▶️  Step 3/4: Applying effect chain..."

# Apply all effects
sox "$TEMP_WAV" "$PROCESSED_WAV" $SOX_EFFECTS

if [ $? -ne 0 ]; then
    echo "❌ Error: SoX audio processing failed!"
    exit 1
fi

echo "   ✅ All effects applied successfully"
echo ""

# ================================================================================
# STEP 4: CONVERT TO MP3
# ================================================================================

echo "▶️  Step 4/4: Converting to MP3 (320kbps)..."

lame -b 320 "$PROCESSED_WAV" "$FINAL_MP3"

if [ $? -ne 0 ]; then
    echo "❌ Error: MP3 conversion failed!"
    exit 1
fi

echo "   ✅ MP3 created"
echo ""

# ================================================================================
# FINAL SUMMARY
# ================================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉  RENDERING COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "📦  Output files:"
echo "    • WAV (raw):           $TEMP_WAV"
echo "    • WAV (with effects):  $PROCESSED_WAV"
echo "    • MP3 (320kbps):       $FINAL_MP3"
echo ""
echo "🎛️  Applied effects:"
echo "    • FluidSynth Gain:     $FLUIDSYNTH_GAIN"
echo "    • Volume Boost:        ${GAIN_VALUE}% (${GAIN_MULTIPLIER}x)"
[ "$ENABLE_REVERB" = "yes" ] && echo "    • Reverb:              $REVERB_AMOUNT%"
[ "$ENABLE_COMPRESS" = "yes" ] && echo "    • Compression:         ${COMPRESSION_RATIO}:1 ratio"
[ "$ENABLE_EQ" = "yes" ] && echo "    • EQ:                  Bass+${BASS_BOOST}dB, Treble+${TREBLE_BOOST}dB"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
