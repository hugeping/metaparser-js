var Module;
FS.mkdir('/appdata');
FS.mount(IDBFS,{},'/appdata');

FS.mkdir('/games');
FS.mount(MEMFS,{},'/games');

var parser_start, parser_stop, parser_cmd, parser_restart

Module['postRun'].push(function() {
	console.log("Starting...");
	parser_start = Module.cwrap('parser_start', 'string', ['string'])
	parser_restart = Module.cwrap('parser_restart', 'number')
	parser_stop = Module.cwrap('parser_stop', null)
	parser_cmd = Module.cwrap('parser_cmd', 'string', ['string'])

	var argv = []
	var req
	var url

	var metatags = document.getElementsByTagName('meta');

	for (var mt = 0; mt < metatags.length; mt++) { 
		if (metatags[mt].getAttribute("name") === "gamefile") {
			url = metatags[mt].getAttribute("content");
		}
	}

	if (!url && typeof window === "object") {
		argv = window.location.search.substr(1).trim().split('&');
		if (!argv[0])
			argv = [];
		url = argv[0];
	}

	if (!url)
		url='data.zip?'+(Math.random()*10000000);

	req = new XMLHttpRequest();
	req.open("GET", url, true);
	req.responseType = "arraybuffer";
	console.log("Get: ", url);

	req.onload = function() {
		var basename = function(path) {
			parts = path.split( '/' );
			return parts[parts.length - 1];
		}
		var data = req.response;
		console.log("Data loaded...");
		FS.syncfs(true, function (error) {
			if (error) {
				console.log("Error while syncing: ", error);
			}
			url = basename(url);
			console.log("Writing: ", url);
			FS.writeFile(url, new Int8Array(data), { encoding: 'binary' }, "w");
			console.log("Running...");
			window.onclick = function(){ window.focus() };
			Start(url);
		});
	}
	req.send(null);
});
