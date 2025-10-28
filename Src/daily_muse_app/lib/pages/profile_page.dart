import 'package:flutter/material.dart';
import '../services/api_service.dart';
// 引入详情页
import 'article_detail_page.dart';
import 'quote_detail_page.dart';

class ProfilePage extends StatefulWidget {
  final bool isLoggedIn;
  final bool isAdmin;
  final String username;
  // 收藏夹现在需要包含文章和名言的列表
  final List<dynamic> favoriteArticles;
  final List<dynamic> favoriteQuotes;
  final VoidCallback? onLogout;
  final VoidCallback? onFavoritesRefresh; // 用于刷新收藏列表

  const ProfilePage({
    super.key,
    this.isLoggedIn = false,
    this.isAdmin = false,
    this.username = "",
    this.favoriteArticles = const [],
    this.favoriteQuotes = const [],
    this.onLogout,
    this.onFavoritesRefresh,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    await ApiService.clearToken();
    if (widget.onLogout != null) {
      widget.onLogout!();
    }
  }

  Future<void> _unfavoriteItem(int id, String type) async {
    setState(() => _isLoading = true);
    // 这里调用 toggleFavorite 相当于取消收藏
    final result = await ApiService.toggleFavorite(id, type);
    setState(() => _isLoading = false);

    if (result['success']) {
      widget.onFavoritesRefresh?.call();
    }

    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已取消收藏')));
    }
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 60,
            color: Colors.pinkAccent.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList(List<dynamic> items, String type) {
    if (items.isEmpty) {
      return _buildEmptyState('暂无收藏');
    }

    return RefreshIndicator(
      onRefresh: () async {
        widget.onFavoritesRefresh?.call();
        // 增加一点延迟，确保刷新动画完整
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final String title = type == 'article'
              ? (item['title'] ?? '无标题')
              : (item['content'] ?? '无内容');
          final String subtitle = "—— ${item['author'] ?? '未知作者'}";

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            elevation: 3,
            child: ListTile(
              title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
              subtitle: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              leading: Icon(
                type == 'article' ? Icons.article : Icons.format_quote,
                color: Theme.of(context).colorScheme.primary,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.favorite, color: Colors.redAccent),
                tooltip: '取消收藏',
                onPressed: _isLoading
                    ? null
                    : () => _unfavoriteItem(item['id'], type),
              ),
              // *** 关键：点击列表项，导航到对应的详情页实现美观阅读 ***
              onTap: () {
                // 克隆 item 并添加 is_favorited 标志，确保详情页知道是收藏状态
                final Map<String, dynamic> data = Map.from(item);
                data['is_favorited'] = true;

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => type == 'article'
                        ? ArticleDetailPage(
                            initialData: data,
                            onFavoriteChanged: widget.onFavoritesRefresh,
                          )
                        : QuoteDetailPage(
                            initialData: data,
                            onFavoriteChanged: widget.onFavoritesRefresh,
                          ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLoggedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock_open, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text("请先登录", style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            const Text("登录后可查看收藏内容", style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    } else {
      // 登录后的主页
      return Scaffold(
        appBar: AppBar(
          title: Text("${widget.username} 的主页"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "退出登录",
              onPressed: _logout,
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: const [
              Tab(text: '收藏的文章'),
              Tab(text: '收藏的名言'),
            ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: [
            // 注意：这里需要确保 main.dart 传递的是 List<dynamic>
            _buildFavoritesList(widget.favoriteArticles, 'article'),
            _buildFavoritesList(widget.favoriteQuotes, 'quote'),
          ],
        ),
      );
    }
  }
}
