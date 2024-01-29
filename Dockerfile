# Use Alpine Linux as the base image
FROM alpine:latest

# Environment variables
ENV GODOT_VERSION "3.2.3"
# Change this to a strong password
ENV VNC_PASSWORD "your_password" 
ENV DISPLAY ":1"
ENV SCREEN_GEOMETRY "1280x720x24"
# Your Git repository URL
ENV HTTPS_GIT_REPO "" 

# Update the package list and install dependencies
RUN apk update
RUN apk add --no-cache bash wget git x11vnc xvfb unzip
# Dependency for Godot
RUN apk add --no-cache libstdc++ 

# Install glibc compatibility for Alpine (required by Godot)
RUN wget https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.31-r0/glibc-2.31-r0.apk
RUN apk add --allow-untrusted --force-overwrite glibc-2.31-r0.apk

# Download and install Godot
RUN wget https://downloads.tuxfamily.org/godotengine/${GODOT_VERSION}/Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && unzip Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip \
    && mv Godot_v${GODOT_VERSION}-stable_linux_headless.64 /usr/local/bin/godot \
    && rm -f Godot_v${GODOT_VERSION}-stable_linux_headless.64.zip

# Set up VNC server
RUN x11vnc -storepasswd $VNC_PASSWORD /etc/vncsecret
RUN chmod 444 /etc/vncsecret

# Make directory for the Godot project
RUN mkdir /godotapp

# Clone the project from the Git repository
RUN if [ -n "$HTTPS_GIT_REPO" ]; then git clone ${HTTPS_GIT_REPO} /godotapp; fi

# Copy the entrypoint script into the container
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Expose VNC server port
EXPOSE 5900

# Set the entrypoint script
ENTRYPOINT ["/entrypoint.sh"]