const http = require('http');
const PORT = process.env.PORT || 3000;

const server = http.createServer((req, res) => {
  res.end('🎉 App is live on EC2 with PM2!');
});

server.listen(PORT, () => console.log(`Server running on http://localhost:${PORT}`));

