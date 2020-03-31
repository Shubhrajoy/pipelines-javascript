const http = require('http');
const hostname = 'azdevops-test02';
const port = 5000;
const server = http.createServer((req, res) => {
res.statusCode = 200;
res.setHeader('Content-Type', 'text/plain');
res.end('My new Node.js app...how do you like it..??\n');
});
server.listen(port, hostname, () => {
console.log();
});
