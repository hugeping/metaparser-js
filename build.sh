export WORKSPACE="/home/peter/Devel/emsdk/env"
. /home/peter/Devel/emsdk/emsdk_env.sh

LIB="$WORKSPACE/lib"
INC="$WORKSPACE/include"

emmake make clean
LDFLAGS=-r emmake make EXTRA_CFLAGS=-I"$INC"\ -Wno-macro-redefined

STEAD_BLACKLIST="dbg.lua dbg-ru.lua ext/gui.lua ext/sandbox.lua ext/sound.lua ext/sprites.lua ext/timer.lua finger.lua keys.lua click.lua CMakeLists.txt"
MP_BLACKLIST="morph/morphs.mrd"

test -d fs || { mkdir fs && cp -R stead fs/ && \
for d in $STEAD_BLACKLIST; do rm fs/stead/stead3/$d; done;\
cp -R metaparser/morph fs/stead/stead3/ && cp -R metaparser/parser fs/stead/stead3/ && \
for d in $MP_BLACKLIST; do rm fs/stead/stead3/$d; done; }

 # -s BINARYEN_TRAP_MODE=clamp
emcc -O2 metaparser.bc $LIB/liblua.a $LIB/libz.a \
-lidbfs.js \
-s EXPORTED_FUNCTIONS="['_parser_start','_parser_stop','_parser_cmd','_parser_restart', '_parser_autoload', '_parser_autosave', '_parser_load', '_parser_save', '_parser_path', '_parser_clear', '_parser_savename']" \
-s 'EXTRA_EXPORTED_RUNTIME_METHODS=["ccall", "cwrap", "Pointer_stringify"]' \
-s QUANTUM_SIZE=4 \
-s PRECISE_F32=1 \
-s WASM=1 \
-o metaparser-wasm.html -s SAFE_HEAP=0  -s ALLOW_MEMORY_GROWTH=1 \
--post-js mp-post.js  \
--preload-file fs@/ \
&& \
emcc -O2 metaparser.bc $LIB/liblua.a $LIB/libz.a \
-lidbfs.js \
-s EXPORTED_FUNCTIONS="['_parser_start','_parser_stop','_parser_cmd','_parser_restart', '_parser_autoload', '_parser_autosave', '_parser_load', '_parser_save', '_parser_path', '_parser_clear', '_parser_savename']" \
-s 'EXTRA_EXPORTED_RUNTIME_METHODS=["ccall", "cwrap", "Pointer_stringify"]' \
-s QUANTUM_SIZE=4 \
-s PRECISE_F32=1 \
-s WASM=0 \
-o metaparser-js.html -s SAFE_HEAP=0  -s ALLOW_MEMORY_GROWTH=1 \
--post-js mp-post.js  \
--preload-file fs@/


test -d release || mkdir release
test -d release/lib || mkdir release/lib

cp -f metaparser-wasm.* metaparser-js.* release/ && rm -f release/*.html && cp -f index.html release/
cp -rf lib/* release/lib && cp -f README release/ && cp -f ChangeLog release/

cp -f release/metaparser-wasm.* release/metaparser-js.* site/games/ && cp -f release/index.html site/games && cp -rf release/lib/* site/games/lib/
