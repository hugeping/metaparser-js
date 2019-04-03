var $window = $(window), $doc = $(document), $body, bodylineheight

$(function()
{
    $body = $('body');
    var elem = $('<span>&nbsp;</span>').appendTo($body);
    bodylineheight = elem.height();
    elem.remove();
});

var selection = window.getSelection ||
    function() { return document.selection ? document.selection.createRange().text : '' };

function Input(container)
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
    self.lastinput = $('<span class="lastinput"/>').appendTo(container)
    self.container = container
    self.scrollParent = $('html,body')
    self.history = [];
    self.getLine = function()
    {
	this.mode = 'line'
	this.current = 0;
	this.mutable_history = this.history.slice();
	this.mutable_history.unshift('');
	var laststruct = this.container.children().last();
	this.input.val('').appendTo(this.container);
	this.scroll();
	this.input.focus();

    }
    self.submitLine = function()
    {
	var command = this.input.val();
	this.lastinput.appendTo(this.input.parent());
	if (command != this.history[0] && /\S/.test(command)) {
	    this.history.unshift(command);
	}
	this.mode = 0;
	this.input.detach();
	var span = $('<span>')
	var ret = parser_cmd('@metaparser "' + command.replace(/"/g, "") + '"'); //'
	span.append('<b>' + command + '</b>' + '\n' + ret + '\n> ')
	span.appendTo(this.container)
	this.getLine();
    }
    this.scroll = function()
    {
	this.scrollParent.scrollTop(this.lastinput.offset().top - bodylineheight);
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
    $("#about").detach()
    var main = $("<div>", {
	class: "main",
    })
    $("#metaparser").css({"max-width" : "40em"})
    var input = new Input(main)
    $("#metaparser").append(main)
    parser_start(fname);
    var text = parser_cmd("look");
    var span = $('<span>')
    span.append(text + '\n>')
    span.appendTo(input.container)
    input.getLine()
}
