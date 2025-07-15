#!/usr/bin/env node
const http = require('http');

const RPC_USER = process.env.RPC_USER;
// Allow both PRC_PASSWORD and RPC_PASSWORD for flexibility
const RPC_PASSWORD = process.env.PRC_PASSWORD || process.env.RPC_PASSWORD;
const RPC_IP = process.env.RPC_IP || '127.0.0.1';
const RPC_PORT = process.env.RPC_PORT || 9819;

if (!RPC_USER || !RPC_PASSWORD) {
  console.error('Missing RPC credentials. Set RPC_USER and PRC_PASSWORD (or RPC_PASSWORD).');
  process.exit(1);
}

const postData = JSON.stringify({
  jsonrpc: '2.0',
  id: 1,
  method: 'getbalance',
  params: []
});

const options = {
  hostname: RPC_IP,
  port: RPC_PORT,
  method: 'POST',
  path: '/',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData),
    'Authorization': 'Basic ' + Buffer.from(`${RPC_USER}:${RPC_PASSWORD}`).toString('base64')
  }
};

const req = http.request(options, (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    try {
      const parsed = JSON.parse(data);
      if (parsed.error) {
        console.error('RPC error:', parsed.error);
        process.exit(1);
      }
      console.log('Wallet balance:', parsed.result);
    } catch (err) {
      console.error('Failed to parse RPC response:', err.message);
      process.exit(1);
    }
  });
});

req.on('error', (err) => {
  console.error('Request error:', err.message);
  process.exit(1);
});

req.write(postData);
req.end();
