import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ProfilePage extends StatefulWidget {
  final bool isLoggedIn;
  final bool isAdmin;
  final String username;
  final List<String> favorites;
  final VoidCallback? onLogout;

  const ProfilePage({
    super.key,
    this.isLoggedIn = false,
    this.isAdmin = false,
    this.username = "",
    this.favorites = const [],
    this.onLogout,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _articleNotificationEnabled = true;
  bool _quoteNotificationEnabled = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.isLoggedIn) {
      _loadNotificationSettings();
    }
  }

  Future<void> _loadNotificationSettings() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getNotificationSettings();
    setState(() {
      _isLoading = false;
      if (result['success']) {
        final data = result['data'];
        _articleNotificationEnabled = data['article_enabled'] ?? true;
        _quoteNotificationEnabled = data['quote_enabled'] ?? true;
      }
    });
  }

  Future<void> _updateNotificationSettings() async {
    setState(() => _isLoading = true);
    final result = await ApiService.updateNotificationSettings(
      _articleNotificationEnabled,
      _quoteNotificationEnabled,
    );
    setState(() => _isLoading = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  Future<void> _logout() async {
    await ApiService.clearToken();
    if (widget.onLogout != null) {
      widget.onLogout!();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoggedIn) {
      return Center(
        child: Text("欢迎，未登录", style: TextStyle(fontSize: 20)),
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: Text("${widget.username} 的个人主页"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "退出登录",
              onPressed: _logout,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "推送通知设置",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: CheckboxListTile(
                title: const Text('接收文章推送'),
                value: _articleNotificationEnabled,
                onChanged: (value) {
                  setState(() => _articleNotificationEnabled = value ?? true);
                },
              ),
            ),
            Card(
              child: CheckboxListTile(
                title: const Text('接收名言推送'),
                value: _quoteNotificationEnabled,
                onChanged: (value) {
                  setState(() => _quoteNotificationEnabled = value ?? true);
                },
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _updateNotificationSettings,
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('保存设置'),
            ),
          ],
        ),
      );
    }
  }
}
