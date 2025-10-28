// home_page.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';
// 引入新的详情页
import 'article_detail_page.dart';
import 'quote_detail_page.dart';

class HomePage extends StatelessWidget {
  final VoidCallback? onFavoriteChanged;
  final GlobalKey<NavigatorState>? navigatorKey; // 用于导航

  const HomePage({super.key, this.onFavoriteChanged, this.navigatorKey});

  // 导航方法
  void _navigateToDetail(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    // 确保回调能被传递到详情页
    final articlePage = ArticleDetailPage(onFavoriteChanged: onFavoriteChanged);
    final quotePage = QuoteDetailPage(onFavoriteChanged: onFavoriteChanged);

    return Scaffold(
      appBar: AppBar(title: const Text('每日精选')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 顶部标题
              Text(
                '欢迎来到每日精选',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 50),

              // 每日文章按钮
              _buildCuteButton(
                context,
                icon: Icons.article_outlined,
                label: '每日文章',
                color: const Color(0xFFF778A1), // 浅粉色
                onTap: () => _navigateToDetail(context, articlePage),
              ),
              const SizedBox(height: 30),

              // 每日名言按钮
              _buildCuteButton(
                context,
                icon: Icons.format_quote_rounded,
                label: '每日名言',
                color: const Color(0xFF98A6F3), // 浅紫色
                onTap: () => _navigateToDetail(context, quotePage),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 可爱按钮的自定义 Widget
  Widget _buildCuteButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 8,
      shadowColor: color.withOpacity(0.5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: color.withOpacity(0.85),
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.9), color.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(width: 16),
              Text(
                label,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// 移除旧的 _HomePageState 和 SectionCard 逻辑，它们已被新的详情页取代
// ...
