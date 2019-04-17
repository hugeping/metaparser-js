local std = stead
local iface = std '@iface'
local instead = std '@instead'

local function html_tag(nam)
	return function(s, str)
		if not str then return str end
		return '<'..nam..'>'..str..'</'..nam..'>'
	end
end

iface.center = html_tag('center')
iface.bold = html_tag('b')
iface.em = html_tag('i')
iface.img = function(s, str)
	if str then
--		instead.clear() -- always clear window on pictures
		return '<g:'..str..'>'
	end
end
instead.restart = instead_restart
instead.menu = instead_menu
instead.clear = instead_clear
instead.tiny = true -- minimal version

std.mod_start(function()
	local mp = std.ref '@metaparser'
	if mp then
		mp.msg.CUTSCENE_HELP = "Для продолжения нажмите <ввод> или введите {$fmt em|дальше}."
		mp.msg.CUTSCENE_MORE = "^Для продолжения нажмите <ввод> или введите {$fmt em|дальше}."
		std.rawset(mp, 'clear', function(self)
			self.text = ''
--			instead.clear();
		end)
		std.rawset(mp, 'MetaHelp', function()
	pn("{$fmt b|КАК ИГРАТЬ?}")
	pn([[Вводите ваши действия в виде простых предложений вида: глагол -- существительное. Например:^
> открыть дверь^
> отпереть дверь ключом^
> идти на север^
> взять кепку^
^
Чтобы снова увидеть описание обстановки, введите "осмотреть", "осм" или просто нажмите "ввод".^
^
Чтобы осмотреть предмет, введите "осмотреть книгу" или просто "книга".^
^
Попробуйте "осмотреть себя" и узнать, кто вы.^
^
Чтобы узнать какие предметы у вас с собой, наберите "инвентарь" или "инв".^
^
Для перемещений используйте стороны света, например: "идти на север" или "север" или просто "с".^
Кроме сторон света можно перемещаться вверх ("вверх" или "вв") и вниз ("вниз" или "вн").]])
		end)
	end
end)
