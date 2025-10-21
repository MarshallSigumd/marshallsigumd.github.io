import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _articleTitleController = TextEditingController();
  final _articleContentController = TextEditingController();
  final _articleAuthorController = TextEditingController();
  
  final _quoteContentController = TextEditingController();
  final _quoteAuthorController = TextEditingController();
  final _quoteCategoryController = TextEditingController();

  bool _isLoadingArticle = false;
  bool _isLoadingQuote = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _articleTitleController.dispose();
    _articleContentController.dispose();
    _articleAuthorController.dispose();
    _quoteContentController.dispose();
    _quoteAuthorController.dispose();
    _quoteCategoryController.dispose();
    super.dispose();
  }

  Future<void> _addArticle() async {
    if (_articleTitleController.text.isEmpty ||
        _articleContentController.text.isEmpty ||
        _articleAuthorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写所有字段')),
      );
      return;
    }

    setState(() => _isLoadingArticle = true);
    final result = await ApiService.addArticle(
      _articleTitleController.text,
      _articleContentController.text,
      _articleAuthorController.text,
    );
    setState(() => _isLoadingArticle = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      _articleTitleController.clear();
      _articleContentController.clear();
      _articleAuthorController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  Future<void> _addQuote() async {
    if (_quoteContentController.text.isEmpty ||
        _quoteAuthorController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请填写名言内容和作者')),
      );
      return;
    }

    setState(() => _isLoadingQuote = true);
    final result = await ApiService.addQuote(
      _quoteContentController.text,
      _quoteAuthorController.text,
      _quoteCategoryController.text,
    );
    setState(() => _isLoadingQuote = false);

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
      _quoteContentController.clear();
      _quoteAuthorController.clear();
      _quoteCategoryController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'])),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('管理员面板'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '文章管理'),
            Tab(text: '名言管理'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // 文章管理页面
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '添加新文章',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _articleTitleController,
                  decoration: const InputDecoration(
                    labelText: '文章标题',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _articleAuthorController,
                  decoration: const InputDecoration(
                    labelText: '作者',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _articleContentController,
                  decoration: const InputDecoration(
                    labelText: '文章内容',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 6,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoadingArticle ? null : _addArticle,
                    child: _isLoadingArticle
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('发布文章'),
                  ),
                ),
              ],
            ),
          ),
          // 名言管理页面
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '添加新名言',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _quoteContentController,
                  decoration: const InputDecoration(
                    labelText: '名言内容',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 4,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quoteAuthorController,
                  decoration: const InputDecoration(
                    labelText: '作者',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _quoteCategoryController,
                  decoration: const InputDecoration(
                    labelText: '分类（可选）',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoadingQuote ? null : _addQuote,
                    child: _isLoadingQuote
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('发布名言'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
