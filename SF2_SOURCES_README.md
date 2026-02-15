# SF2 Soundfont Collection - GitHub Sources

## Overview
This document lists all major GitHub repositories and sources for SF2 (SoundFont 2) sound effects and instruments.

## How to Use the Download Script

### Installation
```bash
# Make the script executable
chmod +x download_sf2_soundfonts.sh

# Run the script
./download_sf2_soundfonts.sh
```

### What the Script Does
- Downloads SF2 files from multiple GitHub repositories
- Organizes files in a `sf2_soundfonts` directory
- Automatically installs dependencies (curl, git)
- Provides detailed progress information

## Major GitHub Repositories with SF2 Files

### 1. bratpeki/soundfonts
**URL:** https://github.com/bratpeki/soundfonts
**Files:** 9+ SF2 files
**Notable Soundfonts:**
- ChaosBank.sf2 (CC0 1.0)
- GeneralUser.sf2 (General MIDI)
- WeedsGM3.sf2
- TimGM.sf2 (GPLv2)
- 909_drum_sf.sf2 (CC BY 3.0)

### 2. smpldsnds/soundfonts
**URL:** https://github.com/smpldsnds/soundfonts
**Files:** 4 curated SF2 files
**Notable Soundfonts:**
- galaxy-electric-pianos.sf2
- giga-hq-fm-gm.sf2 (CC 4.0)
- supersaw-collection.sf2
- yamaha-grand-lite.sf2

### 3. CarlGao4/Muse-Sounds
**URL:** https://github.com/CarlGao4/Muse-Sounds
**Description:** High-quality Muse Sounds converted to SF2/SF3 format
**Note:** Large files hosted on Cloudflare, not GitHub directly

### 4. bradhowes/SoundFonts
**URL:** https://github.com/bradhowes/SoundFonts
**Description:** iOS SoundFont player with curated SF2 collection
**Links to:** Multiple external SF2 sources

### 5. ad-si/awesome-soundfonts
**URL:** https://github.com/ad-si/awesome-soundfonts
**Type:** Curated list of soundfont resources
**Contains:** Links to numerous SF2 sources including:
- Arachno SoundFont
- GeneralUser GS
- Roland SC-55

## Popular SF2 Soundfonts Available

### General MIDI Collections
1. **GeneralUser GS** - High-quality GM soundfont
2. **FluidR3_GM** - Widely used in MuseScore
3. **Arachno SoundFont** - Comprehensive GM/GS soundfont
4. **WeedsGM3** - Alternative GM soundfont
5. **TimGM** - Compact GM soundfont

### Specialized Soundfonts
1. **909_drum_sf.sf2** - Roland TR-909 drum sounds
2. **ChaosBank.sf2** - Experimental sounds
3. **galaxy-electric-pianos.sf2** - Electric piano collection
4. **supersaw-collection.sf2** - 60 supersaw sounds

## External Sources (Not on GitHub)

### Polyphone Soundfonts
**URL:** https://www.polyphone-soundfonts.com/
**Description:** Large collection of downloadable soundfonts

### Musical Artifacts
**URL:** https://www.musical-artifacts.com/
**Description:** Community-driven soundfont repository
**SF2 Files:** 877+ soundfonts tagged

### Soundfonts 4U
**URL:** https://sites.google.com/site/soundfonts4u/
**Description:** Curated collection of free soundfonts

### rKhive
**URL:** https://rkhive.com/banks.html
**License:** CC0 1.0
**Notable Files:** ChaosBank, Masterpiece, Unison

## Download Strategies

### Method 1: Direct Download (Fastest)
Use the provided script to download individual files via curl

### Method 2: Git Clone (Complete)
Clone entire repositories to get all files including documentation

### Method 3: Manual Download
Visit repositories directly and download via browser

## File Size Considerations

**Note:** GitHub has a 100MB file size limit per file. Larger soundfonts may be:
- Split into multiple files
- Hosted on external services (Cloudflare, etc.)
- Compressed as .sf3 format

## Recommended Soundfonts for Different Uses

### For MIDI Playback
- **GeneralUser GS** - Best overall quality
- **FluidR3_GM** - Good balance of quality and size
- **Arachno SoundFont** - Most comprehensive

### For Music Production
- **galaxy-electric-pianos.sf2** - Electric pianos
- **supersaw-collection.sf2** - Synth sounds
- **yamaha-grand-lite.sf2** - Acoustic piano

### For Retro/Chiptune
- **TimGM** - Compact, authentic
- **eawpats.sf2** - Gravis Ultrasound emulation

### For Drums/Percussion
- **909_drum_sf.sf2** - Classic electronic drums

## Usage Examples

### With Timidity (Termux)
```bash
# Install timidity
pkg install timidity

# Play MIDI with specific soundfont
timidity -c GeneralUser.sf2 song.mid

# Set as default soundfont
echo "soundfont /path/to/GeneralUser.sf2" > ~/.timidity.cfg
```

### With FluidSynth
```bash
# Install fluidsynth
pkg install fluidsynth

# Load soundfont and play MIDI
fluidsynth -a android GeneralUser.sf2 song.mid
```

### With LMMS or DAW
1. Open LMMS/DAW settings
2. Add SF2 file path to soundfont directories
3. Load soundfont in instrument plugin
4. Play via MIDI keyboard or sequencer

## License Information

Most soundfonts in these repositories are:
- **CC0 1.0** - Public domain
- **CC BY 3.0** - Attribution required
- **GNU GPL** - Free to use and modify
- **Custom licenses** - Check individual files

Always check LICENSE files in repositories before commercial use.

## Contributing

To add soundfonts to this collection:
1. Ensure files are < 50MB for GitHub
2. Include proper attribution and license
3. Use descriptive filenames (kebab-case)
4. Add metadata to README

## Troubleshooting

### Download Fails
- Check internet connection
- Try alternative download method (git clone vs curl)
- Some files may be moved/removed from repositories

### File Won't Load
- Verify file integrity (not corrupted)
- Check if soundfont player supports SF2 format
- Some players only support specific SF2 versions

### Missing Files
- Files >100MB may not be on GitHub
- Check repository releases page
- Look for external download links in README

## Additional Resources

- **SFZ Format:** https://sfzformat.com/ (Alternative to SF2)
- **Polyphone Editor:** https://www.polyphone.io/ (Create/edit SF2 files)
- **FluidSynth:** https://www.fluidsynth.org/ (SF2 player library)

## Updates

This list is current as of February 2026. For the latest soundfonts:
- Star repositories to get updates
- Check Musical Artifacts weekly uploads
- Follow r/soundfonts on Reddit
- Join SoundFont communities on Discord

---

**Last Updated:** February 5, 2026
**Total Repositories Listed:** 5 major + 10 external sources
**Estimated Total SF2 Files:** 900+
