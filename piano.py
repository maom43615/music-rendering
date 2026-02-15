import sys
import struct
import math
import random

# --- CONFIG ---
SAMPLE_RATE = 44100
VOLUME = 0.5 * 32767

# --- THE FM SYNTHESIS ENGINE ---
# Simulates an Electric Piano (Rhodes-style)
def get_sample(freq, t, decay_time):
    # Envelope: Fast attack, slow exponential decay
    envelope = math.exp(-3.0 * t / decay_time)
    
    # FM Synthesis Math:
    # Carrier = The main note frequency
    # Modulator = Changes the timbre (tone) over time
    # For a piano sound, we use a 1:1 ratio but modulate the brightness
    
    modulator_freq = freq * 1.0  # Ratio 1:1
    modulation_index = 2.0 * envelope # The tone gets mellower as it decays
    
    # The FM Formula: sin(Carrier + Index * sin(Modulator))
    val = math.sin(2 * math.pi * freq * t + 
                   modulation_index * math.sin(2 * math.pi * modulator_freq * t))
    
    return val * envelope * VOLUME

# --- MUSIC THEORY (Jazz Chords) ---
# Frequencies for keys
def note(name):
    # Dictionary of base frequencies
    freqs = {'C': 261.63, 'D': 293.66, 'E': 329.63, 'F': 349.23, 'G': 392.00, 'A': 440.00, 'B': 493.88}
    base = freqs[name[0]]
    if len(name) > 1 and name[1] == 'b': base *= 0.9438 # Flat
    octave = 4 # Default octave
    if name[-1].isdigit(): octave = int(name[-1])
    return base * (2 ** (octave - 4))

# A nice Jazz Chord progression (ii - V - I in C Major)
# Each chord is a list of frequencies
progression = [
    [note('D3'), note('F3'), note('A3'), note('C4')], # Dm7
    [note('G2'), note('F3'), note('A3'), note('B3')], # G7
    [note('C3'), note('E3'), note('G3'), note('B3')], # Cmaj7
    [note('A2'), note('C3'), note('E3'), note('G3')]  # Am7
]

# --- MAIN LOOP ---
buffer_size = 0
current_chord_idx = 0
time_per_chord = 2.0 # seconds
t_global = 0.0

while True:
    # 1. Which chord are we playing?
    chord_freqs = progression[current_chord_idx]
    
    # Calculate time within the current chord (0.0 to 2.0)
    t_local = t_global % time_per_chord
    
    # 2. Switch chord if time is up
    if t_local < 1.0 / SAMPLE_RATE: # Just switched
        current_chord_idx = (current_chord_idx + 1) % len(progression)
        # Add a random "trill" or variation occasionally
        if random.random() > 0.7:
             time_per_chord = random.choice([1.0, 2.0, 4.0])

    # 3. Synthesize the Audio (Polyphonic - mix all notes)
    mixed_sample = 0
    for f in chord_freqs:
        # Stagger the notes slightly (strumming effect)
        strum_delay = 0.05 * chord_freqs.index(f)
        if t_local > strum_delay:
            mixed_sample += get_sample(f, t_local - strum_delay, 2.0)

    # 4. Output
    # Clamp to prevent distortion
    mixed_sample = max(-32767, min(32767, mixed_sample))
    
    sys.stdout.buffer.write(struct.pack('<h', int(mixed_sample)))
    
    t_global += 1.0 / SAMPLE_RATE

