// daily_muse_backend/index.js
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

const app = express();
app.use(cors());
app.use(bodyParser.json());

let users = []; // 简单存储注册用户

// 注册接口
app.post('/register', (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ message: '用户名或密码不能为空' });
  }
  if (users.find(u => u.username === username)) {
    return res.status(400).json({ message: '用户已存在' });
  }
  users.push({ username, password });
  res.json({ message: '注册成功', token: 'dummy_token' });
});

// 登录接口
app.post('/login', (req, res) => {
  const { username, password } = req.body;
  const user = users.find(u => u.username === username && u.password === password);
  if (!user) return res.status(401).json({ message: '用户名或密码错误' });
  res.json({ message: '登录成功', token: 'dummy_token' });
});

app.listen(3000, () => console.log('后端已启动，端口 3000'));
