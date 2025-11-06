rm -rf work /var/lib/docker/*
systemctl restart docker
for arch in "x86_64" "i686" "aarch64";do
cat > .env<<EOF
jenux_iso_arch=$arch
jenux_iso_preset=base
jenux_iso_livemode=0
jenux_iso_docker_repo=dnlnash/jenuxos
EOF
./make-rootfs.sh
rm .env
done
