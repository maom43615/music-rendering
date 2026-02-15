# MIDI Studio Renderer - Termux Installation Guide

Complete guide for installing and running the MIDI Studio Renderer on Android using Termux.

---

## 📱 Step 1: Install Termux

1. **Download Termux** from F-Droid (recommended) or GitHub:
   - F-Droid: https://f-droid.org/en/packages/com.termux/
   - GitHub: https://github.com/termux/termux-app/releases

   ⚠️ **Do NOT use Google Play Store version** (it's outdated and broken)

2. Open Termux and update packages:
```bash
pkg update && pkg upgrade
```

---

## 🛠️ Step 2: Install Required Packages

```bash
# Install all required tools for MIDI rendering
pkg install fluidsynth sox lame bc termux-tools

# Verify installations
which fluidsynth sox lame bc
```

### Package Details

| Package | Purpose | Termux Status |
|---------|---------|---------------|
| `fluidsynth` | MIDI → WAV renderer | ✅ Available |
| `sox` | Audio effects processor | ✅ Available |
| `lame` | MP3 encoder | ✅ Available |
| `bc` | Calculator for gain | ✅ Available |
| `termux-tools` | Termux utilities | ✅ Pre-installed |

---

## 📂 Step 3: Setup Working Directory

```bash
# Create a directory for your MIDI projects
mkdir -p ~/midi-studio
cd ~/midi-studio

# Grant storage permissions (to access your files)
termux-setup-storage

# This creates ~/storage/shared which links to your phone's storage
```

---

## 📥 Step 4: Transfer Files to Termux

### Option A: Using Termux Storage Access

```bash
# After running termux-setup-storage, your phone storage is at:
# ~/storage/shared (same as /sdcard)

# Copy MIDI and SoundFont files
cp ~/storage/downloads/"Loy Krathong.mid" ~/midi-studio/
cp ~/storage/downloads/Jnsgm2.sf2 ~/midi-studio/

# Copy the scripts
cp ~/storage/downloads/midi_studio_render.sh ~/midi-studio/
cp ~/storage/downloads/midi_studio_render_pro.sh ~/midi-studio/

# Make scripts executable
chmod +x ~/midi-studio/*.sh
```

### Option B: Using wget/curl (if files are online)

```bash
cd ~/midi-studio

# Download your files
wget https://your-url.com/Loy-Krathong.mid
wget https://your-url.com/Jnsgm2.sf2

# Or download a free SoundFont
wget https://member.keymusician.com/Member/FluidR3_GM/FluidR3_GM.sf2
```

---

## 🎵 Step 5: Run the Scripts

### Basic Rendering (Volume Boost Only)

```bash
cd ~/midi-studio

# Normal volume (100%)
./midi_studio_render.sh "Loy Krathong.mid" "Jnsgm2.sf2"

# 150% volume boost
./midi_studio_render.sh "Loy Krathong.mid" "Jnsgm2.sf2" 150

# Maximum volume (300%)
./midi_studio_render.sh "Loy Krathong.mid" "Jnsgm2.sf2" 300
```

### Professional Rendering (All Effects)

```bash
# All effects enabled
./midi_studio_render_pro.sh "Loy Krathong.mid" "Jnsgm2.sf2" 150

# Custom effects
./midi_studio_render_pro.sh "Loy Krathong.mid" "Jnsgm2.sf2" 150 yes yes yes
#                                                            │   │   │   │
#                                                        Gain │   │   └── EQ
#                                                             │   └────── Compression  
#                                                             └────────── Reverb
```

---

## 📤 Step 6: Access Your Output Files

```bash
# List output files
ls -lh *.wav *.mp3

# Copy to phone storage for easy access
cp output_with_effects.mp3 ~/storage/music/
cp output_studio_processed.mp3 ~/storage/music/

# Or to Downloads folder
cp *.mp3 ~/storage/downloads/
```

---

## 🔧 Termux-Specific Optimizations

### 1. Create Aliases for Easy Use

```bash
# Add to ~/.bashrc
echo 'alias midi-render="~/midi-studio/midi_studio_render.sh"' >> ~/.bashrc
echo 'alias midi-pro="~/midi-studio/midi_studio_render_pro.sh"' >> ~/.bashrc

# Reload
source ~/.bashrc

# Now you can use:
midi-render "song.mid" "font.sf2" 150
midi-pro "song.mid" "font.sf2" 150
```

### 2. Prevent Screen Timeout During Rendering

```bash
# Install termux-api (for wake lock)
pkg install termux-api

# Keep screen awake during rendering
termux-wake-lock
./midi_studio_render_pro.sh "Loy Krathong.mid" "Jnsgm2.sf2" 150
termux-wake-unlock
```

### 3. Background Processing

```bash
# Run in background with nohup
nohup ./midi_studio_render_pro.sh "Loy Krathong.mid" "Jnsgm2.sf2" 150 &

# Check progress
tail -f nohup.out

# Check running processes
jobs
```

---

## 📊 Performance Tips for Android

### Reduce Processing Load

If rendering is slow on your device, use these optimizations:

```bash
# 1. Use lower quality FluidSynth settings
# Edit the script and change:
FLUIDSYNTH_GAIN=1  # Instead of 2 (less processing)

# 2. Disable heavy effects
./midi_studio_render_pro.sh "song.mid" "font.sf2" 150 no yes no
#                                                      │   │   │
#                                          No reverb ──┘   │   └── No EQ
#                                             Compression ──┘

# 3. Use smaller SoundFont files
# GeneralUser GS (30MB) instead of FluidR3 (150MB)
```

### Monitor Resource Usage

```bash
# Install htop to monitor CPU/RAM
pkg install htop
htop

# Check available storage
df -h
```

---

## 🎼 Complete Workflow Example

```bash
# 1. Setup (one-time)
pkg install fluidsynth sox lame bc
termux-setup-storage
mkdir -p ~/midi-studio
cd ~/midi-studio

# 2. Transfer files from phone storage
cp ~/storage/downloads/*.mid ~/midi-studio/
cp ~/storage/downloads/*.sf2 ~/midi-studio/
cp ~/storage/downloads/midi_studio_render*.sh ~/midi-studio/
chmod +x *.sh

# 3. Render with effects
./midi_studio_render_pro.sh "Loy Krathong.mid" "Jnsgm2.sf2" 150

# 4. Copy output to phone
cp output_studio_processed.mp3 ~/storage/music/

# 5. Play in your music app!
termux-open ~/storage/music/output_studio_processed.mp3
```

---

## 🐛 Troubleshooting Termux Issues

### "Permission denied" Errors

```bash
# Fix script permissions
chmod +x midi_studio_render.sh midi_studio_render_pro.sh

# Fix storage access
termux-setup-storage

# Restart Termux after granting permissions
```

### "Command not found: fluidsynth"

```bash
# Check if installed
pkg list-installed | grep fluidsynth

# Reinstall if missing
pkg install fluidsynth -y

# Update package repository
pkg update && pkg upgrade
```

### "No space left on device"

```bash
# Check available space
df -h

# Clean Termux cache
pkg clean
apt clean

# Remove old files
rm -f temp_song.wav  # Remove temporary files after rendering
```

### "Cannot find MIDI file"

```bash
# Use absolute paths
ls ~/storage/downloads/*.mid  # Find your MIDI files
ls ~/midi-studio/*.mid        # Check current directory

# Use quotes for filenames with spaces
./midi_studio_render.sh "Loy Krathong.mid" "Jnsgm2.sf2"
```

### SoX "Failed to open audio device"

This is normal! We're rendering to files, not playing audio. Ignore this warning.

---

## 🚀 Advanced: Batch Processing Multiple MIDI Files

```bash
# Create a batch processing script
cat > ~/midi-studio/batch_render.sh << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash

SOUNDFONT="$1"
GAIN="${2:-150}"

for midi in *.mid; do
    echo "Processing: $midi"
    ~/midi-studio/midi_studio_render_pro.sh "$midi" "$SOUNDFONT" "$GAIN"
    # Rename output to include original filename
    mv output_studio_processed.mp3 "${midi%.mid}_rendered.mp3"
done

echo "All files processed!"
EOF

chmod +x ~/midi-studio/batch_render.sh

# Usage: Process all MIDI files in current directory
cd ~/midi-studio
./batch_render.sh "Jnsgm2.sf2" 150
```

---

## 📱 Recommended Termux Apps

### Termux:API (Advanced Features)

```bash
pkg install termux-api

# Play rendered file directly
termux-media-player play output_studio_processed.mp3

# Share file
termux-share output_studio_processed.mp3

# Send notification when done
termux-notification --title "MIDI Render Complete" --content "Your file is ready!"
```

### Termux:Widget (Quick Access)

1. Install Termux:Widget from F-Droid
2. Create shortcut script:

```bash
mkdir -p ~/.shortcuts

cat > ~/.shortcuts/render-midi << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/midi-studio
termux-notification --title "Rendering..." --content "Processing MIDI file"
./midi_studio_render_pro.sh "Loy Krathong.mid" "Jnsgm2.sf2" 150
termux-notification --title "Complete!" --content "Check ~/storage/music/"
cp output_studio_processed.mp3 ~/storage/music/
EOF

chmod +x ~/.shortcuts/render-midi
```

3. Add widget to home screen → tap to render!

---

## 📋 Quick Command Reference

```bash
# Install everything
pkg install fluidsynth sox lame bc termux-api

# Setup storage
termux-setup-storage

# Basic render
./midi_studio_render.sh "file.mid" "font.sf2" 150

# Pro render
./midi_studio_render_pro.sh "file.mid" "font.sf2" 150

# Copy to music folder
cp output_studio_processed.mp3 ~/storage/music/

# Play file
termux-media-player play output_studio_processed.mp3
```

---

## 🎯 Summary: Ubuntu vs Termux Commands

| Task | Ubuntu | Termux |
|------|--------|--------|
| Package manager | `apt-get` | `pkg` |
| Install | `sudo apt-get install` | `pkg install` |
| Update | `sudo apt-get update` | `pkg update` |
| Storage access | `/home/user/` | `~/storage/shared/` |
| Make executable | `chmod +x file.sh` | `chmod +x file.sh` ✅ Same |
| Run script | `./script.sh` | `./script.sh` ✅ Same |

---

## ✅ You're Ready!

Your Termux environment is now a professional MIDI studio. Render high-quality audio files with effects directly on your Android device!

Need help? Check `/data/data/com.termux/files/usr/var/log/` for error logs.
