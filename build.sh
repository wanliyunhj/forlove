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

cp -rf bin output
cp -rf tools/supervise.forlove output/bin
mkdir -p output/conf
cp -rf conf output
mkdir -p output/log
cp tools/control.sh output

