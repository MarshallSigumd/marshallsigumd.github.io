// main.dart
import 'package:flutter/material.dart';
// 导入新的详情页
import 'pages/article_detail_page.dart';
import 'pages/quote_detail_page.dart';

import 'pages/home_page.dart';
import 'pages/profile_page.dart';
import 'pages/login_page.dart';
import 'pages/register_page.dart';
import 'pages/admin_page.dart';
import 'services/api_service.dart';

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
  bool _isAdmin = false;
  String _username = "";
  List<dynamic> _favoriteArticles = [];
  List<dynamic> _favoriteQuotes = [];

  late List<Widget> _pages;
  late List<BottomNavigationBarItem> _navItems;

  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    _updatePages();
    // 首次加载时尝试获取收藏列表
    _loadFavorites();
  }

  void _updatePages() {
    // 重新创建 HomePage 并传入 onFavoriteChanged 回调，用于刷新收藏夹
    final homePage = HomePage(
      onFavoriteChanged: _loadFavorites,
      // 传入 navigatorKey 用于 Home Page 导航到详情页时获取 context
      navigatorKey: navigatorKey,
    );

    if (_isAdmin) {
      _pages = [
        homePage,
        AdminPage(),
        ProfilePage(
          isLoggedIn: _isLoggedIn,
          username: _username,
          favoriteArticles: _favoriteArticles,
          favoriteQuotes: _favoriteQuotes,
          isAdmin: _isAdmin,
          onLogout: _handleLogout,
          onFavoritesRefresh: _loadFavorites,
        ),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '主页'),
        BottomNavigationBarItem(
          icon: Icon(Icons.admin_panel_settings),
          label: '管理',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '个人主页'),
      ];
    } else {
      _pages = [
        homePage,
        ProfilePage(
          isLoggedIn: _isLoggedIn,
          username: _username,
          favoriteArticles: _favoriteArticles,
          favoriteQuotes: _favoriteQuotes,
          isAdmin: _isAdmin,
          onLogout: _handleLogout,
          onFavoritesRefresh: _loadFavorites,
        ),
      ];
      _navItems = const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '主页'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '个人主页'),
      ];
    }
  }

  // ... (_loadFavorites 和 _handleLogout 保持不变)
  Future<void> _loadFavorites() async {
    if (!_isLoggedIn) return;

    final result = await ApiService.getFavorites();
    if (result['success']) {
      if (mounted) {
        setState(() {
          _favoriteArticles = result['data']['articles'] ?? [];
          _favoriteQuotes = result['data']['quotes'] ?? [];
          _updatePages();
        });
      }
    } else {
      if (mounted) {
        // ... (省略 Snackbar，保持简洁)
      }
    }
  }

  void _handleLogout() {
    setState(() {
      _isLoggedIn = false;
      _isAdmin = false;
      _username = "";
      _favoriteArticles = [];
      _favoriteQuotes = [];
      _updatePages();
      _selectedIndex = 0;
    });
  }

  // ... (_onItemTapped 保持不变)
  void _onItemTapped(int index) async {
    int profileIndex = _isAdmin ? 2 : 1;

    // 当点击个人主页时，强制刷新收藏列表
    if (index == profileIndex && _isLoggedIn) {
      _loadFavorites();
    }

    if (index == profileIndex && !_isLoggedIn) {
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
          final loginResult = await navigatorKey.currentState!
              .push<Map<String, dynamic>?>(
                MaterialPageRoute(builder: (_) => LoginPage()),
              );
          if (loginResult != null && loginResult['success'] == true) {
            setState(() {
              _isLoggedIn = true;
              _isAdmin = loginResult['is_admin'] ?? false;
              _username = loginResult['username'] ?? "用户";
              _updatePages();
              _loadFavorites();
              _selectedIndex = _isAdmin ? 2 : 1;
            });
          }
        } else if (result["action"] == "register") {
          final registerResult = await navigatorKey.currentState!
              .push<Map<String, dynamic>?>(
                MaterialPageRoute(builder: (_) => RegisterPage()),
              );
          if (registerResult != null && registerResult['success'] == true) {
            setState(() {
              _isLoggedIn = true;
              _isAdmin = false;
              _username = registerResult['username'] ?? "新用户";
              _favoriteArticles = [];
              _favoriteQuotes = [];
              _updatePages();
              _selectedIndex = 1;
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
      // ==================== 可爱主题优化 ====================
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF5F5FC), // 浅紫色/淡蓝色背景
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF673AB7), // 主色调：深紫色
          secondary: const Color(0xFFFF4081), // 强调色：粉色
          background: const Color(0xFFF5F5FC),
          surface: Colors.white,
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFF673AB7),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.purple[200],
        ),
        cardTheme: CardThemeData(
          elevation: 6,
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20), // 更大的圆角
          ),
          shadowColor: Colors.pinkAccent.withOpacity(0.3), // 柔和的阴影
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          selectedItemColor: const Color(0xFFFF4081),
          unselectedItemColor: Colors.grey[600],
          elevation: 8,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.pink[100]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.pink[100]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFFF4081), width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey[700]),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF673AB7), // 按钮背景色
            foregroundColor: Colors.white, // 按钮文字颜色
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            elevation: 4,
          ),
        ),
      ),
      // =======================================================
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: _navItems,
        ),
      ),
    );
  }
}
