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

instead.restart = instead_restart
instead.menu = instead_menu
