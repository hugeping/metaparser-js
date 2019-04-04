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
		return '<g:'..str..'>'
	end
end
instead.restart = instead_restart
instead.menu = instead_menu

std.mod_start(function()
	local mp = std.ref '@metaparser'
	if mp then
		std.rawset(mp, 'clear', function(self)
			self.text = ''
--			instead_clear();
		end)
	end
end)
