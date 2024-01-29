#!/bin/sh

# Set the VNC password
mkdir -p ~/.vnc
x11vnc -storepasswd $VNC_PASSWORD ~/.vnc/passwd

# Start the virtual frame buffer
Xvfb $DISPLAY -screen 0 $SCREEN_GEOMETRY &

# Start the VNC server
x11vnc -display $DISPLAY -xkb -noxrecord -noxfixes -noxdamage -forever -rfbauth ~/.vnc/passwd &

# Start Godot
/usr/local/bin/godot --path /godotapp --editor
