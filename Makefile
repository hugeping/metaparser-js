VERSION := 3.5.0

DATAPATH=.
STEADPATH=$(DATAPATH)/stead
GAMESPATH=$(DATAPATH)/games

CFLAGS	+= -O2 -Wall -Dunix -D_USE_UNPACK -D_LOCAL_APPDATA

EXE=
PLATFORM=unix.c
RESOURCES=
RM=rm
AR=ar rc
RANLIB=ranlib

include config.make

CFLAGS += $(LUA_CFLAGS) $(EXTRA_CFLAGS) -DGAMES_PATH=\"${GAMESPATH}/\" -DSTEAD_PATH=\"${STEADPATH}/\" -DVERSION=\"$(VERSION)\" -I ../../../include -O2 -I instead/src/

LDFLAGS += $(LUA_LFLAGS) $(EXTRA_LDFLAGS)

INSTEAD_SRC	:= instead.c util.c list.c cache.c idf.c tinymt32.c lfs.c

SRC     := $(INSTEAD_SRC)
OBJ     := $(patsubst %.c, %.o, $(SRC))

all: metaparser$(EXE) stead

update:
	git submodule update --recursive --remote
	git submodule foreach git checkout master
	git submodule foreach git pull origin master

stead:
	mkdir stead
	cp -f -R instead/stead/stead3 stead/
	cp -f instead/src/tiny/tiny3.lua stead/
	cp -f mp.lua stead/

$(OBJ): %.o : instead/src/instead/%.c
	$(CC) -c $(<) $(I) $(CFLAGS) $(CPPFLAGS) -o $(@)

metaparser$(EXE): metaparser.c unpack.c unzip.c ioapi.c $(OBJ)
	$(CC) $(CFLAGS) $(^) $(LDFLAGS) -o $(@)

clean:
	$(RM) -f *.o metaparser$(EXE)
	$(RM) -rf stead metaparser-wasm.data metaparser-wasm.html metaparser-wasm.js metaparser-wasm.wasm
	$(RM) -rf stead metaparser-js.data metaparser-js.html metaparser-js.html.mem metaparser-js.js
