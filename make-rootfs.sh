#!/bin/bash
umask 022
if [ -e .env ];then
source .env
fi
if [ -z $jenux_iso_arch ]||[ -z $jenux_iso_livemode ]||[ -z $jenux_iso_preset ]||[ -z $jenux_iso_docker_repo ];then
if [ -z $jenux_iso_arch ];then
echo jenux_iso_arch is not set
else
echo jenux_iso_arch: $jenux_iso_arch
fi
if [ -z $jenux_iso_livemode ];then
echo jenux_iso_livemode is not set
else
echo jenux_iso_livemode: $jenux_iso_livemode
fi
if [ -z $jenux_iso_preset ];then
echo jenux_iso_preset is not set
else
echo jenux_iso_preset: $jenux_iso_preset
fi
if [ -z $jenux_iso_docker_repo ];then
echo jenux_iso_docker_repo is not set
else
echo jenux_iso_docker_repo: $jenux_iso_docker_repo
fi
echo environment error, see .venv.example, all vars must be set.
exit 1
fi
if echo $jenux_iso_arch|grep -qw _detect_;then
export jenux_iso_arch=`uname -m`
fi
export preset=$jenux_iso_preset
export arch=$jenux_iso_arch
if echo $jenux_iso_arch|grep -iqw all;then
unset arch
fi
work_dir=work
script_path=$(readlink -f ${0%/*})
if [ -e /.dockerenv ];then
mount -t devtmpfs /dev /dev
fi
run_once() {
    if [[ ! -e ${work_dir}/build.${1}_${arch} ]]; then
        $1
        touch ${work_dir}/build.${1}_${arch}
    fi
}
make_pacman_conf() {
for d in "${work_dir}/${arch}" "${work_dir}/${arch}/airootfs" "${work_dir}/iso/${install_dir}";do
if [ -d $d ];then
sleep .01
else
mkdir -p $d
fi
done
local _cache_dirs
    _cache_dirs=($(pacman -v 2>&1 | grep '^Cache Dirs:' | sed 's/Cache Dirs:\s*//g'))
    if [ $arch = "aarch64" ];then
    curl -s -Lo ${script_path}/pacman.${arch}.conf https://nashcentral.duckdns.org/autobuildres/pi/pacman.$arch.conf
mkdir -p "${work_dir}/${arch}/airootfs/etc/pacman.d"
export prepkgdir=$PWD
cd "${work_dir}/${arch}/airootfs"
while true;do
export keyringurl=`lynx --dump -listonly -nonumbers os.archlinuxarm.org/$arch/core|grep archlinuxarm-keyring|grep .tar|sed "/.sig/d"|tail -n 1|cut -f 4 -d \  `
if curl -LO $keyringurl;then
break
else
continue
fi
done
while true;do
export mirrorlisturl=`lynx --dump -listonly os.archlinuxarm.org/$arch/core|grep pacman-mirrorlist|grep .tar|sed "/.sig/d"|tail -n 1|cut -f 3 -d \  `
if curl -Lo mirrors.tar $mirrorlisturl;then
break
else
continue
fi
done
pacman --needed --noconfirm -U *.pkg*
tar -xf mirrors.tar etc/pacman.d/mirrorlist
sed -i "s|\# Server|Server|g" etc/pacman.d/mirrorlist
rm *.pkg* mirrors.tar
cd $prepkgdir
else
curl -Lo ${script_path}/pacman.${arch}.conf https://nashcentral.duckdns.org/autobuildres/linux/pacman.${arch}.conf
fi
if [ -e /.dockerenv ];then
cp ${script_path}/pacman.$arch.conf ${work_dir}/pacman.${arch}.conf
else
sed -r "s|^#?\\s*CacheDir.+|CacheDir = $(echo -n ${_cache_dirs[@]})|g" ${script_path}/pacman.$arch.conf > ${work_dir}/pacman.${arch}.conf
fi
if [ $arch = "aarch64" ];then
sed -i "s|Include = \/etc\/pacman.d\/mirrorlist|Include = ${work_dir}\/${arch}\/airootfs\/etc\/pacman.d\/mirrorlist|g" "${work_dir}/pacman.${arch}.conf"
fi
if [ $arch = "i686" ];then
mkdir -p "${work_dir}/${arch}/airootfs/etc/pacman.d"
while true;do
if curl -Lo "${work_dir}/${arch}/airootfs/etc/pacman.d/mirrorlist" https://git.archlinux32.org/packages/plain/core/pacman-mirrorlist/mirrorlist;then
break
else
continue
fi
done
sed -i "s|#Server|Server|g;/mirror.datacenter.by/d;/archlinux32.agoctrl.org/d;/de.mirror.archlinux32.org/d;/\/mirror.archlinux32.org\//d;/mirror.archlinux32.oss/d" "${work_dir}/${arch}/airootfs/etc/pacman.d/mirrorlist"
sed -i "s|Include = \/etc\/pacman.d\/mirrorlist|Include = ${work_dir}\/${arch}\/airootfs\/etc\/pacman.d\/mirrorlist|g" "${work_dir}/pacman.${arch}.conf"
export mirrorurl=`cat ${work_dir}/${arch}/airootfs/etc/pacman.d/mirrorlist|grep -i server|head -n 1|sed "s|\\$arch|$arch|g;s|\\$repo|core|g;s|Server = ||g"`
export keyringurl=`lynx --dump -listonly -nonumbers $mirrorurl|grep archlinux32-keyring|grep .tar|sed "/transition/d;/.sig/d"|tail -n 1|cut -f 4 -d \  `
while true;do
if curl -LO $keyringurl;then
break
else
continue
fi
done
pacman --needed --noconfirm -U *.pkg*
rm *.pkg*
fi
if [ $arch = "x86_64" ];then
mkdir -p "${work_dir}/${arch}/airootfs/etc/pacman.d"
while true;do
if curl -L https://archlinux.org/packages/core/any/pacman-mirrorlist/download/|tar --zstd -C ${work_dir}/${arch}/airootfs -x etc/pacman.d/mirrorlist;then
break
else
continue
fi
done
sed -i "s|#Server|Server|g" "${work_dir}/${arch}/airootfs/etc/pacman.d/mirrorlist"
sed -i "s|Include = \/etc\/pacman.d\/mirrorlist|Include = ${work_dir}\/${arch}\/airootfs\/etc\/pacman.d\/mirrorlist|g" "${work_dir}/pacman.${arch}.conf"
export mirrorurl=`cat ${work_dir}/${arch}/airootfs/etc/pacman.d/mirrorlist|grep -i server|head -n 1|sed "s|\\$arch|$arch|g;s|\\$repo|core|g;s|Server = ||g"`
export keyringurl=`lynx --dump -listonly -nonumbers $mirrorurl|grep archlinux-keyring|grep .tar|sed "/transition/d;/.sig/d"|tail -n 1|cut -f 4 -d \  `
while true;do
if curl -LO $keyringurl;then
break
else
continue
fi
done
pacman --needed --noconfirm -U *.pkg*
rm *.pkg*
fi
mkdir -p ${work_dir}/${arch}/airootfs/var/lib/pacman/
}
make_packages() {
while true;do
curl https://nashcentral.duckdns.org/autobuildres/linux/pkg.${preset}|tr \  \\n|sed "/pacstrap/d;/\/mnt/d;/--overwrite/d;/\\\\\*/d" > packages.${arch}
if cat packages.${arch}|grep -iqw base;then
break
else
continue
fi
done
if [ $arch = "aarch64" ];then
sed -i "/qemu-system-arm/d;/qemu-system-x86/d;/qemu-emulators-full/d" packages.${arch}
fi
if [ $arch = "i686" ];then
sed -i "/qemu-img/d;s|qemu-base|qemu-headless|g" packages.${arch}
fi
if echo $preset|grep -qw base ;then
true
else
for reppkg in "jack2" "virtualbox-guest-utils-nox";do
if pacman --config ${work_dir}/pacman.${arch}.conf -r ${work_dir}/${arch}/airootfs -Q 2>/dev/stdout|grep -iqw $reppkg;then
pacman --noconfirm --config ${work_dir}/pacman.${arch}.conf -r ${work_dir}/${arch}/airootfs -Rdd $reppkg
fi
done
fi
echo -n pacman --config ${work_dir}/pacman.${arch}.conf -r ${work_dir}/${arch}/airootfs -Syyp\   > installtest.${arch}
cat packages.${arch}|tr \\n \  >> installtest.${arch}
chmod 700 installtest.${arch}
for f in `./installtest.${arch} 2>/dev/stdout|grep -i "error: target not found: "|sed "s|error: target not found: ||g"`;do
sed -i "/$f/d" ${script_path}/packages.${arch}
done
rm installtest.${arch}
    if [ $arch = "aarch64" ];then
cat ${script_path}/packages.${arch}|tr \\n \  |sed "s| linux | linux-aarch64 linux-aarch64-headers raspberrypi-bootloader firmware-raspberrypi pi-bluetooth hciattach-rpi3 fbdetect |g;s| linux-headers | |g"|tr \  \\n |sort|uniq > pkg.$arch
mv pkg.$arch ${script_path}/packages.${arch}
fi
export isopkgs=`echo -en base grub lynx curl dosfstools e2fsprogs squashfs-tools arch-install-scripts mkinitcpio-archiso sbsigntools shim-signed git gptfdisk parted unzip dos2unix qemu-img`
if echo $arch|grep -qw x86_64;then
export isopkgs=`echo -en $isopkgs`" qemu-user-static qemu-user-static-binfmt "
fi
if echo $arch|grep -qw i686;then
export isopkgs=`echo -en $isopkgs`" archlinux32-keyring "
fi
if echo $arch|grep -qw aarch64;then
export isopkgs=`echo -en $isopkgs`" archlinuxarm-keyring "
fi
while true;do
if pacstrap -C "${work_dir}/pacman.${arch}.conf" -M -G "${work_dir}/${arch}/airootfs" --needed --overwrite \\* `echo -en $isopkgs`;then
rm -rf "${work_dir}/${arch}/airootfs/var/cache/pacman/pkg/"*
break
else
continue
fi
done
rm ${script_path}/packages.${arch} ${script_path}/pacman.${arch}.conf 
while true;do
curl -Lo "${work_dir}/${arch}/airootfs/etc/pacman.conf" https://nashcentral.duckdns.org/autobuildres/linux/pacman.$arch.conf
if cat "${work_dir}/${arch}/airootfs/etc/pacman.conf" |grep -iqw jenux;then
break
else
continue
fi
done
}
if [ -z $arch ];then
export buildtype=tripple
export prepbuilds=`echo -en x86_64 i686 aarch64`
else
export buildtype=$arch
export prepbuilds=`echo -en $arch`
fi
for arch in `echo -en $prepbuilds`; do
run_once make_pacman_conf
run_once make_packages
case "$arch" in
armv7h)
export dockerplat="--platform linux/arm/v7"
;;
aarch64)
export dockerplat="--platform linux/aarch64"
;;
i686)
export dockerplat="--platform linux/i686"
;;
x86_64)
export dockerplat="--platform linux/amd64"
;;
*)
export dockerplat="--platform linux/"${arch}
;;
esac
rm -rf "${work_dir}/${arch}/airootfs/etc/pacman.d/gnupg"
cat >> dockerfile.`echo -en $dockerplat|sed "s|--platform linux\/||g"|tr / +`<<EOF
FROM scratch
COPY "${work_dir}/${arch}/airootfs/" /
ONBUILD RUN pacman-key --init&&pacman-key --populate
EOF
docker build --tag $jenux_iso_docker_repo":"jenux-${preset}-${arch} $dockerplat . -f dockerfile.`echo -en $dockerplat|sed "s|--platform linux\/||g"|tr / +`
docker push $jenux_iso_docker_repo":"jenux-${preset}-${arch}
docker manifest create $jenux_iso_docker_repo":"jenux-${preset}"-rootfs"  --amend $jenux_iso_docker_repo":"jenux-${preset}-${arch} 
docker manifest push $jenux_iso_docker_repo":"jenux-${preset}"-rootfs"
rm -rf "${work_dir}" dockerfile.`echo -en $dockerplat|sed "s|--platform linux\/||g"|tr / +`
done
