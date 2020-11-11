
var http = require('http');
const util = require('util');
const exec = util.promisify(require('child_process').exec);

var AsyncLock = require('async-lock');
var lock = new AsyncLock({timeout: 500});
var lockKey = "ghost_starting";

var sleepAmount = 15 * 1000

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function start() {
  console.log('Starting Ghost Server');
  const {stdout, stderr} = await exec('ghost start', {cwd: '/var/www/ghost'});
  await sleep(sleepAmount);
  if (stderr) {
    console.log(`error starting ghost: ${stderr}`)
  }
}

//create a server object:
http.createServer(async function (req, res) {

  res.writeHead(200, {'Content-Type': 'text/html'});
  res.write('<head><meta http-equiv="refresh" content="2"></head>');
  res.write('<body>Ghost CMS Server starting ....');
  res.end(); //end the response

  try {
    await lock.acquire(lockKey, start)
    console.log(`ghost started`)
  } catch (err) {
    console.log(`skipping start, already trying ${err}`);
  }

}).listen(7777);