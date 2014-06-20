#!/usr/bin/env node

var path = require('path');
var ssh2 = require('ssh2');

if(process.argv.length < 4) {
	console.log("Usage: " + process.argv[1] + " <remote host> <remote port> <local port>");
	process.exit(255);
}

function getUserHome() {
  return process.env.HOME || process.env.HOMEPATH || process.env.USERPROFILE;
}

var config = {
	userName : process.env.USER,
	keyFile : path.join(getUserHome(), ".ssh", "id_rsa"),
	remoteHost : process.argv[2],
	remotePort : process.argv[3],
	localPort : process.argv[4],
};

console.log("Attempting to forward " + config.userName +"@" + config.remoteHost + ":" + config.remotePort + " to localhost:" + config.localPort + " using keyfile " + config.keyFile);

var conn = new ssh2();
conn.on('ready', function() {
  console.log('Connection :: ready');
  conn.exec('uptime', function(err, stream) {
    if (err) throw err;
    stream.on('exit', function(code, signal) {
      console.log('Stream :: exit :: code: ' + code + ', signal: ' + signal);
    }).on('close', function() {
      console.log('Stream :: close');
      conn.end();
    }).on('data', function(data) {
      console.log('STDOUT: ' + data);
    }).stderr.on('data', function(data) {
      console.log('STDERR: ' + data);
    });
  });
}).connect({
  host: config.remoteHost,
  port: 22,
  username: config.userName,
  privateKey: require('fs').readFileSync(config.keyFile)
});
