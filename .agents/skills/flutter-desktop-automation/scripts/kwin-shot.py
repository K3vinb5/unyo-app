#!/usr/bin/env python3
# Capture a specific KWin window by handle WITHOUT changing focus (Wayland-safe).
# Usage: kwin-shot.py <window-handle> <output.png>
# Handle from: kdotool search --name "<title regex>"
# Requires: python3-dbus, ImageMagick (magick; adjust if IM6 convert).
import dbus, os, subprocess, sys

handle, out = sys.argv[1], sys.argv[2]
bus = dbus.SessionBus()
iface = dbus.Interface(bus.get_object("org.kde.KWin", "/org/kde/KWin/ScreenShot2"), "org.kde.KWin.ScreenShot2")
r, w = os.pipe()
res = iface.CaptureWindow(handle, {}, dbus.types.UnixFd(w))
os.close(w)
data = b""
while True:
    chunk = os.read(r, 65536)
    if not chunk:
        break
    data += chunk
os.close(r)
width, height = int(res["width"]), int(res["height"])
# KWin delivers raw QImage::Format_RGBX8888; capture includes ~45px shadow margins.
subprocess.run(
    ["magick", "-size", f"{width}x{height}", "-depth", "8", "rgba:-", "-alpha", "off", out],
    input=data, check=True,
)
print(f"saved {out} ({width}x{height})")
