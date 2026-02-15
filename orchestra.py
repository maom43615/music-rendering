import sys
import struct
import math
import random

# --- CONFIG ---
SAMPLE_RATE = 44100
BPM = 100
VOLUME = 0.6

# --- SYNTHESIS ENGINES (The Instruments) ---

def wave_sine(t, freq):
    return math.sin(2 * math.pi * freq * t)

def wave_saw(t, freq):
    # Sawtooth: Rises linearly and drops
    period = 1.0 / freq
    return 2.0 * ((t / period) - math.floor(0.5 + t / period))

def wave_noise():
    return random.uniform(-1, 1)

# 1. KICK DRUM (Pitch drops fast: Pewww!)
def play_kick(t):
    if t > 0.3: return 0 # Short sound
    # Frequency drops from 150Hz to 0Hz
    drop_freq = 150 * math.exp(-15 * t)
    return wave_sine(t, drop_freq) * 0.8 * math.exp(-5 * t)

# 2. HI-HAT (Short burst of static)
def play_hat(t):
    if t > 0.05: return 0
    return wave_noise() * 0.4 * math.exp(-50 * t)

# 3. VIOLIN SECT (Sawtooth + Slow Attack "Bowing")
def play_violin(t, freq, duration):
    if t > duration: return 0
    # The "Bow": Volume swells up then stays
    attack = min(1.0, t * 5.0) 
    decay = max(0, (duration - t) * 5.0)
    envelope = min(attack, decay)
    
    # Vibrato (Quivering pitch)
    vibrato = 1.0 + 0.01 * math.sin(2 * math.pi * 6.0 * t)
    
    return wave_saw(t, freq * vibrato) * 0.4 * envelope

# 4. BASS (Triangle wave)
def play_bass(t, freq, duration):
    if t > duration: return 0
    return (abs(wave_saw(t, freq)) * 2 - 1) * 0.6 * math.exp(-t)

# --- THE CONDUCTOR (Sequencer) ---
# Define a simple looping score
beats_per_bar = 4
seconds_per_beat = 60.0 / BPM
t_global = 0.0

# Active notes [Instrument_Func, start_time, params...]
active_voices = []

# The Score: 1 = Kick, 2 = Hat, 3 = Bass C, 4 = Bass G, 5 = Chord
pattern = [
    [1, 2, 5], # Beat 1: Kick + Hat + Chord
    [2],       # Beat 2: Hat
    [1, 2, 3], # Beat 3: Kick + Hat + Bass C
    [2, 4]     # Beat 4: Hat + Bass G
]

beat_index = 0

while True:
    # 1. TRIGGER NEW NOTES
    # Check if we crossed a beat boundary
    current_beat = int(t_global / seconds_per_beat)
    
    if current_beat > beat_index:
        beat_index = current_beat
        step = beat_index % len(pattern)
        notes = pattern[step]
        
        start = t_global
        
        if 1 in notes: active_voices.append({'type': 'kick', 'start': start})
        if 2 in notes: active_voices.append({'type': 'hat', 'start': start})
        if 3 in notes: active_voices.append({'type': 'bass', 'start': start, 'freq': 65.4}) # Low C
        if 4 in notes: active_voices.append({'type': 'bass', 'start': start, 'freq': 98.0}) # Low G
        if 5 in notes: 
            # Violin Chord (C Major)
            active_voices.append({'type': 'violin', 'start': start, 'freq': 261.63, 'dur': 1.0})
            active_voices.append({'type': 'violin', 'start': start, 'freq': 329.63, 'dur': 1.0})
            active_voices.append({'type': 'violin', 'start': start, 'freq': 392.00, 'dur': 1.0})

    # 2. MIX AUDIO
    mixed_sample = 0
    
    # Process all active voices
    # We create a copy of the list [:] so we can modify the original while looping
    for voice in active_voices[:]:
        local_t = t_global - voice['start']
        val = 0
        
        if voice['type'] == 'kick': val = play_kick(local_t)
        elif voice['type'] == 'hat': val = play_hat(local_t)
        elif voice['type'] == 'bass': val = play_bass(local_t, voice['freq'], 0.5)
        elif voice['type'] == 'violin': val = play_violin(local_t, voice['freq'], voice['dur'])
        
        # If sound is done (0 silence), remove it to save CPU
        if abs(val) < 0.001 and local_t > 0.5: 
             active_voices.remove(voice)
        else:
             mixed_sample += val

    # 3. MASTER LIMITER (Prevent Distortion)
    mixed_sample = max(-1.0, min(1.0, mixed_sample * VOLUME))
    
    # 4. OUTPUT
    sys.stdout.buffer.write(struct.pack('<h', int(mixed_sample * 32767)))
    t_global += 1.0 / SAMPLE_RATE
