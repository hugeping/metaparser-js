var $window = $(window), $doc = $(document), $body, bodylineheight
var Game

$(function()
{
    $body = $('body');
    var elem = $('<span>&nbsp;</span>').appendTo($body);
    bodylineheight = elem.height();
    elem.remove();
});

var selection = window.getSelection ||
    function() { return document.selection ? document.selection.createRange().text : '' };

var Blobs = {};

function matchRe(regexp, string) {
    var isMatching = string.match(regexp);
    if (isMatching) {
	return isMatching[1].trim();
    }
    return '';
}

function basename(path)
{
	var parts = path.split('/');
	return parts[parts.length-1];
}

function gameName()
{
    if (typeof(TextDecoder) == 'undefined') {
	return basename(parser_path());
    }
    var fullpath = parser_path() + '/main3.lua'
    fullpath = fullpath.replace(/^\./, '')
    var fd = FS.open(fullpath, "r")
    var stat = FS.stat(fullpath);
    var len = (stat.size > 192) ? 192:stat.size;
    var buf = new Uint8Array(len);
    FS.read(fd, buf, 0, len, 0);
    var ret = new TextDecoder().decode(buf);
    var nam = matchRe(/--\s*\$Name\(ru\)\s*:\s*([^\$\n]+)/, ret);
    if (nam === '') {
	nam = matchRe(/--\s*\$Name\s*:\s*([^\$\n]+)/, ret);
	if (ret === '') {
	    nam = basename(parser_path());
	}
    }
    FS.close(fd);
    return nam
}

function isAutosave()
{
    var fullpath = parser_path().replace(/^\./, '').replace(/\/games\//, '')
    fullpath = '/appdata/saves/' + fullpath + '/' + parser_savename();
    if (FS.analyzePath(fullpath).exists) {
	return true
    }
    return false
}

function rmAutosave()
{
    var fullpath = parser_path().replace(/^\./, '').replace(/\/games\//, '')
    fullpath = '/appdata/saves/' + fullpath + '/autosave';
    if (FS.analyzePath(fullpath).exists) {
	FS.unlink(fullpath);
    }
}

function dataUrl(path)
{
    var fullpath = parser_path() + '/' + path;
    fullpath = fullpath.trim().replace(/\\/g, '\/').replace(/\/+/g, '\/');
    fullpath = fullpath.replace(/^\./, '')
    if (!Blobs.hasOwnProperty(fullpath)) {
	if (FS.analyzePath(fullpath).exists) {
	    var content = FS.readFile(fullpath);
	    Blobs[fullpath] = URL.createObjectURL(new Blob([content]));
	} else {
	    Blobs[fullpath] = '';
	}

    }
    return Blobs[fullpath];
}

function parseImg(tag, img)
{
    return '<img '+ 'src="' + dataUrl(img) + '">';
}

function parseOutput(str)
{
    str = str.replace(/<g:([^>]+)>/g, parseImg);
    return str;
}

function fmtCommand(command)
{
    return '<div role="heading" aria-level="2">&gt; <b>' + command.trim() + '</b></div>\n'
}

var scrollPages = window.scrollByPages || function( pages )
{
    var height = document.documentElement.clientHeight,
    delta = height - Math.min( height / 10, bodylineheight * 2 );
    scrollBy( 0, delta * pages );
}

function Input(output)
{
    var self = this
    self.input = $('<input>', {
	class: 'TextInput',
	autocapitalize: 'off',
	keydown: function(event)
	{
	    var  keyCode = self.keyCode = event.which, cancel;
	    if (self.mode != 'line') {
		return;
	    }
	    if (keyCode == 38) {
		self.prev_next(1);
		cancel = 1;
	    } else if (keyCode == 40) {
		self.prev_next(-1);
		cancel = 1;
	    } else if (keyCode == 33) {
		scrollPages(-1);
		cancel = 1;
	    } else if (keyCode == 34) {
		scrollPages(1);
		cancel = 1;
	    } else if (keyCode == 13) {
		self.submitLine();
		cancel = 1;
	    }
	    event.stopPropagation();
	    if (cancel) {
		return false;
	    }
	}
    })
    self.output = output
    self.scrollParent = $('html,body')
    self.history = [];
    self.promptline = $('<div>')
    self.prompt = $('<span>').append('\n&gt; ')
    self.promptline.append(self.prompt)
    self.promptline.append(self.input.val(''))

    self.getLine = function()
    {
	this.mode = 'line'
	this.current = 0;
	this.mutable_history = this.history.slice();
	this.mutable_history.unshift('');
	self.input.val('')
	this.promptline.appendTo(this.output.parent());
	var width = this.output.width() - this.prompt.width() * 2;
	this.input.width(width);
	this.scroll();
	this.input.focus();
    }
    self.submitLine = function()
    {
	var command = this.input.val();
	command = command.replace(/&/g, " ").replace(/</g, " ").replace(/>/g, " ");

	if (command != this.history[0] && /\S/.test(command)) {
	    this.history.unshift(command);
	}
	this.mode = 0;
	this.promptline.detach();
	var span = $('<div role="listitem">')
	var ret = parser_cmd('@metaparser "' + command.replace(/"/g, "") + '"'); //'
	if (!ret) {
		ret = parser_cmd(command.replace(/"/g, ""));
	}
	if (parser_restart() == 1) {
	    console.log("Restart game\n.");
	    parser_stop();
	    parser_start(Game);
//	    rmAutosave();
	    ret = parser_cmd("look");
	    this.output.empty();
	} else if (parser_save() == 1) {
	    console.log("Save game\n.");
	    ret = parser_autosave().trim();
	    if (ret == "")
		    ret = "<i>Игра сохранена (" + parser_savename() + ")</i>"
	    ret = fmtCommand(command) + ret.trim();
	} else if (parser_load() == 1) {
	    if (!isAutosave()) {
		ret = fmtCommand(command) + "<i>Нет сохранённой игры.</i>\n";
	    } else {
		console.log("Load game\n.");
		parser_stop();
		parser_start(Game);
		ret = "<i>Игра восстановлена (" + parser_savename() + ")</i>\n\n" + parser_autoload();
		this.output.empty();
	    }
	} else if (parser_clear() == 1) {
	    this.output.empty();
	} else {
	    ret = fmtCommand(command) + ret.trim();
	}
	ret = parseOutput(ret);
	ret = ret.trim() + '\n\n';
	span.append(ret);
	span.appendTo(this.output)
	this.getLine();
    }
    this.scroll = function()
    {
	var laststruct = this.output.children().last();
	this.scrollParent.scrollTop(laststruct.offset().top - bodylineheight);
    }
    this.prev_next = function(change)
    {
	var input = this.input,
	    mutable_history = this.mutable_history,
	    current = this.current,
	    new_current = current + change;

	// Check it's within range
	if ( new_current < mutable_history.length && new_current >= 0 )
	{
	    mutable_history[current] = input.val();
	    input.val( mutable_history[new_current] );
	    this.current = new_current;
	}
    }
    var input = self.input
    $doc.on( 'click.TextInput keydown.TextInput',
	     function( ev )
	     {
		 // Only intercept on things that aren't inputs and if the user isn't selecting text
		 if ( ev.target.nodeName != 'INPUT' && selection() == '' )
		 {
		     // If the input box is close to the viewport then focus it
		     if ( $window.scrollTop() + $window.height() - input.offset().top > -60 )
		     {
			 // window.scrollTo( 0, 9e9 );
			 input.scroll();
			 // Manually reset the target incase focus/trigger don't - we don't want the trigger to recurse
			 ev.target = input[0];
			 input.focus()
			     .trigger( ev );
			 // Stop propagating after re-triggering it, so that the trigger will work for all keys
			 ev.stopPropagation();
		     }
		     // Intercept the backspace key if not
		     else if ( ev.type == 'keydown' && ev.which == 8 )
		     {
			 return false;
		     }
		 }
	     });
}


function Start(fname)
{
    Game = fname
    $("#about").detach()

    var input = new Input($("#transcript"))
    var span = $('<div role="listitem">')

    if (parser_start(fname) != 0) {
	span.append('<b>Error while starting game!</b>')
	span.appendTo(input.output)
	return;
    }
    document.title = gameName();
    var text = parser_cmd("look");
//    if (isAutosave()) {
//	text = "<i>Игра восстановлена. \"Заново\" &mdash; начать сначала.</i>\n\n" + text;
//    }
    text = parseOutput(text).trim();
    span.append(text + '\n\n')
    span.appendTo(input.output)
    input.getLine()
}
