#!/usr/bin/env lua
local header=[[<!DOCTYPE html>
<html lang="ru">
<head>
	<meta charset="utf-8">
	<title>МЕТАПАРСЕР: интерактивная литература</title>
	<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">
	<link rel="icon" type="image/png" sizes="64x64" href="/favicon.png">
	<link href="css/bootstrap.min.css" rel="stylesheet">
	<link href="css/styles.css" rel="stylesheet">
</head>
<body>
<div class="container">

<div class="row align-items-center headline">

<div class="col-sm-12"><img src="compass-logo.png" class="logo float-left">
<div id="about" class="page-header"><h1>МЕТАПАРСЕР</h1>
<p>Добро пожаловать в библиотеку интерактивной литературы! Здесь представлены
игры с текстовым вводом в минималистичном формате. Ничего лишнего &mdash; только текст и ваше воображение!
Каждую игру вы можете запустить в браузере прямо с сайта.</p>
<p class="small"><i>Если вам нужны инструкции, наберите в игре "помощь". Для загрузки прошлого состояния, наберите "загрузить". Чтобы начать заново, введите "заново".</i></p>
</div>
</div>
</div>
<hr />
]]
local feedback=[[
	<hr/>
	<div class="row">
	<div class="col-sm-12">
	<h2>Контакты</h2>
	<p>Привет! Меня зовут Пётр и я занимаюсь движком <a href="https://instead-hub.github.io">INSTEAD</a> с 2009 года.<br/>
	Если вы хотите добавить свою игру в каталог, сообщите мне об этом на форуме <a href="http://instead-games.ru">instead-games.ru</a> или по почте <a href="mailto:gl00my@mail.ru">gl00my[at]mail.ru</a><br/>
	<br/>Настоящая интерактивная литература в виде игр с текстовым вводом &mdash; сегодня почти забытый жанр.<br/>
	Если вы заинтересованы в существовании проекта, вы можете рассказать о нём друзьям, сделать пожертвование или написать отзыв.<br/>
	<br/>Ваша поддержка помогает двигаться вперёд!</p>
	</div>
	</div>
]]
local donate=[[
<div style="overflow-x: visible" class="donate">
<form action="https://www.paypal.com/cgi-bin/webscr" method="post" target="_top">
<input type="hidden" name="cmd" value="_s-xclick">
<input type="hidden" name="hosted_button_id" value="QJDNRPU8B2FEJ">
<input type="image" src="https://www.paypalobjects.com/ru_RU/RU/i/btn/btn_donateCC_LG.gif" border="0" name="submit" alt="PayPal — более безопасный и легкий способ оплаты через Интернет!">
<img alt="" border="0" src="https://www.paypalobjects.com/ru_RU/i/scr/pixel.gif" width="1" height="1">
</form>
<iframe src="https://money.yandex.ru/quickpay/shop-widget?writer=buyer&targets=&targets-hint=%D0%9D%D0%B0%20%D0%BF%D1%80%D0%BE%D0%B5%D0%BA%D1%82&default-sum=50&button-text=11&payment-type-choice=on&mobile-payment-type-choice=on&hint=&successURL=&quickpay=shop&account=41001612955830" width="450" height="224" frameborder="0" allowtransparency="true" scrolling="no"></iframe>
</div>
]]

local disquss =[[
<div id="disqus_thread"></div>
<script>

/**
*  RECOMMENDED CONFIGURATION VARIABLES: EDIT AND UNCOMMENT THE SECTION BELOW TO INSERT DYNAMIC VALUES FROM YOUR PLATFORM OR CMS.
*  LEARN WHY DEFINING THESE VARIABLES IS IMPORTANT: https://disqus.com/admin/universalcode/#configuration-variables*/
/*
var disqus_config = function () {
this.page.url = PAGE_URL;  // Replace PAGE_URL with your page's canonical URL variable
this.page.identifier = PAGE_IDENTIFIER; // Replace PAGE_IDENTIFIER with your page's unique identifier variable
};
*/
(function() { // DON'T EDIT BELOW THIS LINE
var d = document, s = d.createElement('script');
s.src = 'https://metaparser.disqus.com/embed.js';
s.setAttribute('data-timestamp', +new Date());
(d.head || d.body).appendChild(s);
})();
</script>
<noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
]]

local footer=feedback..donate..disquss..[[
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
</div>]], v.dsc, v.nam)..disquss..[[</div></body></html>]];
	return text
end

local games = {
	"mars", "snowstorm", "summerday", "deadhand",
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
