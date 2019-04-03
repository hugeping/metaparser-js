#include <stdio.h>
#include <stdlib.h>
#include "string.h"
#include "instead/instead.h"
#include <libgen.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <unistd.h>

#ifdef __EMSCRIPTEN__
#include "emscripten.h"
#include "emscripten/html5.h"
#endif

static char game[256];

static int need_restart = 0;

static int luaB_restart(lua_State *L) {
	need_restart = !lua_isboolean(L, 1) || lua_toboolean(L, 1);
	return 0;
}

static const luaL_Reg tiny_funcs[] = {
	{ "instead_restart", luaB_restart },
	{NULL, NULL}
};

static int tiny_init(void)
{
	int rc;
	rc = instead_loadfile("stead/tiny3.lua");
	if (rc)
		return rc;
	instead_api_register(tiny_funcs);
	return 0;
}

static struct instead_ext ext = {
	.init = tiny_init,
};

extern int unpack(const char *zipfilename, const char *where);

extern char zip_game_dirname[];

static int setup_zip(const char *file)
{
	fprintf(stderr,"Trying to install: %s\n", file);
	if (unpack(file, GAMES_PATH)) {
		return -1;
	}
	fprintf(stderr, "Unpacked game: %s\n", zip_game_dirname);
	return 0;
}

char *parser_cmd(char *cmd);

static char *parser_autoload()
{
	char *p;
	char path[PATH_MAX];
	if (!game[0])
		return NULL;
	snprintf(path, sizeof(path), "/appdata/saves/%s/autosave", game);
	if (access(path, R_OK))
		return parser_cmd("look");
	snprintf(path, sizeof(path), "load %s/autosave", path);
	p = parser_cmd(path);
	if (p)
		return p;
	return parser_cmd("look");
}

#ifdef __EMSCRIPTEN__
void data_sync(void)
{
	EM_ASM(FS.syncfs(function(error) {
		if (error) {
			console.log("Error while syncing:", error);
		} else {
			console.log("Config synced");
		}
	}););
}
static const char *em_beforeunload(int eventType, const void *reserved, void *userData)
{
	char path[PATH_MAX];
	char *p;
	if (!game[0])
		return NULL;
	mkdir("/appdata/saves/", S_IRWXU);
	snprintf(path, sizeof(path), "/appdata/saves/%s", game);
	mkdir(path, S_IRWXU);
	snprintf(path, sizeof(path), "save %s/autosave", path);
	p = parser_cmd(path);
	if (p)
		free(p);
	data_sync();
	return NULL;
}
#endif

char *parser_start(const char *file)
{
	char path[PATH_MAX];
	need_restart = 0;
	if (instead_extension(&ext)) {
		fprintf(stderr, "Can't register tiny extension\n");
		return NULL;
	}
	instead_set_debug(1);
	if (!setup_zip(file))
		snprintf(path, sizeof(path), "%s/%s", GAMES_PATH, zip_game_dirname);
	else
		snprintf(path, sizeof(path), "%s", file);

	snprintf(game, sizeof(game), "%s", basename(path));

	if (instead_init(path)) {
		fprintf(stderr, "Can not init game.\n");
		return NULL;
	}
	if (instead_load(NULL)) {
		fprintf(stderr, "Can not load game: %s\n", instead_err());
		return NULL;
	}
#ifdef __EMSCRIPTEN__
	emscripten_set_beforeunload_callback(NULL, em_beforeunload);
#endif
	return parser_autoload();
}

static char *buf = NULL;

void parser_stop(void)
{
	instead_done();
	if (buf)
		free(buf);
	zip_game_dirname[0] = 0;
	game[0] = 0;
}

char *parser_cmd(char *cmd)
{
	int rc;
	char *ret = instead_cmd(cmd, &rc);
	if (buf)
		free(buf);
	buf = ret;
	return ret;
}

int parser_restart(void)
{
	return need_restart;
}

int main(int argc, char **argv)
{
	parser_start(argv[1]);
}
