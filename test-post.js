// Test if server is receiving and saving data
const http = require('http');

const testData = JSON.stringify({
  temperature: 25.5,
  humidity: 60.0,
  soil_raw: 500,
  soil_pct: 50.0
});

const options = {
  hostname: '172.22.48.1',
  port: 3000,
  path: '/api/ingest',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': testData.length
  }
};

console.log('Testing POST to server...');
console.log('URL: http://172.22.48.1:3000/api/ingest');
console.log('Data:', testData);
console.log('');

const req = http.request(options, (res) => {
  console.log(`Status Code: ${res.statusCode}`);
  
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  
  res.on('end', () => {
    console.log('Response:', data);
    
    if (res.statusCode === 201) {
      console.log('\n✓ SUCCESS! Server is working correctly.');
      console.log('Now check if NodeMCU Serial Monitor shows code: 201');
    } else {
      console.log('\n✗ ERROR: Server responded but with wrong status code');
    }
  });
});

req.on('error', (error) => {
  console.error('✗ ERROR connecting to server:', error.message);
  console.log('\nPossible issues:');
  console.log('1. Server not running (run: cd server && npm start)');
  console.log('2. Wrong IP address');
  console.log('3. Firewall blocking connection');
});

req.write(testData);
req.end();
