var port = 1111;
//var xml = '<?xml version="1.0"?>\n<!DOCTYPE cross-domain-policy SYSTEM \n"http://www.adobe.com/xml/dtds/cross-domain-policy.dtd">\n<cross-domain-policy>\n<site-control permitted-cross-domain-policies="master-only"/>\n<allow-access-from domain="*" to-ports="*"/>\n</cross-domain-policy>\n\0';
var xml = '<cross-domain-policy><allow-access-from domain="*" to-ports="*" /></cross-domain-policy>';

require("net").createServer(function(client){
	client.on('error', function(err){});
	client.write(xml);
	client.end();
	console.log("policy file sent");
}).listen(port);
console.log("cross-domain-policy on port "+port);