#!/usr/bin/env python3
"""Tail a file, prefix each arriving line with a wall-clock HH:MM:SS.mmm stamp.

Usage: ts-tail.py <file> <out>   (waits for <file> to exist; Ctrl-C to stop)
Arrival stamps are ~flush latency, good to a few ms for line-oriented logs.
"""
import sys, time, os

src, out = sys.argv[1], sys.argv[2]
while not os.path.exists(src):
    time.sleep(0.05)
with open(src, "rb") as f, open(out, "a", buffering=1) as o:
    o.write(f"# ts-tail start {time.strftime('%H:%M:%S')} src={src}\n")
    while True:
        line = f.readline()
        if not line:
            time.sleep(0.01)
            continue
        stamp = time.strftime("%H:%M:%S") + (".%03d" % (int(time.time() * 1000) % 1000))
        text = line.decode("utf-8", "replace").rstrip("\n")
        o.write(f"{stamp}\t{text}\n")
