# Use the official Microsoft .NET SDK image as the base image
FROM mcr.microsoft.com/dotnet/sdk:8.0

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
ENV GODOT_VERSION="4.2.1"
ENV GODOT_DOWNLOAD_URL="https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/mono/Godot_v${GODOT_VERSION}-stable_mono_linux_x86_64.zip"
ENV GODOT_TEMPLATES_URL="https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/mono/Godot_v${GODOT_VERSION}-stable_mono_export_templates.tpz"

ENV GODOT_MONO="Godot_v${GODOT_VERSION}-stable_mono_linux"

ENV GODOT_FOLDER="${GODOT_MONO}_x86_64"
ENV GODOT_BIN="${GODOT_MONO}.x86_64"

# Download both Godot versions and export templates
RUN wget ${GODOT_DOWNLOAD_URL} -O godot.zip &&  \
    wget ${GODOT_TEMPLATES_URL} -O templates.tpz

RUN unzip godot.zip
RUN mv ${GODOT_FOLDER} /usr/local/bin/godot
RUN chmod +x /usr/local/bin/godot/${GODOT_BIN}

# Install mono templates
RUN mkdir -p /root/.local/share/godot/templates && \
    unzip templates.tpz -d /root/.local/share/godot/templates

# Clean up
RUN rm godot.zip templates.tpz

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

RUN apt-get install -y --no-install-recommends git

# Set the entrypoint to the script
ENTRYPOINT ["/entrypoint.sh"]
