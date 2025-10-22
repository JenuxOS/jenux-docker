FROM jenux-base-rootfs
RUN pacman-key --init
RUN pacman-key --populate
CMD ["/bin/zsh"]
