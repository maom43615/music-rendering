#!/data/data/com.termux/files/usr/bin/bash

# SF2 Downloader v2.3 (Network Fix)
# fixes SSL handshakes, IPv6 timeouts, and User-Agent blocking

# Setup
DOWNLOAD_DIR="$(pwd)/sf2_soundfonts"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   SF2 Downloader v2.3 (Network Fix)${NC}"
echo -e "${BLUE}=========================================${NC}"

# Robust Download Function
download_force() {
    local url="$1"
    local filename="$2"
    
    if [ -s "$filename" ]; then
        echo -e "${YELLOW}[Skip]${NC} $filename (Exists)"
        return 0
    fi

    echo -ne "${BLUE}[....]${NC} Downloading: $filename\r"
    
    # Flags explained:
    # -L: Follow redirects
    # -k: Insecure (ignore SSL certificate errors)
    # -4: Force IPv4 (more stable on mobile)
    # -A: User Agent (pretend to be Chrome)
    # --fail: Report error if 404/500
    
    if curl -L -k -4 -A "Mozilla/5.0" --fail --connect-timeout 15 --retry 2 -o "$filename" "$url"; then
        if [ -s "$filename" ]; then
            echo -e "${GREEN}[Down]${NC} Success:     $filename"
        else
            echo -e "${RED}[Fail]${NC} Empty file:  $filename"
            rm "$filename" 2>/dev/null
        fi
    else
        # If standard curl fails, print the error code for debugging
        echo -e "${RED}[Fail]${NC} Error downloading $filename"
    fi
}

# --- BATCH 1: Standard Files (bratpeki) ---
# If these still fail, the repository might be down/changed
base_url="https://raw.githubusercontent.com/bratpeki/soundfonts/main/SF2"

echo "--- Standard Set ---"
download_force "$base_url/Masterpiece.sf2" "Masterpiece.sf2"
download_force "$base_url/Unison.SF2" "Unison.SF2"
download_force "$base_url/909_drum_sf.sf2" "909_drum_sf.sf2"
download_force "$base_url/TimGM.sf2" "TimGM.sf2"
download_force "$base_url/GeneralUser.sf2" "GeneralUser.sf2"

# --- BATCH 2: Backup Source (wrightflyer) ---
# This is often more reliable if batch 1 fails
echo ""
echo "--- Backup Source ---"
download_force "https://github.com/wrightflyer/SF2_SoundFonts/raw/master/Jnsgm2.sf2" "Jnsgm2.sf2"
download_force "https://github.com/wrightflyer/SF2_SoundFonts/raw/master/SGM-v2.01-NicePianosGuitarsBass-V1.2.sf2" "SGM-v2.01.sf2"

# --- BATCH 3: MuseScore ---
echo ""
echo "--- MuseScore ---"
download_force "https://ftp.osuosl.org/pub/musescore/soundfont/MuseScore_General/MuseScore_General.sf2" "MuseScore_General.sf2"

echo ""
echo -e "${GREEN}Process Complete.${NC}"
ls -lh *.sf2 *.SF2 2>/dev/null | awk '{print $9, "(" $5 ")"}'

