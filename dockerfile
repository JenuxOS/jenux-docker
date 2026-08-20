FROM dnlnash/jenuxos:jenux-base-rootfs   
COPY . /build
RUN pacman --needed --noconfirm -Syu docker
WORKDIR /build
ENTRYPOINT ./build-all-and-push.sh
