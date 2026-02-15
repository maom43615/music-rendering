import sys
import struct
import math
import random

# --- CONFIG ---
SAMPLE_RATE = 44100
VOLUME = 0.3

# --- NATURE ENGINE ---

def pink_noise(state):
    # Pink noise is "softer" than white noise (sounds like rain, not static)
    # We use a Paul Kellet's refined method
    white = random.uniform(-1, 1)
    state[0] = 0.99886 * state[0] + white * 0.0555179
    state[1] = 0.99332 * state[1] + white * 0.0750759
    state[2] = 0.96900 * state[2] + white * 0.1538520
    state[3] = 0.86650 * state[3] + white * 0.3104856
    state[4] = 0.55000 * state[4] + white * 0.5329522
    state[5] = -0.7616 * state[5] - white * 0.0168980
    pink = sum(state) + white * 0.5362
    return pink * 0.11, state

def thunder_clap(t):
    if t > 2.0: return 0
    # Thunder is just loud noise passed through a Low Pass Filter
    # We simulate the rumble by modulating volume randomly
    rumble = random.uniform(-1, 1) * math.exp(-1.5 * t)
    return rumble * 0.8

# --- MAIN LOOP ---
pink_state = [0, 0, 0, 0, 0, 0]
thunder_timer = 0
is_thundering = False

while True:
    # 1. GENERATE RAIN (Constant)
    rain, pink_state = pink_noise(pink_state)
    
    # 2. GENERATE THUNDER (Random)
    thunder = 0
    if is_thundering:
        thunder = thunder_clap(thunder_timer)
        thunder_timer += 1.0/SAMPLE_RATE
        if thunder_timer > 2.0: is_thundering = False
    elif random.random() < 0.00005: # Rare chance to start thunder
        is_thundering = True
        thunder_timer = 0

    # 3. MIX
    mixed = (rain * 0.5) + (thunder * 0.8)
    
    # 4. OUTPUT
    mixed = max(-1.0, min(1.0, mixed * VOLUME))
    sys.stdout.buffer.write(struct.pack('<h', int(mixed * 32767)))

