import time
import fluidsynth
import sys

class PianoPlayer:
    def __init__(self, soundfont_path, driver='pulseaudio'):
        """
        Initialize the synthesizer.
        
        Args:
            soundfont_path (str): Path to the .sf2 file.
            driver (str): Audio driver ('pulseaudio' for Termux, 'alsa' for Linux, 'coreaudio' for macOS).
        """
        self.fs = fluidsynth.Synth()
        
        # Start the audio driver
        # Note: In Termux, ensure pulseaudio is running via 'pulseaudio --start'
        print(f"[INFO] Starting audio driver: {driver}...")
        self.fs.start(driver=driver)

        # Load the soundfont
        print(f"[INFO] Loading SoundFont: {soundfont_path}...")
        self.sfid = self.fs.sfload(soundfont_path)
        
        if self.sfid == -1:
            print("[ERROR] Failed to load SoundFont! Please check the file path.")
            sys.exit(1)

        # Select the program (Bank 0, Preset 0 is usually Grand Piano in GM standard)
        self.fs.program_select(0, self.sfid, 0, 0)
        print("[INFO] Piano initialized successfully.")

    def play_note(self, note, duration=0.5, velocity=100):
        """
        Play a single note.
        
        Args:
            note (int): MIDI note number (60 is Middle C).
            duration (float): How long to play in seconds.
            velocity (int): Key pressure (0-127).
        """
        self.fs.noteon(0, note, velocity)
        time.sleep(duration)
        self.fs.noteoff(0, note)

    def play_chord(self, notes, duration=1.0, velocity=100):
        """
        Play multiple notes simultaneously (Chord).
        
        Args:
            notes (list): List of MIDI note numbers e.g., [60, 64, 67].
            duration (float): Duration in seconds.
        """
        # Turn all notes on
        for note in notes:
            self.fs.noteon(0, note, velocity)
        
        # Hold
        time.sleep(duration)
        
        # Turn all notes off
        for note in notes:
            self.fs.noteoff(0, note)

    def cleanup(self):
        """Stop and delete the synthesizer to free memory."""
        self.fs.delete()
        print("[INFO] Synthesizer shut down.")

# --- Main Execution Block ---
if __name__ == "__main__":
    # CONFIGURATION
    # You MUST change this to the actual name of your .sf2 file
    SOUNDFONT_FILE = "piano.sf2" 
    
    # Initialize the player
    piano = PianoPlayer(SOUNDFONT_FILE)

    try:
        # 1. Play a C Major Scale
        print("Playing C Major Scale...")
        scale = [60, 62, 64, 65, 67, 69, 71, 72] # C, D, E, F, G, A, B, C
        for key in scale:
            piano.play_note(key, duration=0.3)

        time.sleep(0.5)

        # 2. Play a C Major Chord (C-E-G)
        print("Playing C Major Chord...")
        piano.play_chord([60, 64, 67], duration=2.0)

        # 3. Play a quick melody (Twinkle Twinkle Little Star snippet)
        print("Playing Melody...")
        melody = [60, 60, 67, 67, 69, 69, 67] # C C G G A A G
        for key in melody:
            piano.play_note(key, duration=0.4)
            time.sleep(0.1) # Small gap between notes

    except KeyboardInterrupt:
        print("\n[INFO] Interrupted by user.")
    
    finally:
        # Always cleanup resources
        piano.cleanup()

