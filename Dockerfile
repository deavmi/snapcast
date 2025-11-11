FROM debian:latest AS base

# TODO: Add disable prompt-on-install
ARG=/

# Modified from doc/build.md instructions
RUN apt install build-essential cmake cmake-format ccache ninja-build -y
RUN apt install alsa-utils avahi-daemon libasound2-dev libavahi-client-dev \ 
		libboost-dev libexpat1-dev libflac-dev libjack-dev libopus-dev libpulse-dev \
		libsoxr-dev libssl-dev libvorbis-dev libvorbisidec-dev -y \
