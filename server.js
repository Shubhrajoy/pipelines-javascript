const http = require('http');
const hostname = 'azdevops-test02';
const server = http.createServer((req, res) => {
res.statusCode = 200;
res.setHeader('Content-Type', 'text/plain');
res.end('My Sample App is Up and Running....!\n');
});
server.listen(port, hostname, () => {
console.log();
});
