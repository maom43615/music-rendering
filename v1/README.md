# MIDI Studio Renderer
## Converting Greasemonkey Audio Effects to Command-Line Processing

This project converts the browser-based audio effects from the "YouTube Studio FINAL" Greasemonkey script into command-line tools for rendering MIDI files with professional audio effects.

---

## 📋 What This Does

The Greasemonkey script uses **Web Audio API** to apply real-time effects in the browser:
- **GainNode** for volume boost (0-300%)
- Visual controls with sliders

These scripts replicate those effects for **offline rendering** of MIDI files:
1. ✅ Render MIDI → WAV using FluidSynth + SoundFont
2. ✅ Apply GainNode volume boost (matching the script's 0-300% range)
3. ✅ Optional professional effects (reverb, compression, EQ)
4. ✅ Export to WAV and MP3

---

## 🛠️ Installation

### Required Tools

```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install fluidsynth sox libsox-fmt-all lame bc

# macOS (using Homebrew)
brew install fluid-synth sox lame
```

**What each tool does:**
- `fluidsynth` - MIDI to WAV renderer using SoundFonts
- `sox` - Audio effects processor (replicates Web Audio API)
- `lame` - MP3 encoder
- `bc` - Calculator for gain calculations

---

## 🎵 Basic Script (Simple Volume Boost)

### `midi_studio_render.sh`

Applies **only the GainNode** effect from the Greasemonkey script.

### Usage

```bash
# Basic usage (100% volume = normal)
./midi_studio_render.sh "Loy Krathong.mid" "Jnsgm2.sf2"

# With 150% volume boost (1.5x louder)
./midi_studio_render.sh "Loy Krathong.mid" "Jnsgm2.sf2" 150

# Maximum boost (300% = 3x louder)
./midi_studio_render.sh "Loy Krathong.mid" "Jnsgm2.sf2" 300
```

### Output Files
- `temp_song.wav` - Raw FluidSynth output
- `output_with_effects.wav` - With volume boost applied
- `output_with_effects.mp3` - MP3 version (320kbps)

---

## 🎛️ Professional Script (Full Studio Effects)

### `midi_studio_render_pro.sh`

Adds professional audio processing on top of the GainNode:
- ✅ **Volume Boost** (GainNode from script)
- ✅ **Reverb** - Studio ambience
- ✅ **Compression** - Dynamic range control
- ✅ **Equalization** - Bass and treble enhancement

### Usage

```bash
# All effects enabled (default)
./midi_studio_render_pro.sh "Loy Krathong.mid" "Jnsgm2.sf2" 150

# Custom control over effects
./midi_studio_render_pro.sh "Loy Krathong.mid" "Jnsgm2.sf2" 150 yes yes yes
#                                                            │   │   │   │
#                                                        Gain │   │   └── EQ
#                                                             │   └────── Compression  
#                                                             └────────── Reverb

# Only volume boost (no other effects)
./midi_studio_render_pro.sh "Loy Krathong.mid" "Jnsgm2.sf2" 200 no no no

# Volume + reverb only
./midi_studio_render_pro.sh "Loy Krathong.mid" "Jnsgm2.sf2" 120 yes no no
```

### Output Files
- `temp_song.wav` - Raw FluidSynth output
- `output_studio_processed.wav` - With all effects applied
- `output_studio_processed.mp3` - MP3 version (320kbps)

---

## 🔬 Technical Mapping: Browser → Command Line

| Greasemonkey (Web Audio API) | Command Line (SoX) | Description |
|------------------------------|-------------------|-------------|
| `createGain()` | `sox vol X` | Volume control |
| `gainNode.gain.value = slider/100` | `vol $(echo $GAIN/100 | bc)` | Gain calculation |
| `source.connect(gainNode)` | SoX effect chain | Audio routing |
| `gainNode.connect(destination)` | Output to file | Final output |

### Example Conversion

**Greasemonkey code:**
```javascript
const gainNode = ctx.createGain();
document.getElementById('gain-slider').oninput = (e) => {
    gainNode.gain.value = e.target.value / 100;  // Slider: 0-300
};
```

**Equivalent bash:**
```bash
GAIN_VALUE=150  # Slider value
GAIN_MULTIPLIER=$(echo "scale=4; $GAIN_VALUE / 100" | bc)  # = 1.5
sox input.wav output.wav vol $GAIN_MULTIPLIER  # Apply 1.5x gain
```

---

## 📊 Volume Boost Reference

| Slider Value | Multiplier | Effect |
|-------------|-----------|--------|
| 0 | 0.0x | Silence |
| 50 | 0.5x | Half volume |
| 100 | 1.0x | **Normal (default)** |
| 150 | 1.5x | 50% louder |
| 200 | 2.0x | Double volume |
| 300 | 3.0x | Triple volume (max) |

---

## 🎯 Use Cases

### 1. Your Original Command
```bash
# Original (no effects)
fluidsynth -ni -g 2 -F temp_song.wav Jnsgm2.sf2 "Loy Krathong.mid"
```

### 2. With Greasemonkey Effects
```bash
# Apply the same volume boost as the browser script
./midi_studio_render.sh "Loy Krathong.mid" "Jnsgm2.sf2" 150
```

### 3. Professional Production
```bash
# Full studio treatment
./midi_studio_render_pro.sh "Loy Krathong.mid" "Jnsgm2.sf2" 150
```

---

## ⚙️ Advanced Customization

### Modify Effect Parameters

Edit the script variables:

```bash
# In midi_studio_render_pro.sh

FLUIDSYNTH_GAIN=2         # FluidSynth internal gain
REVERB_AMOUNT=50          # Reverb % (0-100)
COMPRESSION_RATIO=3       # Compression ratio (e.g., 3:1)
BASS_BOOST=3              # Bass boost in dB
TREBLE_BOOST=2            # Treble boost in dB
```

### Add Custom SoX Effects

In the effect chain section, you can add:

```bash
# Add echo effect
SOX_EFFECTS="$SOX_EFFECTS echo 0.8 0.88 60 0.4"

# Add flanger
SOX_EFFECTS="$SOX_EFFECTS flanger"

# Add tremolo
SOX_EFFECTS="$SOX_EFFECTS tremolo 5 40"
```

Full SoX documentation: http://sox.sourceforge.net/sox.html

---

## 🎼 Example: Processing "Loy Krathong"

```bash
# Step 1: Download a SoundFont if you don't have one
wget https://member.keymusician.com/Member/FluidR3_GM/FluidR3_GM.sf2

# Step 2: Basic rendering with 150% volume
./midi_studio_render.sh "Loy Krathong.mid" "FluidR3_GM.sf2" 150

# Step 3: Professional rendering with all effects
./midi_studio_render_pro.sh "Loy Krathong.mid" "FluidR3_GM.sf2" 150

# Output:
# ✅ output_with_effects.wav (basic)
# ✅ output_with_effects.mp3 (basic)
# ✅ output_studio_processed.wav (pro)
# ✅ output_studio_processed.mp3 (pro)
```

---

## 🔍 Troubleshooting

### "Command not found"
```bash
# Check if tools are installed
which fluidsynth sox lame

# Install missing tools
sudo apt-get install fluidsynth sox libsox-fmt-all lame bc
```

### "File not found"
```bash
# Check file paths
ls -lh "Loy Krathong.mid"
ls -lh "Jnsgm2.sf2"

# Use absolute paths if needed
./midi_studio_render.sh "/full/path/to/Loy Krathong.mid" "/full/path/to/Jnsgm2.sf2"
```

### Output too quiet/loud
```bash
# Adjust gain value
./midi_studio_render.sh "file.mid" "font.sf2" 50   # Quieter
./midi_studio_render.sh "file.mid" "font.sf2" 200  # Louder
```

### Clipping/distortion
```bash
# Reduce gain or add compression
./midi_studio_render_pro.sh "file.mid" "font.sf2" 100 yes yes yes
```

---

## 📚 Additional Resources

- **FluidSynth Manual**: http://www.fluidsynth.org/
- **SoX Documentation**: http://sox.sourceforge.net/
- **Web Audio API**: https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API
- **LAME MP3 Encoder**: https://lame.sourceforge.io/

---

## 🎤 What Makes This "Studio Quality"?

The Greasemonkey script's approach + our additions:

1. ✅ **GainNode precision** - Exact volume control (0.01 precision)
2. ✅ **High-quality SoundFont** - Your Jnsgm2.sf2 provides realistic instruments
3. ✅ **Professional effects chain** - Reverb → Compression → EQ
4. ✅ **320kbps MP3** - Maximum quality encoding
5. ✅ **No quality loss** - WAV intermediate files preserve full fidelity

---

## 📝 Summary

**Basic Script:**
- ✅ Matches Greasemonkey GainNode exactly
- ✅ Simple volume boost (0-300%)
- ✅ Fast rendering

**Pro Script:**
- ✅ Everything from basic +
- ✅ Professional audio effects
- ✅ Studio-quality output
- ✅ Customizable effect chain

Both scripts start from your original FluidSynth command and add the browser-based effects for offline rendering!
