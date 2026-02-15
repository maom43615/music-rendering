import time
import fluidsynth
import sys
import os

# --- CONFIGURATION ---
# Total play time target per file (approx 25-30s to equal ~2 mins total)
DEMO_DURATION = 30 
DRIVER = 'pulseaudio' # Standard for Termux

# List of files to test
SF2_FILES = [
    "ChaosBank.sf2",
    "Jnsgm2.sf2",
    "MuseScore_General.sf2",
    "yamaha-grand-lite.sf2",
    "galaxy-electric-pianos.sf2"
]

class SoundFontTester:
    def __init__(self):
        print(f"[Init] Starting Audio Driver ({DRIVER})...")
        self.fs = fluidsynth.Synth()
        self.fs.start(driver=DRIVER)
        # Boost volume for mobile speakers
        self.fs.setting('synth.gain', 1.5)

    def load_font(self, path):
        """Loads a SF2 and returns the ID. Returns -1 on failure."""
        if not os.path.exists(path):
            print(f"[Skip] File not found: {path}")
            return -1
            
        # Check for empty/corrupt files (common download error)
        if os.path.getsize(path) < 1024:
            print(f"[Skip] File is too small/corrupt (<1KB): {path}")
            return -1

        print(f"\n[Load] Loading: {path}...")
        sfid = self.fs.sfload(path)
        
        if sfid == -1:
            print(f"[Fail] Failed to load {path} (Invalid format?)")
        return sfid

    def has_drums(self, sfid):
        """Checks if Bank 128 (Standard Percussion) exists."""
        # We try to select the standard drum kit
        # program_select(channel, sfid, bank, preset)
        # Returns 0 on success, -1 on failure
        # We use a test channel (15) to check
        if self.fs.program_select(15, sfid, 128, 0) == 0:
            return True
        return False

    def play_note(self, channel, note, velocity, duration):
        self.fs.noteon(channel, note, velocity)
        # Non-blocking play would require a scheduler, 
        # but for this script, we manage time in the main loop
    
    def cleanup(self):
        self.fs.delete()

# --- MUSIC DATA ---
# A simple chord progression: Am - F - C - G
CHORDS = [
    [57, 60, 64], # Am
    [53, 57, 60], # F
    [48, 52, 55], # C
    [55, 59, 62]  # G
]
BASS_NOTES = [45, 41, 36, 43] # A, F, C, G (Low)

# --- DEMO ROUTINES ---

def run_band_demo(tester, sfid):
    """Plays Drums, Bass, Piano, and Strings."""
    print("   [Mode] Full Band Detected (GM Compatible)")
    print("   [Test] Drums(Ch9) + Bass(Ch1) + Piano(Ch0) + Strings(Ch2)")
    
    fs = tester.fs
    
    # Setup Instruments
    fs.program_select(0, sfid, 0, 0)   # Piano
    fs.program_select(1, sfid, 0, 33)  # Fingered Bass
    fs.program_select(2, sfid, 0, 48)  # Strings Ensemble
    fs.program_select(9, sfid, 128, 0) # Standard Drum Kit

    bpm = 0.25 # 120 BPM sixteenths
    loops = int(DEMO_DURATION / (bpm * 16)) # Calculate loops to fit duration
    
    print(f"   [Play] Playing {loops} loops (~{DEMO_DURATION}s)...")

    for _ in range(loops):
        for i, chord in enumerate(CHORDS):
            # Start of Measure
            
            # 1. Bass (Long note)
            fs.noteon(1, BASS_NOTES[i], 100)
            
            # 2. Strings (Pad)
            for note in chord:
                fs.noteon(2, note + 12, 60) # +12 for octave up
            
            # 3. Beat Loop (4 beats per chord)
            for beat in range(4):
                # Piano Chord (Quarter notes)
                for note in chord:
                    fs.noteon(0, note, 90)
                
                # Drums: Simple Rock Beat
                fs.noteon(9, 36, 100) # Kick
                fs.noteon(9, 42, 80)  # Hat
                time.sleep(bpm)
                fs.noteoff(0, chord[0]); fs.noteoff(0, chord[1]); fs.noteoff(0, chord[2]) # Piano Staccato
                
                fs.noteon(9, 42, 80)  # Hat
                time.sleep(bpm)
                
                fs.noteon(9, 38, 100) # Snare
                fs.noteon(9, 42, 80)  # Hat
                time.sleep(bpm)
                
                fs.noteon(9, 42, 80)  # Hat
                time.sleep(bpm)

            # End of Measure - Note Offs
            fs.noteoff(1, BASS_NOTES[i])
            for note in chord:
                fs.noteoff(2, note + 12)

def run_solo_demo(tester, sfid):
    """Plays a dynamic solo piano piece."""
    print("   [Mode] Solo Instrument Detected")
    print("   [Test] High Dynamic Range (Velocity 40 -> 120)")
    
    fs = tester.fs
    fs.program_select(0, sfid, 0, 0) # Default Preset
    
    arpeggios = [
        [45, 52, 57, 60, 64, 69], # A minor 9
        [41, 48, 53, 57, 60, 65], # F major 7
        [36, 43, 48, 52, 55, 59], # C major 7
        [43, 50, 55, 59, 62, 67]  # G dominant
    ]
    
    print(f"   [Play] Playing Arpeggios (~{DEMO_DURATION}s)...")
    
    start_time = time.time()
    
    while time.time() - start_time < DEMO_DURATION:
        for arp in arpeggios:
            # 1. Soft Upward Sweep
            for note in arp:
                fs.noteon(0, note, 50) # Soft
                time.sleep(0.1)
            
            time.sleep(0.5)
            
            # 2. Loud Downward Strike (Chord)
            for note in arp:
                fs.noteoff(0, note) # Release previous
                fs.noteon(0, note, 110) # Loud!
            
            time.sleep(1.0)
            
            # Release
            for note in arp:
                fs.noteoff(0, note)
                
            time.sleep(0.2)

# --- MAIN EXECUTION ---
def main():
    tester = SoundFontTester()
    
    print("=========================================")
    print("   FULL SF2 SUITE TESTER (2 MINS)")
    print("=========================================")

    try:
        for filename in SF2_FILES:
            sfid = tester.load_font(filename)
            
            if sfid != -1:
                # INTELLIGENT DETECTION
                if tester.has_drums(sfid):
                    run_band_demo(tester, sfid)
                else:
                    run_solo_demo(tester, sfid)
                
                # Unload to save RAM for next file
                tester.fs.sfunload(sfid)
                print("   [Done] Unloaded.\n")
                time.sleep(1) # Brief pause between fonts
                
    except KeyboardInterrupt:
        print("\n[Stop] Test interrupted by user.")
    
    finally:
        tester.cleanup()
        print("Test Complete.")

if __name__ == "__main__":
    main()

