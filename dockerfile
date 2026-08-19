FROM dnlnash/jenuxos:jenux-base-rootfs   
COPY . /build
RUN pacman --needed --noconfirm -Syu docker
WORKDIR /build
RUN sh -c "echo $github.secrets.DOCKERPAT|docker login -u $github.secrets.DOCKERUSERNAME -p -"
RUN ./build-all-and-push.sh
