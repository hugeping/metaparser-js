#!/usr/bin/env bash
# build INSTEAD with emscripten

set -e
export WORKSPACE="/home/peter/Devel/emsdk-portable/env"

if [ ! -f ./emsdk_env.sh ]; then
	echo "Run this script in emsdk directory"
	exit 1
fi
if [ -z "$WORKSPACE" ]; then
	echo "Define WORKSPACE path in $0"
	exit 1
fi

if [ ! -d "$WORKSPACE" ]; then
	echo "Please, create build directory $WORKSPACE"
	exit 1
fi
. ./emsdk_env.sh

# some general flags
export CFLAGS="-g0 -O2"
export CXXFLAGS="$CFLAGS"
export EM_CFLAGS="-Wno-warn-absolute-paths"
export EMMCC_CFLAGS="$EM_CFLAGS"
export PKG_CONFIG_PATH="$WORKSPACE/lib/pkgconfig"
export MAKEFLAGS="-j2"

# flags to fake emconfigure and emmake
export CC="emcc"
export CXX="em++"
export LD="$CC"
export LDSHARED="$LD"
export RANLIB="emranlib"
export AR="emar"

# Lua
cd $WORKSPACE
if ! test -r .stamp_lua; then
rm -rf lua-5.1.5
[ -f lua-5.1.5.tar.gz ] || wget -nv 'https://www.lua.org/ftp/lua-5.1.5.tar.gz'
tar xf lua-5.1.5.tar.gz
cd lua-5.1.5
cat src/luaconf.h | sed -e 's/#define LUA_USE_POPEN//g' -e 's/#define LUA_USE_ULONGJMP//g'>src/luaconf.h.new
mv src/luaconf.h.new src/luaconf.h
emmake make posix CC=emcc 
emmake make install INSTALL_TOP=$WORKSPACE 
touch ../.stamp_lua
fi

# zlib
cd $WORKSPACE
if ! test -r .stamp_zlib; then
rm -rf zlib-1.2.12/
[ -f zlib-1.2.12.tar.gz ] || wget -nv 'http://zlib.net/zlib-1.2.12.tar.gz'
tar xf zlib-1.2.12.tar.gz
cd zlib-1.2.12
emconfigure ./configure --prefix=$WORKSPACE
emmake make install
touch ../.stamp_zlib
fi
