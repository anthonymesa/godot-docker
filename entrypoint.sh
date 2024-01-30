#!/bin/bash

export MONO_PATH=/usr/lib/mono/4.0:/usr/lib/mono/4.5:.

# Check if the EDITOR environment variable is set to a non-empty value
if [[ -n "$EDITOR" ]]; then
    # Set the VNC password
    mkdir -p ~/.vnc
    x11vnc -storepasswd "$VNC_PASSWORD" ~/.vnc/passwd

    # Start the virtual frame buffer
    Xvfb "$DISPLAY" -screen 0 "$SCREEN_GEOMETRY" &

    # Start the VNC server
    x11vnc -display "$DISPLAY" -xkb -noxrecord -noxfixes -noxdamage -forever -rfbauth /root/.vnc/passwd &

    # Wait for Xvfb to start
    sleep 5

    # Start the Godot editor
    /usr/local/bin/godot/godot_editor --path /godotapp/project.godot --editor
else
    # Start Godot headless
    /usr/local/bin/godot/godot --path /godotapp/project.godot --editor 
fi
