FROM dnlnash/jenuxos:jenux-base-rootfs
COPY . /build
RUN pacman --needed --noconfirm -Syu docker qemu-user-static qemu-user-static-binfmt
WORKDIR /build
ENTRYPOINT ["./build-all-and-push.sh"]
