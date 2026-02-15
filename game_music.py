import sys
import struct
import math
import random

# --- CONFIG ---
SAMPLE_RATE = 44100
BPM = 135 # Fast action tempo
VOLUME = 0.5
SECONDS_PER_BEAT = 60.0 / BPM

# --- SOUND ENGINE (Chiptune Style) ---

def wave_square(t, freq, duty=0.5):
    # NES-style square wave. Duty cycle changes the "width" of the sound.
    period = 1.0 / freq
    phase = (t / period) - math.floor(t / period)
    return 1.0 if phase < duty else -1.0

def wave_noise():
    return random.uniform(-1, 1)

def wave_saw(t, freq):
    period = 1.0 / freq
    return 2.0 * ((t / period) - math.floor(0.5 + t / period))

# 1. SNARE (Noise burst)
def play_snare(t):
    if t > 0.15: return 0
    # Mix noise with a quick pitch drop for "punch"
    return wave_noise() * 0.5 * math.exp(-20 * t)

# 2. BASS (Fast, driving saw wave)
def play_bass(t, freq):
    if t > 0.2: return 0
    # Low pass filter effect simulated by volume envelope
    return wave_saw(t, freq) * 0.8 * math.exp(-10 * t)

# 3. LEAD SYNTH (Square wave with arpeggio effect)
def play_lead(t, freq, duration):
    if t > duration: return 0
    # 50% duty cycle = distinct "video game" tone
    # Slide pitch slightly for "laser" effect
    slide = freq - (10 * t) 
    return wave_square(t, slide, 0.5) * 0.4 * math.exp(-2 * t)

# --- THE TRACK (Level 1 Theme) ---
# A Minor Arpeggio pattern
bass_line = [55, 55, 65.4, 55, 73.4, 55, 65.4, 55] # A, A, C, A, D, A, C, A
lead_melody = [
    (440, 0.5), (523.25, 0.5), (659.25, 0.5), (880, 0.5), # A C E A
    (783.99, 0.5), (659.25, 0.5), (523.25, 0.5), (587.33, 0.5) # G E C D
]

t_global = 0.0
step = 0

while True:
    # 1. SEQUENCER
    # 16th notes (4 steps per beat)
    step_duration = SECONDS_PER_BEAT / 4.0
    current_step = int(t_global / step_duration)
    
    # Generate 1 second of audio at a time to keep logic simple
    # But for a realtime stream, we calculate sample by sample
    
    # 2. MIXER
    # We mix slightly ahead of time? No, let's do sample-by-sample for accuracy
    
    # Calculate local time within the step
    local_t = t_global % step_duration
    
    # TRIGGER EVENTS (On the start of a step)
    is_beat = (current_step % 4 == 0)
    is_offbeat = (current_step % 4 == 2)
    
    # Drums: Kick on 1, Snare on 3
    kick_val = 0
    snare_val = 0
    
    # Kick (Simple sine drop)
    if (current_step % 4) == 0 and local_t < 0.2:
        kick_val = math.sin(2 * math.pi * 60 * (1-local_t*4) * local_t) * 0.8
        
    # Snare (Noise) on beats 2 and 4 (steps 4 and 12 in a 16-step bar)
    # Let's do a simple House beat: Kick on 0, 4, 8, 12. Snare on 4, 12
    if (current_step % 8) == 4 and local_t < 0.15:
        snare_val = wave_noise() * 0.6 * math.exp(-20 * local_t)

    # Bass (Running 16th notes)
    bass_note = bass_line[current_step % 8]
    bass_val = play_bass(local_t, bass_note)
    
    # Lead (Slower melody)
    lead_idx = (current_step // 4) % 8
    lead_freq, lead_dur = lead_melody[lead_idx]
    # Only play lead if we are in the first part of the note
    lead_local_t = (t_global % (step_duration * 4)) 
    lead_val = play_lead(lead_local_t, lead_freq, lead_dur * SECONDS_PER_BEAT)

    # 3. SUM
    mixed = kick_val + snare_val + bass_val + lead_val
    
    # 4. LIMITER
    mixed = max(-1.0, min(1.0, mixed * VOLUME))
    
    sys.stdout.buffer.write(struct.pack('<h', int(mixed * 32767)))
    t_global += 1.0 / SAMPLE_RATE
