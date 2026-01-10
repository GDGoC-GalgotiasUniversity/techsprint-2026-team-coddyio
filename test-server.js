// Quick test server - run this first to verify connectivity
const http = require('http');

const server = http.createServer((req, res) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.url}`);
  
  if (req.method === 'POST' && req.url === '/api/ingest') {
    let body = '';
    req.on('data', chunk => body += chunk);
    req.on('end', () => {
      console.log('Received data:', body);
      res.writeHead(201, { 'Content-Type': 'application/json' });
      res.end('{"success":true,"message":"Test OK"}');
    });
  } else {
    res.writeHead(200);
    res.end('Server is running!');
  }
});

server.listen(3000, '0.0.0.0', () => {
  console.log('Test server running on port 3000');
  console.log('Waiting for NodeMCU connection...');
});
