import sys
import struct
import random
import collections

# --- CONFIGURATION ---
SAMPLE_RATE = 44100
TEMPO = 4  # Notes per second (approx)
VOLUME = 20000  # Max amplitude (0-32767)

# --- THE PHYSICS (Karplus-Strong Algorithm) ---
# This simulates a string by filtering noise repeatedly
class String:
    def __init__(self, frequency):
        # Calculate the length of the string in samples
        N = int(SAMPLE_RATE / frequency)
        # Fill the string with random noise (The "Pluck")
        self.buffer = collections.deque([random.uniform(-1, 1) for _ in range(N)])

    def sample(self):
        # Pop the first sample
        val = self.buffer.popleft()
        # Look at the next sample (which is now at index 0)
        next_val = self.buffer[0]
        # Average them and apply decay (0.996 makes it fade out like a string)
        avg = 0.996 * 0.5 * (val + next_val)
        # Push the result back to the end of the string
        self.buffer.append(avg)
        return val

# --- MUSIC THEORY ---
# Frequencies for A Minor Pentatonic Scale (Sounds good in any order)
# A2, C3, D3, E3, G3, A3
NOTES = [110.0, 130.81, 146.83, 164.81, 196.00, 220.00]

# --- MAIN LOOP ---
active_strings = [] # List of strings currently vibrating
samples_per_beat = int(SAMPLE_RATE / TEMPO)
counter = 0

while True:
    # 1. TIME TO PLUCK A NEW NOTE?
    if counter <= 0:
        # Pick a random note from the scale
        freq = random.choice(NOTES)
        # Add a new vibrating string to our list
        active_strings.append(String(freq))
        # Keep only the last 3 strings to save CPU (Polyphony limit)
        if len(active_strings) > 3:
            active_strings.pop(0)

        # Reset counter for next pluck (random rhythm)
        counter = samples_per_beat * random.choice([1, 2, 0.5])

    # 2. CALCULATE AUDIO
    # Sum the sound of all active strings
    mixed_sample = 0
    for s in active_strings:
        mixed_sample += s.sample()

    # 3. PREVENT DISTORTION
    # Clamp value between -1 and 1
    mixed_sample = max(-1.0, min(1.0, mixed_sample))

    # 4. OUTPUT
    # Convert to 16-bit integer
    int_sample = int(mixed_sample * VOLUME)
    audio_data = struct.pack('<h', int_sample)
    sys.stdout.buffer.write(audio_data)

    counter -= 1
