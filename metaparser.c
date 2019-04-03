#include <stdio.h>
#include <stdlib.h>
#include "string.h"
#include "instead/instead.h"

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

int parser_start(const char *file)
{
	char path[PATH_MAX];
	need_restart = 0;
	if (instead_extension(&ext)) {
		fprintf(stderr, "Can't register tiny extension\n");
		return -1;
	}
	instead_set_debug(1);
	if (!setup_zip(file))
		snprintf(path, sizeof(path), "%s/%s", GAMES_PATH, zip_game_dirname);
	else
		snprintf(path, sizeof(path), "%s", file);
	if (instead_init(path)) {
		fprintf(stderr, "Can not init game.\n");
		return -1;
	}
	if (instead_load(NULL)) {
		fprintf(stderr, "Can not load game: %s\n", instead_err());
		return -1;
	}
	return 0;
}

static char *buf = NULL;

void parser_stop(void)
{
	instead_done();
	if (buf)
		free(buf);
	zip_game_dirname[0] = 0;
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
