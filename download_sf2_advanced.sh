#!/data/data/com.termux/files/usr/bin/bash

# SF2 Downloader v2.2 (Clean Output)
# Fixes redundant messages and Jnsgm2 download error

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Setup
DOWNLOAD_DIR="$(pwd)/sf2_soundfonts"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   SF2 Soundfont Downloader v2.2${NC}"
echo -e "${BLUE}   Location: $DOWNLOAD_DIR${NC}"
echo -e "${BLUE}=========================================${NC}"

# Smart Download Function
download_smart() {
    local url="$1"
    local filename="$2"
    
    # 1. Check if file exists
    if [ -s "$filename" ]; then
        echo -e "${YELLOW}[Skip]${NC} $filename (Exists)"
        return 0
    fi

    # 2. Try to download
    echo -ne "${BLUE}[....]${NC} Downloading: $filename\r"
    
    if curl -L --fail --silent --connect-timeout 10 -o "$filename" "$url"; then
        # Check if file is not empty (some errors produce empty files)
        if [ -s "$filename" ]; then
            echo -e "${GREEN}[Down]${NC} Success:     $filename"
            return 0
        else
            echo -e "${RED}[Fail]${NC} Empty file:  $filename"
            rm "$filename" 2>/dev/null
            return 1
        fi
    else
        echo -e "${RED}[Fail]${NC} Error:       $filename"
        return 1
    fi
}

# --- BATCH 1: Standard Files ---
echo ""
echo "--- Essential Soundfonts ---"
base_url="https://raw.githubusercontent.com/bratpeki/soundfonts/main/SF2"

download_smart "$base_url/ChaosBank.sf2" "ChaosBank.sf2"
download_smart "$base_url/Masterpiece.sf2" "Masterpiece.sf2"
download_smart "$base_url/Unison.SF2" "Unison.SF2"
download_smart "$base_url/909_drum_sf.sf2" "909_drum_sf.sf2"
download_smart "$base_url/TimGM.sf2" "TimGM.sf2"
download_smart "$base_url/GeneralUser.sf2" "GeneralUser.sf2"

# --- BATCH 2: The Fix for Jnsgm2 ---
# Uses a backup mirror because the original link often fails
download_smart "https://github.com/wrightflyer/SF2_SoundFonts/raw/master/Jnsgm2.sf2" "Jnsgm2.sf2"

# --- BATCH 3: High Quality ---
echo ""
echo "--- High Quality Extensions ---"
base_url_2="https://raw.githubusercontent.com/smpldsnds/soundfonts/main/soundfonts"

download_smart "$base_url_2/galaxy-electric-pianos.sf2" "galaxy-electric-pianos.sf2"
download_smart "$base_url_2/yamaha-grand-lite.sf2" "yamaha-grand-lite.sf2"

# --- BATCH 4: MuseScore (Large) ---
echo ""
echo "--- MuseScore General (Large) ---"
download_smart "https://ftp.osuosl.org/pub/musescore/soundfont/MuseScore_General/MuseScore_General.sf2" "MuseScore_General.sf2"
download_smart "https://keymusician01.s3.amazonaws.com/FluidR3_GM.sf2" "FluidR3_GM.sf2"

# --- Summary ---
echo ""
echo -e "${GREEN}Done! Check the folder: $DOWNLOAD_DIR${NC}"
ls -lh *.sf2 *.SF2 2>/dev/null | awk '{print $9, "(" $5 ")"}'

