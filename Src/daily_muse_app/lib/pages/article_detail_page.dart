import 'package:flutter/material.dart';
import '../services/api_service.dart';

class ArticleDetailPage extends StatefulWidget {
  final VoidCallback? onFavoriteChanged;
  // 允许从其他页面（如 AdminPage, ProfilePage）传入数据进行展示
  final Map<String, dynamic>? initialData;

  const ArticleDetailPage({
    super.key,
    this.onFavoriteChanged,
    this.initialData,
  });

  @override
  _ArticleDetailPageState createState() => _ArticleDetailPageState();
}

class _ArticleDetailPageState extends State<ArticleDetailPage> {
  Map<String, dynamic>? _articleData;
  bool _isLoading = true;
  bool _isFavorited = false;
  // 标记是否是查看模式（非今日文章），如果是，则不显示收藏按钮
  late bool _isViewOnly;

  @override
  void initState() {
    super.initState();
    _isViewOnly = widget.initialData != null;
    if (widget.initialData != null) {
      _articleData = widget.initialData;
      _isLoading = false;
      // 检查传入的数据是否有收藏状态（收藏夹页面会传入）
      _isFavorited = _articleData?['is_favorited'] ?? false;
    } else {
      _fetchTodayArticle();
    }
  }

  Future<void> _fetchTodayArticle() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getTodayArticle();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _articleData = result['data'];
        _isFavorited = _articleData?['is_favorited'] ?? false;
      } else {
        _articleData = {'error': result['message']};
        _isFavorited = false;
      }
    });
  }

  Future<void> _toggleFavorite(int? id) async {
    if (id == null) return;

    bool originalState = _isFavorited;
    // 乐观更新 UI
    setState(() => _isFavorited = !originalState);

    final result = await ApiService.toggleFavorite(id, 'article');

    if (!mounted) return;

    if (!result['success']) {
      setState(() => _isFavorited = originalState); // 回滚
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('操作失败: ${result['message']}')));
    } else {
      // 这里的 result['favorited'] 是后端返回的最新状态
      setState(() => _isFavorited = result['favorited']);
      widget.onFavoriteChanged?.call(); // 通知主页/main刷新收藏
    }
  }

  // 优化：处理文章缩进和段落间距
  String _formatArticleContent(String content) {
    // 1. 将所有 \t 替换为四个非断行空格（\u00A0），以模拟缩进
    return content.replaceAll('\t', '\u00A0\u00A0\u00A0\u00A0');
  }

  // 新增：构建文章内容 Widget，以实现更好的段落排版
  Widget _buildArticleBody(String content) {
    // 假设文章内容是以 \n\n (或 \r\n\r\n) 分隔的段落
    // 过滤掉所有可能的多余空行，确保段落间只有我们需要的间距
    final paragraphs = content
        .split(RegExp(r'\n{2,}|\r\n\r\n'))
        .where((p) => p.trim().isNotEmpty)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: paragraphs.map((paragraph) {
        // 进一步处理，将段落内多余的换行符替换为空格
        String cleanedParagraph = paragraph
            .replaceAll(RegExp(r'\n|\r\n'), ' ')
            .trim();

        // 应用缩进格式化
        String formattedParagraph = _formatArticleContent(cleanedParagraph);

        return Padding(
          // 调整段落间距，使其更紧凑 (从 16 减少到 10)
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Text(
            formattedParagraph,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              height: 1.6, // 调整行高，提升阅读舒适度
              letterSpacing: 0.2,
            ),
            textAlign: TextAlign.justify,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_articleData == null || _articleData!.containsKey('error')) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            _articleData?['error'] ?? '加载失败，请检查网络或稍后重试。',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    final data = _articleData!;
    final content = data['content'] ?? '';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Text(
            data['title'] ?? '无标题',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary, // 使用主题主色
            ),
          ),
          const SizedBox(height: 8),
          // 作者
          Text(
            '作者: ${data['author'] ?? '未知'}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontStyle: FontStyle.italic,
              color: Colors.pinkAccent[100],
            ),
          ),
          const Divider(height: 30, thickness: 1.5),
          // 使用新的内容构建方法
          _buildArticleBody(content),
          const SizedBox(height: 50),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isViewOnly ? '文章详情' : '每日文章'),
        actions: [
          // 仅在非查看模式下显示收藏按钮
          if (!_isViewOnly)
            IconButton(
              icon: Icon(
                _isFavorited ? Icons.favorite : Icons.favorite_border,
                color: _isFavorited ? Colors.redAccent : Colors.white,
                size: 28,
              ),
              onPressed: _articleData?['id'] != null
                  ? () => _toggleFavorite(_articleData?['id'])
                  : null,
            ),
          // 仅在非查看模式下显示刷新按钮
          if (!_isViewOnly)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _isLoading ? null : _fetchTodayArticle,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildContent(),
    );
  }
}
