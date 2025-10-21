import 'package:flutter/material.dart';
import '../services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _articleContent = '点击按钮获取今日文章...';
  String _quoteContent = '点击按钮获取今日名言...';
  bool _isLoadingArticle = false;
  bool _isLoadingQuote = false;

  Future<void> _fetchTodayArticle() async {
    setState(() => _isLoadingArticle = true);

    final result = await ApiService.getTodayArticle();

    setState(() {
      _isLoadingArticle = false;
      if (result['success']) {
        final data = result['data'];
        _articleContent =
            '标题: ${data['title']}\n作者: ${data['author']}\n\n${data['content']}';
      } else {
        _articleContent = result['message'];
      }
    });
  }

  Future<void> _fetchTodayQuote() async {
    setState(() => _isLoadingQuote = true);

    final result = await ApiService.getTodayQuote();

    setState(() {
      _isLoadingQuote = false;
      if (result['success']) {
        final data = result['data'];
        _quoteContent = '"${data['content']}"\n—— ${data['author']}';
      } else {
        _quoteContent = result['message'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('每日精选')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SectionCard(
            title: '今日文章',
            content: _articleContent,
            isLoading: _isLoadingArticle,
            onTap: _fetchTodayArticle,
          ),
          SectionCard(
            title: '今日名言',
            content: _quoteContent,
            isLoading: _isLoadingQuote,
            onTap: _fetchTodayQuote,
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final String content;
  final bool isLoading;
  final VoidCallback onTap;

  const SectionCard({
    required this.title,
    required this.content,
    this.isLoading = false,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              content,
              style: const TextStyle(fontSize: 14),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : onTap,
                child: isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('点击获取'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
