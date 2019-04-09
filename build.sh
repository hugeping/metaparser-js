export WORKSPACE="/home/peter/Devel/emsdk-portable/env"
. /home/peter/Devel/emsdk-portable/emsdk_env.sh

LIB="$WORKSPACE/lib"
INC="$WORKSPACE/include"
emmake make clean
emmake make EXTRA_CFLAGS=-I"$INC"

test -d fs || { mkdir fs && cp -R stead fs/ && for d in dbg.lua dbg-ru.lua ext/gui.lua ext/sandbox.lua ext/sound.lua ext/sprites.lua ext/timer.lua finger.lua keys.lua click.lua CMakeLists.txt; do rm fs/stead/stead3/$d; done;  }

emcc -O2 metaparser.bc $LIB/liblua.a $LIB/libz.a \
-s EXPORTED_FUNCTIONS="['_parser_start','_parser_stop','_parser_cmd','_parser_restart', '_parser_autoload', '_parser_load', '_parser_path', '_parser_clear']" \
-s 'EXTRA_EXPORTED_RUNTIME_METHODS=["ccall", "cwrap", "Pointer_stringify"]' \
-s QUANTUM_SIZE=4 \
-s BINARYEN_TRAP_MODE=clamp \
-s PRECISE_F32=1 \
-s WASM=1 \
-o metaparser-wasm.html -s SAFE_HEAP=0  -s ALLOW_MEMORY_GROWTH=1 \
--post-js mp-post.js  \
--preload-file fs@/

emcc -O2 metaparser.bc $LIB/liblua.a $LIB/libz.a \
-s EXPORTED_FUNCTIONS="['_parser_start','_parser_stop','_parser_cmd','_parser_restart', '_parser_autoload', '_parser_load', '_parser_path', '_parser_clear']" \
-s 'EXTRA_EXPORTED_RUNTIME_METHODS=["ccall", "cwrap", "Pointer_stringify"]' \
-s QUANTUM_SIZE=4 \
-s BINARYEN_TRAP_MODE=clamp \
-s PRECISE_F32=1 \
-s WASM=0 \
-o metaparser-js.html -s SAFE_HEAP=0  -s ALLOW_MEMORY_GROWTH=1 \
--post-js mp-post.js  \
--preload-file fs@/

cp -f metaparser-wasm.* metaparser-js.* site/games/ && rm -f site/games/*.html && cp -f index.html site/games
cp -rf lib/* site/games/lib/
#echo "Happy hacking"
#python2.7 -m SimpleHTTPServer 8000
