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

function dataUrl(path)
{
    var fullpath = parser_path() + '/' + path;
    fullpath = fullpath.trim().replace(/\\/g, '\/').replace(/\/+/g, '\/');
    fullpath = fullpath.replace(/^\./, '')
    if (!Blobs.hasOwnProperty(fullpath)) {
	if (FS.analyzePath(fullpath).exists) {
	    let content = FS.readFile(fullpath);
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
	var width = this.output.width() - this.prompt.width();
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
	if (parser_restart() == 1) {
	    console.log("Restart game\n.");
	    parser_stop();
	    parser_start(Game);
	    ret = parser_cmd("look");
	    this.output.empty();
	} else if (parser_load() == 1) {
	    console.log("Load game\n.");
	    parser_stop();
	    parser_start(Game);
	    ret = "<i>Restored.</i>\n\n" + parser_autoload();
	    this.output.empty();
	} else if (parser_clear() == 1) {
	    this.output.empty();
	} else {
	    ret = '&gt; <b>' + command.trim() + '</b>' + '\n' + ret;
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
    var text = parser_cmd("look");
    text = parseOutput(text).trim();
    span.append(text + '\n\n')
    span.appendTo(input.output)
    input.getLine()
}
