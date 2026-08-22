#!/bin/bash
if [ -z $DOCKERUSERNAME ]||[ -z $DOCKERPAT ];then
if [ -z $DOCKERUSERNAME ];then
echo DOCKERUSERNAME not set
fi
if [ -z $PAT ];then
echo DOCKERPAT not set
fi
exit 2
fi
echo $DOCKERPAT|docker login -u $DOCKERUSERNAME -p -
rm -rf work
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
docker logout
