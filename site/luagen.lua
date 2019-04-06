#!/usr/bin/env lua
local header=[[<!DOCTYPE html>
<html lang="ru">
<head>
	<meta charset="utf-8">
	<title>МЕТАПАРСЕР: интерактивная литература</title>
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<link href="css/bootstrap.min.css" rel="stylesheet">
	<link href="css/styles.css" rel="stylesheet">
</head>
<body>
<div class="container">

<div class="row align-items-center headline">

<div class="col-sm-12"><img src="compass-logo.png" class="logo float-left">
<div id="about" class="page-header"><h1>МЕТАПАРСЕР</h1>
<p>Добро пожаловать в библиотеку интерактивной литературы! Здесь представлены
игры в минималистичном оформлении. Только текст и ваше воображение! Ничего лишнего!
Каждую игру вы можете запустить в браузере прямо с сайта. Если вам нужны инструкции, наберите в игре "помощь".</p>
</div>
</div>
</div>
<hr />
]]



local footer=[[
</div> <!-- container -->
</body>
</html>
]]

function gen_game(v)
	local text = string.format([[<html><head>
  <title>Текстовая игра «%s»</title>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <meta name="description" content="Описание игры %s.">
  <link rel="stylesheet" href="/games/style.css" type="text/css" media="all">
</head>

<body>

<div class="container">

<div class="coverimage">
  <span><img src=%q border="0"></span>
</div>

<div class="introduction">
  <h1>
    <span>%s</span>
  </h1>
  <h2>
    <span>%s</span>
  </h2>
  <div class="bibliography">
    <span>%s</span>
  </div>
</div>

<div class="links">
  <ul>
    <li><a href="../index.html?%s">Играть онлайн</a></li>
    <br />]], v.nam, v.nam, v.pic, v.nam, v.info, v.author, v.dir .. '/'.. v.data)
	for k, l in ipairs(v.links or {}) do
		text = text .. string.format([[<li><a href=%q>%s</a></li>]], l[2], l[1])
	end
	text = text .. string.format([[
  </ul>
</div>

<div class="about">
  <span><p class="dsc">%s
</p></span>
</div>

<div class="playinfo">
  <p><i>%s</i> — это текстовая игра, созданная с помощью модуля <a href="https://instead-hub.github.io/page/metaparser/">МЕТАПАРСЕР-3</a> для движка <a href="https://instead-hub.github.io">INSTEAD</a>.
Здесь вы можете поиграть в адаптированную версию игры в режиме онлайн.
Полные версии этой и других игр вы найдёте на <a href="http://instead-games.ru">instead-games.ru</a>.
  </p>
</div>

</div>]], v.dsc, v.nam);
	return text
end

local games = {
	"mars", "snowstorm"
}
local g = {}
for _, v in ipairs(games) do
	local path = "games/"..v
	local t = dofile(path.."/info.lua")
	t.dir = v
	table.insert(g, t)
	local f = io.open(path.."/index.html", "w")
	f:write(gen_game(t))
	f:close()
end
games = g

local GRID = 3
function gen()
	print(header)
	for k, v in ipairs(games) do
		local y = (k - 1) % GRID
		if y == 0 then
			print([[<div class="row">]])
		end
		print([[<div class="col-sm-4">]])
		print([[<div class="thumbnail">]])

		print([[<p class="text-center">]]);
		print(string.format([[<a href=%q><img class="img-rounded" src=%q" alt="" width="128px"></a>]],
			"games/"..v.dir.."/index.html", 'games/'..v.dir .. '/'..v.pic));
		print([[</p>]]);
		print([[<div class="caption">]])
		print(string.format([[<h4 class="text-center"><a href=%q>%s</a></h4><p class="dsc">%s
<i>Автор: %s</i></p>]],
			"games/"..v.dir.."/index.html", v.nam, v.info, v.author));
		print([[</div>]])

		print([[</div>]])
		print([[</div>]])
		if y == GRID - 1 or k == #games then
			print([[</div> <!-- row -->]])
		end
	end
	print(footer)
end


gen()
