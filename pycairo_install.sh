#!/bin/bash
which python && \
mkdir -p /tmp/gt/ && \
wget -O /tmp/gt/pycairo.tar.bz2 https://www.cairographics.org/releases/pycairo-1.10.0.tar.bz2 && \
cd /tmp/gt/ && tar jxf /tmp/gt/pycairo.tar.bz2 && cd pycairo* && \
wget http://www.linuxfromscratch.org/patches/blfs/svn/pycairo-1.10.0-waf_unpack-1.patch && \
wget http://www.linuxfromscratch.org/patches/blfs/svn/pycairo-1.10.0-waf_python_3_4-1.patch && \
patch -Np1 -i ./pycairo-1.10.0-waf_unpack-1.patch && \
wafdir=$(./waf unpack)  && \
pushd $wafdir          && \
patch -Np1 -i ../pycairo-1.10.0-waf_python_3_4-1.patch && \
popd                   && \
unset wafdir           && \
./waf --help && ./waf configure && ./waf build && ./waf install
