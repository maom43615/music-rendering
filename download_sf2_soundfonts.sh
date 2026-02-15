#!/data/data/com.termux/files/usr/bin/bash

# SF2 Soundfont Downloader for Termux
# Downloads SF2 files from multiple GitHub repositories
# Usage: bash download_sf2_soundfonts.sh

set -e

echo "========================================="
echo "SF2 Soundfont Downloader for Termux"
echo "========================================="
echo ""

# Check if required tools are installed
check_dependencies() {
    echo "[*] Checking dependencies..."
    
    if ! command -v curl &> /dev/null; then
        echo "[!] curl not found. Installing..."
        pkg install curl -y
    fi
    
    if ! command -v git &> /dev/null; then
        echo "[!] git not found. Installing..."
        pkg install git -y
    fi
    
    echo "[✓] All dependencies installed"
    echo ""
}

# Create directory for downloads
DOWNLOAD_DIR="$(pwd)/sf2_soundfonts"
mkdir -p "$DOWNLOAD_DIR"
cd "$DOWNLOAD_DIR"

echo "[*] Download directory: $DOWNLOAD_DIR"
echo ""

check_dependencies

# Counter for total downloads
TOTAL_DOWNLOADED=0

# Function to download from bratpeki/soundfonts
download_bratpeki() {
    echo "========================================="
    echo "[1] Downloading from bratpeki/soundfonts"
    echo "========================================="
    
    local repo_url="https://raw.githubusercontent.com/bratpeki/soundfonts/main/SF2"
    local files=(
        "ChaosBank.sf2"
        "Jnsgm2.sf2"
        "Masterpiece.sf2"
        "Unison.SF2"
        "909_drum_sf.sf2"
        "TimGM.sf2"
        "eawpats.sf2"
        "GeneralUser.sf2"
        "WeedsGM3.sf2"
    )
    
    for file in "${files[@]}"; do
        echo "[*] Downloading: $file"
        if curl -L -o "$file" "$repo_url/$file" 2>/dev/null; then
            echo "[✓] Downloaded: $file"
            ((TOTAL_DOWNLOADED++))
        else
            echo "[!] Failed to download: $file"
        fi
    done
    echo ""
}

# Function to download from smpldsnds/soundfonts
download_smpldsnds() {
    echo "========================================="
    echo "[2] Downloading from smpldsnds/soundfonts"
    echo "========================================="
    
    local repo_url="https://raw.githubusercontent.com/smpldsnds/soundfonts/main/soundfonts"
    local files=(
        "galaxy-electric-pianos.sf2"
        "giga-hq-fm-gm.sf2"
        "supersaw-collection.sf2"
        "yamaha-grand-lite.sf2"
    )
    
    for file in "${files[@]}"; do
        echo "[*] Downloading: $file"
        if curl -L -o "$file" "$repo_url/$file" 2>/dev/null; then
            echo "[✓] Downloaded: $file"
            ((TOTAL_DOWNLOADED++))
        else
            echo "[!] Failed to download: $file"
        fi
    done
    echo ""
}

# Function to download popular SF2 files from various sources
download_popular_soundfonts() {
    echo "========================================="
    echo "[3] Downloading Popular Soundfonts"
    echo "========================================="
    
    # FluidR3_GM (if available via direct link)
    echo "[*] Downloading: FluidR3_GM.sf2"
    if curl -L -o "FluidR3_GM.sf2" "https://github.com/musescore/MuseScore/raw/2.3.2/share/sound/FluidR3_GM.sf2" 2>/dev/null; then
        echo "[✓] Downloaded: FluidR3_GM.sf2"
        ((TOTAL_DOWNLOADED++))
    else
        echo "[!] Failed to download: FluidR3_GM.sf2"
    fi
    
    echo ""
}

# Function to clone entire repositories with SF2 files
clone_repositories() {
    echo "========================================="
    echo "[4] Cloning Complete Repositories"
    echo "========================================="
    
    # Clone bratpeki/soundfonts
    if [ ! -d "bratpeki_soundfonts" ]; then
        echo "[*] Cloning bratpeki/soundfonts..."
        if git clone --depth 1 https://github.com/bratpeki/soundfonts.git bratpeki_soundfonts 2>/dev/null; then
            echo "[✓] Cloned bratpeki/soundfonts"
            # Copy SF2 files to main directory
            if [ -d "bratpeki_soundfonts/SF2" ]; then
                cp bratpeki_soundfonts/SF2/*.sf2 . 2>/dev/null || true
                cp bratpeki_soundfonts/SF2/*.SF2 . 2>/dev/null || true
            fi
        else
            echo "[!] Failed to clone bratpeki/soundfonts"
        fi
    fi
    
    # Clone smpldsnds/soundfonts
    if [ ! -d "smpldsnds_soundfonts" ]; then
        echo "[*] Cloning smpldsnds/soundfonts..."
        if git clone --depth 1 https://github.com/smpldsnds/soundfonts.git smpldsnds_soundfonts 2>/dev/null; then
            echo "[✓] Cloned smpldsnds/soundfonts"
            # Copy SF2 files to main directory
            if [ -d "smpldsnds_soundfonts/soundfonts" ]; then
                cp smpldsnds_soundfonts/soundfonts/*.sf2 . 2>/dev/null || true
            fi
        else
            echo "[!] Failed to clone smpldsnds/soundfonts"
        fi
    fi
    
    echo ""
}

# Additional soundfonts from archive.org and other sources
download_additional_sources() {
    echo "========================================="
    echo "[5] Downloading from Additional Sources"
    echo "========================================="
    
    # Download Arachno SoundFont (popular GM soundfont)
    echo "[*] Downloading: Arachno SoundFont"
    if curl -L -o "arachno.sf2" "https://www.arachnosoft.com/main/download.php?id=soundfont-sf2" 2>/dev/null; then
        echo "[✓] Downloaded: arachno.sf2"
        ((TOTAL_DOWNLOADED++))
    else
        echo "[!] Failed to download: arachno.sf2"
    fi
    
    echo ""
}

# Main execution
echo "[*] Starting download process..."
echo ""

download_bratpeki
download_smpldsnds
download_popular_soundfonts
clone_repositories

# Count total SF2 files in directory
TOTAL_FILES=$(find . -maxdepth 1 -name "*.sf2" -o -name "*.SF2" | wc -l)

echo "========================================="
echo "Download Complete!"
echo "========================================="
echo "Total SF2 files in directory: $TOTAL_FILES"
echo "Download directory: $DOWNLOAD_DIR"
echo ""
echo "To use these soundfonts:"
echo "1. Install a MIDI player like timidity"
echo "2. Configure it to use these soundfonts"
echo "3. Play MIDI files with your chosen soundfont"
echo ""
echo "Example with timidity:"
echo "  pkg install timidity"
echo "  timidity -c $DOWNLOAD_DIR/GeneralUser.sf2 your_song.mid"
echo ""
echo "========================================="

# List all downloaded SF2 files
echo ""
echo "[*] Downloaded SF2 files:"
ls -lh *.sf2 *.SF2 2>/dev/null | awk '{print "    " $9 " (" $5 ")"}'

exit 0
