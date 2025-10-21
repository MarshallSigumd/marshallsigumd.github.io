// daily_muse_backend/index.js
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const fs = require('fs');
const path = require('path');

const app = express();
app.use(cors());
app.use(bodyParser.json());

const DATA_FILE = path.join(__dirname, 'data', 'users.json');

// 初始化存储目录
if (!fs.existsSync(path.dirname(DATA_FILE))) {
  fs.mkdirSync(path.dirname(DATA_FILE), { recursive: true });
}
if (!fs.existsSync(DATA_FILE)) {
  fs.writeFileSync(DATA_FILE, JSON.stringify([]));
}

// 从文件读取用户
function loadUsers() {
  return JSON.parse(fs.readFileSync(DATA_FILE, 'utf-8'));
}

// 写入用户数据
function saveUsers(users) {
  fs.writeFileSync(DATA_FILE, JSON.stringify(users, null, 2));
}

// 注册接口
app.post('/register', (req, res) => {
  const { username, password } = req.body;
  if (!username || !password) {
    return res.status(400).json({ message: '用户名或密码不能为空' });
  }

  const users = loadUsers();
  if (users.find(u => u.username === username)) {
    return res.status(400).json({ message: '用户已存在' });
  }

  const newUser = { username, password, favorites: [] };
  users.push(newUser);
  saveUsers(users);
  res.json({ message: '注册成功', user: newUser });
});

// 登录接口
app.post('/login', (req, res) => {
  const { username, password } = req.body;
  const users = loadUsers();
  const user = users.find(u => u.username === username && u.password === password);
  if (!user) {
    return res.status(401).json({ message: '用户名或密码错误' });
  }
  res.json({ message: '登录成功', user });
});

// 获取收藏夹
app.get('/favorites/:username', (req, res) => {
  const { username } = req.params;
  const users = loadUsers();
  const user = users.find(u => u.username === username);
  if (!user) {
    return res.status(404).json({ message: '用户不存在' });
  }
  res.json({ favorites: user.favorites });
});

// 添加收藏
app.post('/favorites', (req, res) => {
  const { username, item } = req.body;
  const users = loadUsers();
  const user = users.find(u => u.username === username);
  if (!user) {
    return res.status(404).json({ message: '用户不存在' });
  }
  if (!user.favorites.includes(item)) {
    user.favorites.push(item);
  }
  saveUsers(users);
  res.json({ message: '已收藏', favorites: user.favorites });
});

// 删除收藏
app.delete('/favorites', (req, res) => {
  const { username, item } = req.body;
  const users = loadUsers();
  const user = users.find(u => u.username === username);
  if (!user) {
    return res.status(404).json({ message: '用户不存在' });
  }
  user.favorites = user.favorites.filter(f => f !== item);
  saveUsers(users);
  res.json({ message: '已取消收藏', favorites: user.favorites });
});

app.listen(3000, () => console.log('✅ 后端已启动，端口 3000'));
