// quote_detail_page.dart

import 'package:flutter/material.dart';
import '../services/api_service.dart';

class QuoteDetailPage extends StatefulWidget {
  final VoidCallback? onFavoriteChanged;
  final Map<String, dynamic>? initialData; // 允许从其他页面传入数据

  const QuoteDetailPage({super.key, this.onFavoriteChanged, this.initialData});

  @override
  _QuoteDetailPageState createState() => _QuoteDetailPageState();
}

class _QuoteDetailPageState extends State<QuoteDetailPage> {
  Map<String, dynamic>? _quoteData;
  bool _isLoading = true;
  bool _isFavorited = false;
  late bool _isViewOnly;

  @override
  void initState() {
    super.initState();
    _isViewOnly = widget.initialData != null;
    if (widget.initialData != null) {
      _quoteData = widget.initialData;
      _isLoading = false;
      _isFavorited = _quoteData?['is_favorited'] ?? false;
    } else {
      _fetchTodayQuote();
    }
  }

  Future<void> _fetchTodayQuote() async {
    setState(() => _isLoading = true);
    final result = await ApiService.getTodayQuote();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result['success']) {
        _quoteData = result['data'];
        _isFavorited = _quoteData?['is_favorited'] ?? false;
      } else {
        _quoteData = {'error': result['message']};
        _isFavorited = false;
      }
    });
  }

  Future<void> _toggleFavorite(int? id) async {
    if (id == null) return;

    bool originalState = _isFavorited;
    setState(() => _isFavorited = !originalState);

    final result = await ApiService.toggleFavorite(id, 'quote');

    if (!mounted) return;

    if (!result['success']) {
      setState(() => _isFavorited = originalState); // 回滚
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('操作失败: ${result['message']}')));
    } else {
      setState(() => _isFavorited = result['favorited']);
      widget.onFavoriteChanged?.call();
    }
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_quoteData == null || _quoteData!.containsKey('error')) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            _quoteData?['error'] ?? '加载失败，请检查网络或稍后重试。',
            textAlign: TextAlign.center,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      );
    }

    final data = _quoteData!;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 使用 Card 包装名言内容，增加可爱感
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Icon(
                      Icons.format_quote_rounded,
                      color: Theme.of(context).colorScheme.secondary,
                      size: 40,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      data['content'] ?? '无内容',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context).colorScheme.primary,
                            height: 1.5,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // 作者
            Text(
              '—— ${data['author'] ?? '未知'}',
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isViewOnly ? '名言详情' : '每日名言'),
        actions: [
          // 仅在非查看模式下显示收藏按钮
          if (!_isViewOnly)
            IconButton(
              icon: Icon(
                _isFavorited ? Icons.favorite : Icons.favorite_border,
                color: _isFavorited ? Colors.redAccent : Colors.white,
                size: 28,
              ),
              onPressed: _quoteData?['id'] != null
                  ? () => _toggleFavorite(_quoteData?['id'])
                  : null,
            ),
          // 仅在非查看模式下显示刷新按钮
          if (!_isViewOnly)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _isLoading ? null : _fetchTodayQuote,
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: _buildContent(),
    );
  }
}
