import 'package:flutter/material.dart';
import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';

void main() {
  runApp(DailyMuseApp());
}

class DailyMuseApp extends StatefulWidget {
  @override
  _DailyMuseAppState createState() => _DailyMuseAppState();
}

class _DailyMuseAppState extends State<DailyMuseApp> {
  int _selectedIndex = 0;
  bool _isLoggedIn = false;
  String _username = "";
  List<String> _favorites = [];

  late List<Widget> _pages;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _pages = [
      HomePage(),
      ProfilePage(
        isLoggedIn: _isLoggedIn,
        username: _username,
        favorites: _favorites,
        onLogout: _handleLogout,
      ),
    ];
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _username = "";
      _favorites = [];
      _pages[1] = ProfilePage(
        isLoggedIn: _isLoggedIn,
        username: _username,
        favorites: _favorites,
        onLogout: _handleLogout,
      );
      _selectedIndex = 0; // 可选择切回首页
    });
  }

  void _onItemTapped(int index) async {
    if (index == 1 && !_isLoggedIn) {
      final result = await showDialog<Map<String, dynamic>>(
        context: navigatorKey.currentContext!,
        builder: (context) => AlertDialog(
          title: const Text("账号操作"),
          content: const Text("请选择登录或注册"),
          actions: [
            TextButton(
              child: const Text("登录"),
              onPressed: () => Navigator.pop(context, {"action": "login"}),
            ),
            TextButton(
              child: const Text("注册"),
              onPressed: () => Navigator.pop(context, {"action": "register"}),
            ),
          ],
        ),
      );

      if (result != null) {
        if (result["action"] == "login") {
          final loginResult = await navigatorKey.currentState!.push<bool>(
            MaterialPageRoute(builder: (_) => LoginPage()),
          );
          if (loginResult == true) {
            setState(() {
              _isLoggedIn = true;
              _username = "用户";
              _favorites = ["收藏文章1", "收藏名言1", "收藏音乐1"];
              _pages[1] = ProfilePage(
                isLoggedIn: _isLoggedIn,
                username: _username,
                favorites: _favorites,
                onLogout: _handleLogout,
              );
              _selectedIndex = index;
            });
          }
        } else if (result["action"] == "register") {
          final registerResult = await navigatorKey.currentState!.push<bool>(
            MaterialPageRoute(builder: (_) => RegisterPage()),
          );
          if (registerResult == true) {
            setState(() {
              _isLoggedIn = true;
              _username = "新用户";
              _favorites = [];
              _pages[1] = ProfilePage(
                isLoggedIn: _isLoggedIn,
                username: _username,
                favorites: _favorites,
                onLogout: _handleLogout,
              );
              _selectedIndex = index;
            });
          }
        }
      }
    } else {
      setState(() => _selectedIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: '每日精选',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '主页'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '个人主页'),
          ],
        ),
      ),
    );
  }
}
