#! /bin/sh
if [ $# -ge 1 ];then
	part=$1
else
	part=all
fi

rm -rf output
rm -rf bin
make $part -j 4

mkdir -p output
mkdir -p bin
mkdir -p output/thirdlibs

platform=$(uname -s)
macos=Darwin

if [ "$platform" == "$macos" ]; then
    cp -rf thirdlibs/macos/* output/thirdlibs
else
    cp -rf thirdlibs/linux/* output/thirdlibs
fi

cp -rf bin output
cp -rf tools/supervise.forlove output/bin
mkdir -p output/conf
cp -rf conf output
mkdir -p output/log
cp tools/control.sh output
