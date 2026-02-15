#!/bin/bash

# MIDI TO YOUTUBE VIDEO GENERATOR
# Combines FluidSynth audio rendering + Greasemonkey effects + Piano Roll Visualization
# Creates professional videos suitable for YouTube upload (unlimited length)
#
# Usage: ./midi_to_youtube_video.sh "input.mid" "soundfont.sf2" [gain_value] [options]

# ================================================================================
# CONFIGURATION
# ================================================================================

MIDI_FILE="$1"
SOUNDFONT="$2"
GAIN_VALUE="${3:-150}"          # Volume boost (Greasemonkey effect)
VIDEO_TOOL="${4:-midi2video}"   # Options: midi2video, MIDIVisualizer, midani

# Output files
TEMP_AUDIO_WAV="temp_audio.wav"
FINAL_AUDIO_WAV="audio_with_effects.wav"
FINAL_AUDIO_MP3="audio_with_effects.mp3"
FINAL_VIDEO="youtube_output.mp4"

# FluidSynth settings
FLUIDSYNTH_GAIN=2

# Video settings
VIDEO_WIDTH=1920
VIDEO_HEIGHT=1080
VIDEO_FPS=30
VIDEO_BITRATE=8000  # 8Mbps for high quality

# Visualization tool paths (will be auto-detected)
MIDI2VIDEO_SCRIPT=""
MIDIVISUALIZER_BIN=""

# ================================================================================
# COLORS FOR OUTPUT
# ================================================================================

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ================================================================================
# HELPER FUNCTIONS
# ================================================================================

print_header() {
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${CYAN}🎬 MIDI TO YOUTUBE VIDEO GENERATOR${NC}"
    echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

print_step() {
    echo -e "${BLUE}▶️  $1${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}ℹ️  $1${NC}"
}

# ================================================================================
# DETECT VISUALIZATION TOOLS
# ================================================================================

detect_tools() {
    print_step "Detecting visualization tools..."
    
    # Check for midi2video (Python script)
    if [ -f "midi2video.py" ]; then
        MIDI2VIDEO_SCRIPT="./midi2video.py"
        print_info "Found: midi2video.py (Python)"
    elif command -v midi2video &> /dev/null; then
        MIDI2VIDEO_SCRIPT="midi2video"
        print_info "Found: midi2video (installed)"
    fi
    
    # Check for MIDIVisualizer (C++ binary)
    if command -v MIDIVisualizer &> /dev/null; then
        MIDIVISUALIZER_BIN="MIDIVisualizer"
        print_info "Found: MIDIVisualizer (installed)"
    elif [ -f "./MIDIVisualizer" ]; then
        MIDIVISUALIZER_BIN="./MIDIVisualizer"
        print_info "Found: MIDIVisualizer (local)"
    fi
    
    # Recommend tools if none found
    if [ -z "$MIDI2VIDEO_SCRIPT" ] && [ -z "$MIDIVISUALIZER_BIN" ]; then
        print_error "No visualization tools found!"
        echo ""
        echo "Please install one of these:"
        echo ""
        echo "Option 1: midi2video (Python - Easy setup)"
        echo "  git clone https://github.com/ablomer/midi2video"
        echo "  cd midi2video"
        echo "  pip install -r requirements.txt"
        echo ""
        echo "Option 2: MIDIVisualizer (C++ - High performance)"
        echo "  Download from: https://github.com/kosua20/MIDIVisualizer/releases"
        echo ""
        exit 1
    fi
    
    echo ""
}

# ================================================================================
# VALIDATION
# ================================================================================

if [ -z "$MIDI_FILE" ] || [ -z "$SOUNDFONT" ]; then
    print_header
    echo ""
    echo "Usage: $0 <midi_file> <soundfont.sf2> [gain] [tool]"
    echo ""
    echo "Examples:"
    echo "  $0 'song.mid' 'font.sf2' 150"
    echo "  $0 'song.mid' 'font.sf2' 150 midi2video"
    echo "  $0 'song.mid' 'font.sf2' 200 MIDIVisualizer"
    echo ""
    echo "Parameters:"
    echo "  midi_file     - Path to MIDI file"
    echo "  soundfont.sf2 - Path to SoundFont file"
    echo "  gain          - Volume boost 0-300 (default: 150)"
    echo "  tool          - Visualization tool (midi2video|MIDIVisualizer|midani)"
    echo ""
    echo "Output:"
    echo "  • Professional piano roll video"
    echo "  • High-quality audio with Greasemonkey effects"
    echo "  • Ready for YouTube upload (unlimited length)"
    echo "  • MP4 format, H.264 codec, 1920x1080"
    echo ""
    exit 1
fi

if [ ! -f "$MIDI_FILE" ]; then
    print_error "MIDI file not found: $MIDI_FILE"
    exit 1
fi

if [ ! -f "$SOUNDFONT" ]; then
    print_error "SoundFont file not found: $SOUNDFONT"
    exit 1
fi

# Check required tools
MISSING_TOOLS=()
for cmd in fluidsynth sox ffmpeg bc; do
    if ! command -v $cmd &> /dev/null; then
        MISSING_TOOLS+=("$cmd")
    fi
done

if [ ${#MISSING_TOOLS[@]} -gt 0 ]; then
    print_error "Missing required tools: ${MISSING_TOOLS[*]}"
    echo ""
    echo "Install with:"
    echo "  Ubuntu/Debian: sudo apt-get install ${MISSING_TOOLS[*]}"
    echo "  macOS:         brew install ${MISSING_TOOLS[*]}"
    echo "  Termux:        pkg install ${MISSING_TOOLS[*]}"
    exit 1
fi

# ================================================================================
# MAIN EXECUTION
# ================================================================================

print_header
echo ""
echo "📁 Input MIDI:     $MIDI_FILE"
echo "🎹 SoundFont:      $SOUNDFONT"
echo "🔊 Gain Boost:     ${GAIN_VALUE}% ($(echo "scale=2; $GAIN_VALUE/100" | bc)x)"
echo "📺 Output Format:  ${VIDEO_WIDTH}x${VIDEO_HEIGHT} @ ${VIDEO_FPS}fps"
echo "🎥 Video Tool:     $VIDEO_TOOL"
echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

detect_tools

# ================================================================================
# STEP 1: RENDER AUDIO WITH FLUIDSYNTH
# ================================================================================

print_step "Step 1/4: Rendering MIDI to audio with FluidSynth..."

fluidsynth -ni -g $FLUIDSYNTH_GAIN -F "$TEMP_AUDIO_WAV" "$SOUNDFONT" "$MIDI_FILE" 2>/dev/null

if [ $? -ne 0 ]; then
    print_error "FluidSynth rendering failed!"
    exit 1
fi

print_success "Audio rendered with SoundFont"
echo ""

# ================================================================================
# STEP 2: APPLY GREASEMONKEY AUDIO EFFECTS
# ================================================================================

print_step "Step 2/4: Applying Greasemonkey audio effects (GainNode)..."

GAIN_MULTIPLIER=$(echo "scale=4; $GAIN_VALUE / 100" | bc)

sox "$TEMP_AUDIO_WAV" "$FINAL_AUDIO_WAV" vol $GAIN_MULTIPLIER 2>/dev/null

if [ $? -ne 0 ]; then
    print_error "Audio effects failed!"
    exit 1
fi

print_success "Volume boost applied (${GAIN_MULTIPLIER}x)"
echo ""

# ================================================================================
# STEP 3: GENERATE VIDEO VISUALIZATION
# ================================================================================

print_step "Step 3/4: Generating piano roll visualization..."

# Choose visualization tool
case "$VIDEO_TOOL" in
    midi2video)
        if [ -n "$MIDI2VIDEO_SCRIPT" ]; then
            print_info "Using midi2video (Python)"
            python3 "$MIDI2VIDEO_SCRIPT" "$MIDI_FILE" \
                -o "temp_video_silent.mp4" \
                --width $VIDEO_WIDTH \
                --height $VIDEO_HEIGHT \
                --fps $VIDEO_FPS \
                --no-audio \
                --guide-lines \
                --color-mode note
            
            if [ $? -ne 0 ]; then
                print_error "midi2video failed!"
                exit 1
            fi
        else
            print_error "midi2video not found!"
            exit 1
        fi
        ;;
        
    MIDIVisualizer)
        if [ -n "$MIDIVISUALIZER_BIN" ]; then
            print_info "Using MIDIVisualizer (C++)"
            $MIDIVISUALIZER_BIN \
                --midi "$MIDI_FILE" \
                --size $VIDEO_WIDTH $VIDEO_HEIGHT \
                --export "temp_video_silent.mp4" \
                --format MPEG4 \
                --framerate $VIDEO_FPS \
                --bitrate $VIDEO_BITRATE \
                --hide-window 1
            
            if [ $? -ne 0 ]; then
                print_error "MIDIVisualizer failed!"
                exit 1
            fi
        else
            print_error "MIDIVisualizer not found!"
            exit 1
        fi
        ;;
        
    *)
        print_error "Unknown visualization tool: $VIDEO_TOOL"
        print_info "Available tools: midi2video, MIDIVisualizer"
        exit 1
        ;;
esac

print_success "Video visualization generated"
echo ""

# ================================================================================
# STEP 4: COMBINE VIDEO + AUDIO
# ================================================================================

print_step "Step 4/4: Combining video with enhanced audio..."

ffmpeg -i "temp_video_silent.mp4" \
       -i "$FINAL_AUDIO_WAV" \
       -c:v copy \
       -c:a aac \
       -b:a 320k \
       -shortest \
       -y \
       "$FINAL_VIDEO" 2>/dev/null

if [ $? -ne 0 ]; then
    print_error "FFmpeg combination failed!"
    exit 1
fi

print_success "Final video created"
echo ""

# ================================================================================
# CLEANUP
# ================================================================================

print_step "Cleaning up temporary files..."

rm -f "$TEMP_AUDIO_WAV" "temp_video_silent.mp4"

print_success "Cleanup complete"
echo ""

# ================================================================================
# GET VIDEO INFO
# ================================================================================

DURATION=$(ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 "$FINAL_VIDEO" 2>/dev/null)
FILESIZE=$(du -h "$FINAL_VIDEO" | cut -f1)

# ================================================================================
# FINAL SUMMARY
# ================================================================================

echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}🎉 VIDEO GENERATION COMPLETE!${NC}"
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "📦 Output file:"
echo "   $FINAL_VIDEO"
echo ""
echo "📊 Video details:"
echo "   • Resolution:  ${VIDEO_WIDTH}x${VIDEO_HEIGHT}"
echo "   • Frame rate:  ${VIDEO_FPS} fps"
echo "   • Duration:    $(printf '%.1f' $DURATION) seconds"
echo "   • File size:   $FILESIZE"
echo "   • Codec:       H.264 (MP4)"
echo "   • Audio:       AAC 320kbps"
echo ""
echo "🎛️ Audio effects applied:"
echo "   • FluidSynth Gain:    $FLUIDSYNTH_GAIN"
echo "   • Greasemonkey Gain:  ${GAIN_VALUE}% (${GAIN_MULTIPLIER}x)"
echo "   • Total Boost:        $(echo "scale=2; $FLUIDSYNTH_GAIN * $GAIN_MULTIPLIER" | bc)x"
echo ""
echo "📤 YouTube ready:"
echo "   ✅ Unlimited length supported"
echo "   ✅ High quality 1080p"
echo "   ✅ Professional visualization"
echo "   ✅ Studio audio effects"
echo ""
echo -e "${PURPLE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
