echo "Happy hacking"
export WORKSPACE="/home/peter/Devel/emsdk-portable/env"
. /home/peter/Devel/emsdk-portable/emsdk_env.sh
LIB="$WORKSPACE/lib"
INC="$WORKSPACE/include"
emmake make clean
emmake make EXTRA_CFLAGS=-I"$INC"
test -d fs || { mkdir fs && cp -R stead fs/;  }

emcc -O2 metaparser.bc $LIB/liblua.a $LIB/libz.a \
-s EXPORTED_FUNCTIONS="['_parser_start','_parser_stop','_parser_cmd','_parser_restart']" \
-s 'EXTRA_EXPORTED_RUNTIME_METHODS=["ccall", "cwrap", "Pointer_stringify"]' \
-s QUANTUM_SIZE=4 \
-s BINARYEN_TRAP_MODE=clamp \
-s PRECISE_F32=1 \
-s WASM=1 \
-o metaparser.html -s SAFE_HEAP=0  -s TOTAL_MEMORY=201326592 -s ALLOW_MEMORY_GROWTH=1 \
--post-js mp-post.js  \
--preload-file fs@/

echo "Happy hacking"
python2.7 -m SimpleHTTPServer 8000
