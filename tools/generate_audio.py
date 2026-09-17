"""Original deterministic UI chimes; no external samples. Run from any directory."""
from pathlib import Path
import math
import struct
import wave

OUT = Path(__file__).resolve().parents[1] / "assets" / "audio"
RATE = 22050

def chime(name, notes):
    duration = max(start + length for start, frequency, length in notes)
    samples = []
    for i in range(int(duration * RATE)):
        time = i / RATE
        value = 0.0
        for start, frequency, length in notes:
            t = time - start
            if 0 <= t < length:
                envelope = min(1.0, t / 0.008) * math.exp(-7 * t / length)
                envelope *= min(1.0, (length - t) / 0.02)
                value += 0.22 * envelope * (math.sin(math.tau * frequency * t) + 0.18 * math.sin(math.tau * frequency * 2 * t))
        samples.append(struct.pack('<h', round(max(-1, min(1, value)) * 32767)))
    OUT.mkdir(parents=True, exist_ok=True)
    with wave.open(str(OUT / (name + '.wav')), 'wb') as stream:
        stream.setparams((1, 2, RATE, 0, 'NONE', 'not compressed'))
        stream.writeframes(b''.join(samples))

chime('build', [(0, 440, .22), (.07, 660, .32)])
chime('upgrade', [(0, 523.25, .22), (.09, 659.25, .25), (.18, 783.99, .4)])
chime('objective', [(0, 523.25, .4), (.13, 659.25, .4), (.26, 783.99, .6), (.39, 1046.5, .65)])
