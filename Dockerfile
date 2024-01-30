# Use the official Microsoft .NET SDK image as the base image
FROM mono:latest

# Install dependencies for running Godot with .NET support
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    unzip \
    wget \
    x11vnc \
    xvfb \
    libxcursor1 \
    && rm -rf /var/lib/apt/lists/*

ENV VNC_PASSWORD="your_password"
ENV DISPLAY=:1
ENV SCREEN_GEOMETRY="1280x720x24"

# Set environment variables for Godot and VNC
ENV GODOT_VERSION="3.5.3"
ENV GODOT_EDITOR_DOWNLOAD_URL="https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/mono/Godot_v${GODOT_VERSION}-stable_mono_x11_64.zip"
ENV GODOT_HEADLESS_DOWNLOAD_URL="https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/mono/Godot_v${GODOT_VERSION}-stable_mono_linux_headless_64.zip"
ENV GODOT_TEMPLATES_URL="https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/mono/Godot_v${GODOT_VERSION}-stable_mono_export_templates.tpz"

ENV GODOT_MONO="Godot_v${GODOT_VERSION}-stable_mono"

ENV GODOT_HEADLESS="${GODOT_MONO}_linux_headless"
ENV GODOT_HEADLESS_FOLDER="${GODOT_HEADLESS}_64"
ENV GODOT_HEADLESS_BIN="${GODOT_HEADLESS}.64"

ENV GODOT_EDITOR="${GODOT_MONO}_x11"
ENV GODOT_EDITOR_FOLDER="${GODOT_EDITOR}_64"
ENV GODOT_EDITOR_BIN="${GODOT_EDITOR}.64"

# Download both Godot versions and export templates
RUN wget ${GODOT_HEADLESS_DOWNLOAD_URL} -O godot_headless.zip && \
    wget ${GODOT_EDITOR_DOWNLOAD_URL} -O godot_editor.zip &&  \
    wget ${GODOT_TEMPLATES_URL} -O templates.tpz

RUN mkdir /usr/local/bin/godot

# Install headless
RUN unzip godot_headless.zip && \
    mv ${GODOT_HEADLESS_FOLDER}/${GODOT_HEADLESS_BIN} /usr/local/bin/godot/godot && \
    chmod +x /usr/local/bin/godot/godot

# Install editor
RUN unzip godot_editor.zip && \
    mv ${GODOT_EDITOR_FOLDER}/${GODOT_EDITOR_BIN} /usr/local/bin/godot/godot_editor && \
    chmod +x /usr/local/bin/godot/godot_editor

# Install mono templates
RUN mkdir -p /root/.local/share/godot/templates && \
    unzip templates.tpz -d /root/.local/share/godot/templates

# Move Godot solution files etc to project folder
RUN mv ${GODOT_HEADLESS_FOLDER}/GodotSharp /usr/local/bin/godot/GodotSharp

# Clean up
RUN rm godot_headless.zip godot_editor.zip templates.tpz && \
    rm -r ${GODOT_HEADLESS_FOLDER} && \
    rm -r ${GODOT_EDITOR_FOLDER}

# Set up VNC server
RUN mkdir -p ~/.vnc && \
    x11vnc -storepasswd $VNC_PASSWORD ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

# Set up the entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose VNC server port
EXPOSE 5900

# Make directory for the Godot project
RUN mkdir /godotapp

# Set the entrypoint to the script
ENTRYPOINT ["/entrypoint.sh"]
