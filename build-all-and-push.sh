rm -rf work /var/lib/docker/*
systemctl restart docker
for arch in "x86_64" "i686" "aarch64";do
echo jenux_iso_arch=$arch\\njenux_iso_preset=base\\njenux_iso_livemode=0\\njenux_iso_docker_repo=dnlnash/jenuxos >.env
./make-rootfs.sh
rm .env
done
