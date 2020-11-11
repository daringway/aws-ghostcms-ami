var http = require('http');

const { spawn } = require('child_process');

var AsyncLock = require('async-lock');
var lock = new AsyncLock();
var lockKey = "ghost_starting";

let publisher = null;

async function publish() {
  if ( publisher ) {
    console.log('killing publisher')
    await publisher.kill('SIGKILL')
  }

  console.log('publishing website');
  publisher = spawn('/var/www/manager/site-updated');

  publisher.on('exit', (code, signal) => {
    console.log(`publisher exited ${code} : ${signal}`)
    publisher = null
  })
}

//create a server object:
http.createServer(async function (req, res) {
  console.log('starting publishing process');
  res.end(); //end the response

  try {
    await lock.acquire(lockKey, publish)
    console.log(`publishing started`)
  } catch (err) {
    console.log(`failed to acuire publishing lock ${err}`);
  }

}).listen(8888); //the server object listens on port 8080