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
static char game_path[PATH_MAX];

static int need_restart = 0;
static int need_load = 0;
static int need_save = 0;
static int need_clear = 0;

static void parser_autosave();

static int luaB_menu(lua_State *L) {
	const char *menu = luaL_optstring(L, 1, NULL);
	if (!menu)
		return 0;
	need_save = !strcmp(menu, "save");
	need_load = !strcmp(menu, "load");
	return 0;
}

static int luaB_restart(lua_State *L) {
	need_restart = !lua_isboolean(L, 1) || lua_toboolean(L, 1);
	return 0;
}

static int luaB_clear(lua_State *L) {
	need_clear = 1;
	return 0;
}

static int luaB_js_script(lua_State *L) {
	const char *scr = luaL_optstring(L, 1, NULL);
	if (scr)
		emscripten_run_script(scr);
	return 0;
}

static const luaL_Reg tiny_funcs[] = {
	{ "instead_restart", luaB_restart },
	{ "instead_menu", luaB_menu },
	{ "instead_clear", luaB_clear },
	{ "instead_js", luaB_js_script },
	{ NULL, NULL }
};

static int tiny_init(void)
{
	int rc;
	instead_api_register(tiny_funcs);
	rc = instead_loadfile("stead/tiny3.lua");
	if (rc)
		return rc;
	rc = instead_loadfile("stead/mp.lua");
	if (rc)
		return rc;
	return 0;
}

static struct instead_ext ext = {
	.init = tiny_init,
};

extern int unpack(const char *zipfilename, const char *where);

extern char zip_game_dirname[];

static int setup_zip(const char *file)
{
	if (zip_game_dirname[0]) /* already unpacked */
		return 0;
	fprintf(stderr,"Trying to install: %s\n", file);
	if (unpack(file, GAMES_PATH)) {
		return -1;
	}
	fprintf(stderr, "Unpacked game: %s\n", zip_game_dirname);
	return 0;
}

char *parser_cmd(char *cmd);

#ifdef __EMSCRIPTEN__
void data_sync(void)
{
	EM_ASM(FS.syncfs(function(error) {
		if (error) {
			console.log("Error while syncing:", error);
		} else {
			console.log("Save synced");
		}
	}););
}
static const char *em_beforeunload(int eventType, const void *reserved, void *userData)
{
//	parser_autosave();
	return NULL;
}
#endif

static void parser_autosave()
{
	char *p;
	char path[PATH_MAX];
	if (!game[0])
		return;
	mkdir("/appdata/saves/", S_IRWXU);
	snprintf(path, sizeof(path), "/appdata/saves/%s", game);
	mkdir(path, S_IRWXU);
	snprintf(path, sizeof(path), "save /appdata/saves/%s/autosave", game);
	p = instead_cmd(path, NULL);
	if (p)
		free(p);
#ifdef __EMSCRIPTEN__
	data_sync();
#endif
}

char *parser_autoload()
{
	char *p;
	char path[PATH_MAX];
	if (!game[0])
		return NULL;
	snprintf(path, sizeof(path), "/appdata/saves/%s/autosave", game);
	if (access(path, R_OK))
		return parser_cmd("look");
	snprintf(path, sizeof(path), "load /appdata/saves/%s/autosave", game);
	p = parser_cmd(path);
	if (p)
		return p;
	return parser_cmd("look");
}

int parser_start(const char *file)
{
	need_restart = need_load = need_save = need_clear = 0;
	if (instead_extension(&ext)) {
		fprintf(stderr, "Can't register tiny extension\n");
		return -1;
	}
	instead_set_debug(0);
	if (!setup_zip(file))
		snprintf(game_path, sizeof(game_path), "%s/%s", GAMES_PATH, zip_game_dirname);
	else
		snprintf(game_path, sizeof(game_path), "%s", file);

	snprintf(game, sizeof(game), "%s", basename(game_path));

	if (instead_init(game_path)) {
		fprintf(stderr, "Can not init game.\n");
		return -1;
	}
	if (instead_load(NULL)) {
		fprintf(stderr, "Can not load game: %s\n", instead_err());
		return -1;
	}
#ifdef __EMSCRIPTEN__
	emscripten_set_beforeunload_callback(NULL, em_beforeunload);
#endif
	return 0;
}

static char *buf = NULL;

void parser_stop(void)
{
	instead_done();
	if (buf)
		free(buf);
	buf = NULL;
	game[0] = 0;
}

char *parser_cmd(char *cmd)
{
	char *ret = instead_cmd(cmd, NULL);
	if (buf)
		free(buf);
	if (need_save) {
		if (ret)
			free(ret);
		ret = strdup("<i>Игра сохранена.</i>");
		parser_autosave();
	}
	buf = ret;
	need_save = 0;
	return ret;
}

int parser_restart(void)
{
	return need_restart;
}

int parser_load(void)
{
	return need_load;
}

int parser_clear(void)
{
	int ov = need_clear;
	need_clear = 0;
	return ov;
}

char *parser_path(void)
{
	return game_path;
}
