import time
import fluidsynth
import sys
import os
import glob

# Configuration
DRIVER = 'pulseaudio'  # Standard for Termux

class SF2Showcase:
    def __init__(self, soundfont_path):
        self.fs = fluidsynth.Synth()
        
        print(f"[Init] Starting audio driver ({DRIVER})...")
        self.fs.start(driver=DRIVER)

        print(f"[Init] Loading SoundFont: {os.path.basename(soundfont_path)}...")
        self.sfid = self.fs.sfload(soundfont_path)
        
        if self.sfid == -1:
            print("[Error] Could not load SoundFont!")
            sys.exit(1)
            
        # Default high gain for mobile speakers
        self.fs.setting('synth.gain', 2.0)

    def select_instrument(self, channel, bank, preset):
        """Selects an instrument on a specific channel."""
        self.fs.program_select(channel, self.sfid, bank, preset)

    def note_on(self, channel, key, velocity):
        self.fs.noteon(channel, key, velocity)

    def note_off(self, channel, key):
        self.fs.noteoff(channel, key)

    def cleanup(self):
        self.fs.delete()

# --- DEMO 1: RICH SOLO (Best for Yamaha Grand, Galaxy E-Pianos) ---
def play_expressive_solo(synth):
    print("\n--- Playing Expressive Solo Demo ---")
    print("Best for: Yamaha Grand, Galaxy Electric Pianos")
    print("Listening for: Velocity layers (soft vs hard touches)")
    
    # Channel 0, Bank 0, Preset 0 (Usually the main instrument)
    synth.select_instrument(0, 0, 0)

    # A Jazz ii-V-I progression (Dm9 -> G13 -> Cmaj9)
    # Format: (Note, Velocity) - Velocity changes tone in good SF2s
    chords = [
        # Dm9 (Low velocity = mellow sound)
        ([50, 57, 60, 64, 65, 69], 60), 
        # G13 (Medium velocity)
        ([43, 53, 59, 64, 65, 69], 85),
        # Cmaj9 (High velocity = bright sound)
        ([48, 55, 59, 62, 64, 67], 110)
    ]

    for notes, vel in chords:
        print(f"Chord Strike! Velocity: {vel}")
        for note in notes:
            synth.note_on(0, note, vel)
        
        # Arpeggiate top notes slightly for realism
        time.sleep(0.05) 
        
        time.sleep(2.0) # Hold chord
        
        # Release notes
        for note in notes:
            synth.note_off(0, note)
        time.sleep(0.1)

# --- DEMO 2: FULL BAND (Best for Jnsgm2, MuseScore) ---
def play_gm_band(synth):
    print("\n--- Playing Full Band General MIDI Demo ---")
    print("Best for: Jnsgm2, MuseScore_General, ChaosBank")
    print("Structure: Drums (Ch9), Bass (Ch1), Piano (Ch0)")

    # 1. Setup Instruments
    # Channel 0: Piano (Bank 0, Preset 0)
    synth.select_instrument(0, 0, 0)
    
    # Channel 1: Fingered Bass (Bank 0, Preset 33)
    synth.select_instrument(1, 0, 33)
    
    # Channel 9: Drums (Bank 128, Preset 0 is standard GM Drums)
    # Note: Fluidsynth channels are 0-indexed, so Ch 9 is MIDI Ch 10
    synth.select_instrument(9, 128, 0)

    # 2. Define Loops
    # Simple Funk Groove
    # 8 steps (Eighth notes)
    # Kick=36, Snare=38, ClosedHat=42
    drum_pattern = [
        [36, 42],       # Step 1: Kick + Hat
        [42],           # Step 2: Hat
        [38, 42],       # Step 3: Snare + Hat
        [42],           # Step 4: Hat
        [36, 42],       # Step 5: Kick + Hat
        [36, 42],       # Step 6: Kick + Hat
        [38, 42],       # Step 7: Snare + Hat
        [42]            # Step 8: Hat
    ]
    
    bass_line = [36, 36, 38, 39, 41, 41, 39, 38] # C blues scale walk
    piano_chord = [60, 63, 67, 70] # C Minor 7

    tempo = 0.25 # Seconds per step

    print("Starting Groove... (Press Ctrl+C to stop)")
    
    # Play 4 bars
    for bar in range(4):
        print(f"Bar {bar+1}/4")
        
        # Strike Piano Chord on beat 1 of every bar
        for note in piano_chord:
            synth.note_on(0, note, 90)
            
        for step in range(8):
            # Drums
            for drum in drum_pattern[step]:
                synth.note_on(9, drum, 100)
            
            # Bass
            if step < len(bass_line):
                synth.note_on(1, bass_line[step], 110)

            time.sleep(tempo)

            # Note Offs (Bass is short, Drums decay naturally)
            if step < len(bass_line):
                synth.note_off(1, bass_line[step])
            
            # Turn off drums (optional, but good practice)
            for drum in drum_pattern[step]:
                synth.note_off(9, drum)

        # Piano Chord Off at end of bar
        for note in piano_chord:
            synth.note_off(0, note)

# --- MAIN MENU ---
def main():
    # 1. Find SF2 files
    sf2_files = glob.glob("*.sf2") + glob.glob("*.SF2")
    if not sf2_files:
        print("[!] No .sf2 files found in current directory.")
        return

    print("\n=== SF2 SoundFont Tester ===")
    for i, f in enumerate(sf2_files):
        size = os.path.getsize(f) / (1024*1024)
        print(f"{i+1}. {f} ({size:.1f} MB)")

    try:
        choice = int(input("\nSelect SoundFont (Number): ")) - 1
        selected_sf2 = sf2_files[choice]
    except (ValueError, IndexError):
        print("Invalid selection.")
        return

    print(f"\nSelected: {selected_sf2}")
    print("1. Expressive Solo (For Piano/Electric Piano fonts)")
    print("2. Full Band (For General MIDI/MuseScore/Jnsgm2 fonts)")
    
    try:
        mode = int(input("Select Demo Mode (1 or 2): "))
    except ValueError:
        mode = 1

    player = SF2Showcase(selected_sf2)

    try:
        if mode == 1:
            play_expressive_solo(player)
        else:
            play_gm_band(player)
            
        print("\nDemo finished.")
        
    except KeyboardInterrupt:
        print("\nStopped by user.")
    finally:
        player.cleanup()

if __name__ == "__main__":
    main()

