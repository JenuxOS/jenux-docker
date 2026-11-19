#!/bin/bash
if [ -z $DOCKERUSERNAME ]||[ -z $DOCKERPAT ];then
if [ -z $DOCKERUSERNAME ];then
echo DOCKERUSERNAME not set
fi
if [ -z $DOCKERPAT ];then
echo DOCKERPAT not set
fi
exit 2
fi
mv /etc/pacman.d/hooks /etc/pacman.d/hooks.prejenuxiso
cp /etc/pacman.conf /etc/pacman.conf.prejenuxiso
curl -sLo /etc/pacman.conf $baseurl/autobuildres/linux/pacman.$arch.conf
pacman -Sy
echo $DOCKERPAT|docker login -u $DOCKERUSERNAME -p -
rm -rf work
for arch in "x86_64" "i686" "aarch64";do
cat > .env<<EOF
jenux_iso_arch=$arch
jenux_iso_preset=base
jenux_iso_livemode=0
jenux_iso_docker_repo=dnlnash/jenuxos
baseurl=$baseurl
EOF
./make-rootfs.sh
rm .env
done
docker logout
if [ -e /etc/pacman.conf.prejenuxiso ];then
mv /etc/pacman.conf.prejenuxiso /etc/pacman.conf
fi 
if [ -e /etc/pacman.d/hooks.prejenuxiso ];then
mv /etc/pacman.d/hooks.prejenuxiso /etc/pacman.d/hooks
fi
