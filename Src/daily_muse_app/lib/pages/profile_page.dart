import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  final bool isLoggedIn;
  final String username;
  final List<String> favorites;
  final VoidCallback? onLogout;

  const ProfilePage({
    super.key,
    this.isLoggedIn = false,
    this.username = "",
    this.favorites = const [],
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoggedIn) {
      return Center(child: Text("欢迎，未登录", style: TextStyle(fontSize: 20)));
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("$username 的个人主页"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "退出登录",
              onPressed: onLogout,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "我的收藏夹",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...favorites.map((item) => ListTile(title: Text(item))).toList(),
          ],
        ),
      );
    }
  }
}
