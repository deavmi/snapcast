FROM debian:latest AS build

# TODO: Add disable prompt-on-install
# ARG=/

RUN apt update

# Modified from doc/build.md instructions
RUN apt install build-essential cmake cmake-format ccache ninja-build -y
RUN apt install alsa-utils avahi-daemon libasound2-dev libavahi-client-dev \ 
		libboost-dev libexpat1-dev libflac-dev libjack-dev libopus-dev libpulse-dev \
		libsoxr-dev libssl-dev libvorbis-dev libvorbisidec-dev -y 
	
# Copy source across
WORKDIR /tmp
RUN mkdir src
COPY . src/

# Build
WORKDIR src/
RUN mkdir build
WORKDIR build
# TODO: Allow parsing build args here

ARG CMAKE_BUILD_PARALLEL_LEVEL=4 # TODO: Expose

# Enable PipeWire support (FIXME: Enable by default)
ARG COMP_WITH_PIPEWIRE=OFF

# SHELL if [ $COMP_WITH_PIPEWIRE = "ON" ] \
# then \
	# apt install pipewire -y \
# fi \

# RUN cmake .. -DBUILD_WITH_PIPEWIRE=$COMP_WITH_PIPEWIRE

RUN apt install libpipewire-0.3-dev -y
RUN apt install pipewire -y

RUN cmake .. -DBUILD_WITH_PIPEWIRE=ON
RUN cmake --build .


# Binaries are in ../bin
WORKDIR ../bin
# TODO: Copy somewhere
RUN mkdir /bins
RUN cp * /bins

FROM debian:latest AS base

COPY --from=build /bins/* /bin

# Install runtime shard objects
RUN apt update
RUN apt install alsa-utils avahi-daemon libasound2-dev libavahi-client-dev \ 
		libboost-dev libexpat1-dev libflac-dev libjack-dev libopus-dev libpulse-dev \
		libsoxr-dev libssl-dev libvorbis-dev libvorbisidec-dev -y 

RUN apt install libpipewire-0.3-dev -y

CMD ["/bin/snapserver"]
