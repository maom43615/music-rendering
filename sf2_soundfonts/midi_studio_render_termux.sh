#!/data/data/com.termux/files/usr/bin/bash

# MIDI Studio Renderer - TERMUX VERSION
# Optimized for Android/Termux environment
# Usage: ./midi_studio_render_termux.sh "input.mid" "soundfont.sf2" [gain_value]

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

# FluidSynth settings
FLUIDSYNTH_GAIN=2

# Termux-specific: Auto-copy to music folder?
AUTO_COPY_TO_MUSIC="${AUTO_COPY_TO_MUSIC:-yes}"

# ================================================================================
# TERMUX ENVIRONMENT CHECK
# ================================================================================

# Detect if running in Termux
if [ -d "/data/data/com.termux" ]; then
    IS_TERMUX=true
    MUSIC_DIR="$HOME/storage/music"
    DOWNLOAD_DIR="$HOME/storage/downloads"
else
    IS_TERMUX=false
fi

# ================================================================================
# VALIDATION
# ================================================================================

if [ -z "$MIDI_FILE" ] || [ -z "$SOUNDFONT" ]; then
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎵 MIDI Studio Renderer (Termux Edition)"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Usage: $0 <midi_file> <soundfont.sf2> [gain_value]"
    echo ""
    echo "Example:"
    echo "  $0 'Loy Krathong.mid' 'Jnsgm2.sf2' 150"
    echo ""
    echo "Parameters:"
    echo "  midi_file     - Path to MIDI file"
    echo "  soundfont.sf2 - Path to SoundFont file"
    echo "  gain_value    - Volume boost 0-300 (default: 100)"
    echo "                  100 = normal, 200 = 2x, 300 = 3x"
    echo ""
    if [ "$IS_TERMUX" = true ]; then
        echo "📱 Termux Tips:"
        echo "  • Files are in: ~/storage/downloads/"
        echo "  • Output goes to: ~/storage/music/"
        echo "  • Run: termux-setup-storage (if needed)"
    fi
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    exit 1
fi

if [ ! -f "$MIDI_FILE" ]; then
    echo "❌ Error: MIDI file '$MIDI_FILE' not found!"
    if [ "$IS_TERMUX" = true ]; then
        echo ""
        echo "Try these locations:"
        echo "  ls ~/storage/downloads/*.mid"
        echo "  ls ~/midi-studio/*.mid"
        echo "  ls ~/storage/shared/Download/*.mid"
    fi
    exit 1
fi

if [ ! -f "$SOUNDFONT" ]; then
    echo "❌ Error: SoundFont file '$SOUNDFONT' not found!"
    if [ "$IS_TERMUX" = true ]; then
        echo ""
        echo "Try these locations:"
        echo "  ls ~/storage/downloads/*.sf2"
        echo "  ls ~/midi-studio/*.sf2"
    fi
    exit 1
fi

# Check for required tools
MISSING_TOOLS=()
for cmd in fluidsynth sox lame bc; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_TOOLS+=("$cmd")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    echo "❌ Error: Missing required tools: ${MISSING_TOOLS[*]}"
    echo ""
    if [ "$IS_TERMUX" = true ]; then
        echo "Install with:"
        echo "  pkg install ${MISSING_TOOLS[*]}"
    else
        echo "Install with:"
        echo "  sudo apt-get install ${MISSING_TOOLS[*]}"
    fi
    exit 1
fi

# ================================================================================
# DISPLAY SETTINGS
# ================================================================================

GAIN_MULTIPLIER=$(echo "scale=4; $GAIN_VALUE / 100" | bc)

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎵 MIDI Studio Renderer"
if [ "$IS_TERMUX" = true ]; then
    echo "📱 Running on Termux/Android"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📁 Input MIDI:    $MIDI_FILE"
echo "🎹 SoundFont:     $SOUNDFONT"
echo "🔊 Gain Boost:    ${GAIN_VALUE}% ($(echo "scale=2; $GAIN_VALUE/100" | bc)x)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# ================================================================================
# STEP 1: RENDER MIDI TO WAV
# ================================================================================

echo "Step 1/3: Rendering MIDI with FluidSynth..."

# Termux optimization: Use lower verbosity
if [ "$IS_TERMUX" = true ]; then
    fluidsynth -niq -g $FLUIDSYNTH_GAIN -F "$TEMP_WAV" "$SOUNDFONT" "$MIDI_FILE" 2>/dev/null
else
    fluidsynth -ni -g $FLUIDSYNTH_GAIN -F "$TEMP_WAV" "$SOUNDFONT" "$MIDI_FILE"
fi

if [ $? -ne 0 ]; then
    echo "❌ Error: FluidSynth rendering failed!"
    exit 1
fi

echo "✅ MIDI rendered to WAV"
echo ""

# ================================================================================
# STEP 2: APPLY AUDIO EFFECTS
# ================================================================================

echo "Step 2/3: Applying audio effects (Volume Boost)..."

# Apply gain using SoX
sox "$TEMP_WAV" "$FINAL_WAV" vol $GAIN_MULTIPLIER 2>/dev/null

if [ $? -ne 0 ]; then
    echo "❌ Error: SoX audio processing failed!"
    exit 1
fi

echo "✅ Effects applied (Gain: ${GAIN_MULTIPLIER}x)"
echo ""

# ================================================================================
# STEP 3: CONVERT TO MP3
# ================================================================================

echo "Step 3/3: Converting to MP3..."

# Convert to MP3 (suppress LAME output on Termux)
if [ "$IS_TERMUX" = true ]; then
    lame -b 320 "$FINAL_WAV" "$FINAL_MP3" 2>/dev/null
else
    lame -b 320 "$FINAL_WAV" "$FINAL_MP3"
fi

if [ $? -ne 0 ]; then
    echo "❌ Error: MP3 conversion failed!"
    exit 1
fi

echo "✅ MP3 created"
echo ""

# ================================================================================
# TERMUX: AUTO-COPY TO MUSIC FOLDER
# ================================================================================

if [ "$IS_TERMUX" = true ] && [ "$AUTO_COPY_TO_MUSIC" = "yes" ]; then
    if [ -d "$MUSIC_DIR" ]; then
        echo "📱 Copying to Music folder..."
        cp "$FINAL_MP3" "$MUSIC_DIR/" 2>/dev/null
        cp "$FINAL_WAV" "$MUSIC_DIR/" 2>/dev/null
        
        if [ $? -eq 0 ]; then
            echo "✅ Files copied to: $MUSIC_DIR/"
        else
            echo "⚠️  Could not copy to Music folder"
            echo "   Run: termux-setup-storage"
        fi
        echo ""
    fi
fi

# ================================================================================
# SUMMARY
# ================================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "🎉 RENDERING COMPLETE!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📦 Output files:"
echo "   • WAV (with effects): $FINAL_WAV"
echo "   • MP3 (320kbps):      $FINAL_MP3"

if [ "$IS_TERMUX" = true ] && [ -d "$MUSIC_DIR" ]; then
    echo ""
    echo "📱 Also available in:"
    echo "   • $MUSIC_DIR/"
    echo ""
    echo "🎵 Play with:"
    echo "   termux-media-player play $MUSIC_DIR/$FINAL_MP3"
    echo "   termux-share $FINAL_MP3"
fi

echo ""
echo "🎛️ Effect settings:"
echo "   • FluidSynth Gain:    ${FLUIDSYNTH_GAIN}"
echo "   • Volume Boost:       ${GAIN_VALUE}% (${GAIN_MULTIPLIER}x)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# ================================================================================
# TERMUX: SEND NOTIFICATION
# ================================================================================

if [ "$IS_TERMUX" = true ] && command -v termux-notification &> /dev/null; then
    termux-notification \
        --title "🎵 MIDI Render Complete" \
        --content "File: $FINAL_MP3" \
        --action "termux-media-player play $PWD/$FINAL_MP3" 2>/dev/null
fi
