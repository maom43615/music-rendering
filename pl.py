import math
import wave
import struct

# Configuration
sample_rate = 44100
duration = 2.0 # seconds
frequency = 440.0 # Hz (A4)

# Open a wav file
audio = []
num_samples = int(sample_rate * duration)

for x in range(num_samples):
    # The Math: standard sine wave formula
    value = int(32767.0 * math.sin(2 * math.pi * frequency * x / sample_rate))
    audio.append(value)

# Write to disk
with wave.open('math_sound.wav', 'w') as f:
    f.setparams((1, 2, sample_rate, num_samples, "NONE", "not compressed"))
    for sample in audio:
        f.writeframes(struct.pack('h', sample))

print("Generated math_sound.wav")

