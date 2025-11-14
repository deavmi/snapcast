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

ARG CMAKE_BUILD_PARALLEL_LEVEL=1 # TODO: Expose

# Enable PipeWire support
ARG COMP_WITH_PIPEWIRE=ON

RUN cmake .. -DBUILD_WITH_PIPEWIRE=$COMP_WITH_PIPEWIRE
RUN cmake --build .


# Binaries are in ../bin
WORKDIR ../bin
# TODO: Copy somewhere
RUN mkdir /bins
RUN cp * /bins

FROM debian:latest AS base

COPY --from=build /bins/* /bin

CMD ["/bin/snapserver"]
