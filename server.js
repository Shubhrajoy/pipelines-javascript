const http = require('http');
const hostname = 'azdevops-test02';
const port = 5000;
const server = http.createServer((req, res) => {
res.statusCode = 200;
res.setHeader('Content-Type', 'text/plain');
res.end('Final testing of my new Nod.js app...!!!\n');
});
server.listen(port, hostname, () => {
console.log();
});
