#!/usr/bin/env bash
set -o errexit
set -o nounset
cd "$(dirname $0)"/../..

#
# Build and install xa65. When this stops working, check
# https://www.floodgap.com/retrotech/xa/dists/ for a newer version.
#

XA_VERSION=2.3.12

if [ ! -e /usr/local/bin/xa65.exe ]
then
    pushd /usr/local
    mkdir -p src
    cd src
    wget https://www.floodgap.com/retrotech/xa/dists/xa-${XA_VERSION}.tar.gz
    tar -xzf xa-${XA_VERSION}.tar.gz
    cd xa-${XA_VERSION}
    make mingw install
    cp /usr/local/bin/xa.exe /usr/local/bin/xa65.exe
    popd
fi

ARGS="
    --disable-arch \
    --disable-pdf-docs \
    --with-jpeg \
    --with-png \
    --with-gif \
    --with-vorbis \
    --with-flac \
    --enable-ethernet \
    --enable-lame \
    --enable-midi \
    --enable-cpuhistory \
    --enable-external-ffmpeg \
 	--enable-platformdox \
 	--enable-html-docs \
	--enable-native-tools \
	--enable-rs232 \
	--enable-new8580filter \
	--with-fast-sid \
	--with-resid \
	--enable-quicktime \
	--enable-libx264 \
	--enable-x64 \
	--enable-x64-image \
	--enable-realdevice \
    "

case "$1" in
GTK3)
    ARGS="--enable-native-gtk3ui $ARGS"
    ;;

SDL2)
    ARGS="--enable-sdlui2 $ARGS"
    ;;

*)
    echo "Bad UI: $1"
    exit 1
    ;;
esac

echo WE ARE IN DIRECTORY: $PWD
./autogen.sh
sed -i "s/O3/Ofast/g" configure.ac
sed -i "s,Emulates an 8-bit Commodore computer.,Zibri Build,g" src/arch/gtk3/uiabout.c
sed -i "s,GTK_LICENSE_GPL_2_0,GTK_LICENSE_UNKNOWN," src/arch/gtk3/uiabout.c
##### sed -i "s,http://vice-emu.sourceforge.net/,\\\n\\\n         https://git.io/JCLMo\\\n\\\nhttp://vice-emu.sourceforge.net/," src/arch/gtk3/uiabout.c
./configure $ARGS || ( echo -e "\n**** CONFIGURE FAILED ****\n" ; cat config.log ; exit 1 )
make -j 8 -s
make bindist7zip
