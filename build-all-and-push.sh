if [ -z $USERNAME ]||[ -z $PAT ]];then
if [ -z $USERNAME ];then
echo username not set
fi
if [ -z $PAT ];then
echo PAT not set
fi
exit 2
fi
echo $PAT|docker login -u $USERNAME -p -
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
