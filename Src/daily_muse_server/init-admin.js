// init-admin.js
const http = require('http');

const data = JSON.stringify({
  username: 'admin',
  password: 'admin123',
  secret_key: 'daily_muse_secret_2024'
});

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/admin/init',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

const req = http.request(options, (res) => {
  let responseData = '';
  res.on('data', (chunk) => { responseData += chunk; });
  res.on('end', () => {
    console.log('响应:', JSON.parse(responseData));
  });
});

req.on('error', (error) => { console.error('错误:', error); });
req.write(data);
req.end();
