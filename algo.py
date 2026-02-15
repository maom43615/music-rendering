import random
from scamp import *

# 1. Start the Session (The "Brain")
# playback_settings specifically helps Termux/Linux find the audio driver
s = Session(tempo=120) 

# 2. Create an Instrument (The "Voice")
# SCAMP uses a default soundfont (usually piano/sine) if none is provided.
piano = s.new_part("piano")

print(">>> Session Started. Generating Audio...")

# 3. The Algorithm (The "Score")
# We will generate a random walk melody
pitch = 60 # Middle C
key_scale = [0, 2, 4, 5, 7, 9, 11] # Major scale intervals

try:
    for i in range(16):
        # Human-readable output to see what's happening
        print(f"Playing MIDI pitch: {pitch}")
        
        # Play the note
        # play_note(pitch, volume, duration)
        piano.play_note(pitch, 0.7, 0.25)
        
        # Algorithmic change: Move up or down randomly
        step = random.choice([-1, 1, 0, 2])
        
        # Snap to a simple scale logic (simplified for 'Hello World')
        pitch += step
        
except KeyboardInterrupt:
    print("\nStopping music.")


