#!/bin/bash

export MONO_PATH=/usr/share/dotnet/sdk/8*/ref:.

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
    "/usr/local/bin/godot/$GODOT_BIN" --path /godotapp/project.godot
else
    # Start Godot headless
    "/usr/local/bin/godot/$GODOT_BIN" --path /godotapp/project.godot --display-driver headless
fi
