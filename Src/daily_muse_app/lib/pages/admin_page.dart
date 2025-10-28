import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // 文章相关
  final _articleTitleController = TextEditingController();
  final _articleContentController = TextEditingController();
  final _articleAuthorController = TextEditingController();
  List<dynamic> _articles = [];
  bool _isLoadingArticle = false;
  bool _isLoadingArticles = false;

  // 名言相关
  final _quoteContentController = TextEditingController();
  final _quoteAuthorController = TextEditingController();
  final _quoteCategoryController = TextEditingController();
  List<dynamic> _quotes = [];
  bool _isLoadingQuote = false;
  bool _isLoadingQuotes = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadArticles();
    _loadQuotes();
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

  // 加载文章列表
  Future<void> _loadArticles() async {
    setState(() => _isLoadingArticles = true);
    final result = await ApiService.getArticles();
    setState(() => _isLoadingArticles = false);

    if (result['success']) {
      setState(() {
        _articles = result['data'] ?? [];
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    }
  }

  // 加载名言列表
  Future<void> _loadQuotes() async {
    setState(() => _isLoadingQuotes = true);
    final result = await ApiService.getQuotes();
    setState(() => _isLoadingQuotes = false);

    if (result['success']) {
      setState(() {
        _quotes = result['data'] ?? [];
      });
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
      }
    }
  }

  // 添加文章
  Future<void> _addArticle() async {
    if (_articleTitleController.text.isEmpty ||
        _articleContentController.text.isEmpty ||
        _articleAuthorController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写所有字段')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
      _articleTitleController.clear();
      _articleContentController.clear();
      _articleAuthorController.clear();
      _loadArticles();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  // 添加名言
  Future<void> _addQuote() async {
    if (_quoteContentController.text.isEmpty ||
        _quoteAuthorController.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('请填写名言内容和作者')));
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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
      _quoteContentController.clear();
      _quoteAuthorController.clear();
      _quoteCategoryController.clear();
      _loadQuotes();
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
    }
  }

  // 显示编辑文章对话框
  void _showEditArticleDialog(Map<String, dynamic> article) {
    final titleController = TextEditingController(text: article['title']);
    final contentController = TextEditingController(text: article['content']);
    final authorController = TextEditingController(text: article['author']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑文章'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: '文章标题',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: '作者',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: '文章内容',
                  border: OutlineInputBorder(),
                ),
                maxLines: 6,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await ApiService.updateArticle(
                article['id'],
                titleController.text,
                contentController.text,
                authorController.text,
              );

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(result['message'])));
                if (result['success']) {
                  _loadArticles();
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // 显示编辑名言对话框
  void _showEditQuoteDialog(Map<String, dynamic> quote) {
    final contentController = TextEditingController(text: quote['content']);
    final authorController = TextEditingController(text: quote['author']);
    final categoryController = TextEditingController(
      text: quote['category'] ?? '',
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('编辑名言'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: '名言内容',
                  border: OutlineInputBorder(),
                ),
                maxLines: 4,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: authorController,
                decoration: const InputDecoration(
                  labelText: '作者',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(
                  labelText: '分类（可选）',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await ApiService.updateQuote(
                quote['id'],
                contentController.text,
                authorController.text,
                categoryController.text,
              );

              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(result['message'])));
                if (result['success']) {
                  _loadQuotes();
                }
              }
            },
            child: const Text('保存'),
          ),
        ],
      ),
    );
  }

  // 删除文章
  Future<void> _deleteArticle(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这篇文章吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ApiService.deleteArticle(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
        if (result['success']) {
          _loadArticles();
        }
      }
    }
  }

  // 删除名言
  Future<void> _deleteQuote(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('确定要删除这条名言吗？此操作不可撤销。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('取消'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final result = await ApiService.deleteQuote(id);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result['message'])));
        if (result['success']) {
          _loadQuotes();
        }
      }
    }
  }

  // 设置今日文章
  Future<void> _setTodayArticle(int id) async {
    final result = await ApiService.setTodayArticle(id);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
      if (result['success']) {
        _loadArticles();
      }
    }
  }

  // 设置今日名言
  Future<void> _setTodayQuote(int id) async {
    final result = await ApiService.setTodayQuote(id);
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(result['message'])));
      if (result['success']) {
        _loadQuotes();
      }
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
          RefreshIndicator(
            onRefresh: _loadArticles,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '文章列表',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _isLoadingArticles ? null : _loadArticles,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoadingArticles
                      ? const Center(child: CircularProgressIndicator())
                      : _articles.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('暂无文章'),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _articles.length,
                          itemBuilder: (context, index) {
                            final article = _articles[index];
                            final isToday = article['is_today'] == 1;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: isToday ? Colors.blue.shade50 : null,
                              child: ListTile(
                                title: Text(
                                  article['title'] ?? '',
                                  style: TextStyle(
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('作者: ${article['author'] ?? ''}'),
                                    if (isToday)
                                      const Text(
                                        '⭐ 今日文章',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('编辑'),
                                        ],
                                      ),
                                    ),
                                    if (!isToday)
                                      const PopupMenuItem(
                                        value: 'set_today',
                                        child: Row(
                                          children: [
                                            Icon(Icons.star, size: 20),
                                            SizedBox(width: 8),
                                            Text('设为今日文章'),
                                          ],
                                        ),
                                      ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '删除',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'edit':
                                        _showEditArticleDialog(article);
                                        break;
                                      case 'set_today':
                                        _setTodayArticle(article['id']);
                                        break;
                                      case 'delete':
                                        _deleteArticle(article['id']);
                                        break;
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
          // 名言管理页面
          RefreshIndicator(
            onRefresh: _loadQuotes,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
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
                  const SizedBox(height: 32),
                  const Divider(),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '名言列表',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh),
                        onPressed: _isLoadingQuotes ? null : _loadQuotes,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _isLoadingQuotes
                      ? const Center(child: CircularProgressIndicator())
                      : _quotes.isEmpty
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: Text('暂无名言'),
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _quotes.length,
                          itemBuilder: (context, index) {
                            final quote = _quotes[index];
                            final isToday = quote['is_today'] == 1;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              color: isToday ? Colors.blue.shade50 : null,
                              child: ListTile(
                                title: Text(
                                  quote['content'] ?? '',
                                  style: TextStyle(
                                    fontWeight: isToday
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('作者: ${quote['author'] ?? ''}'),
                                    if (quote['category'] != null &&
                                        quote['category'].toString().isNotEmpty)
                                      Text('分类: ${quote['category']}'),
                                    if (isToday)
                                      const Text(
                                        '⭐ 今日名言',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                  ],
                                ),
                                trailing: PopupMenuButton(
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                      value: 'edit',
                                      child: Row(
                                        children: [
                                          Icon(Icons.edit, size: 20),
                                          SizedBox(width: 8),
                                          Text('编辑'),
                                        ],
                                      ),
                                    ),
                                    if (!isToday)
                                      const PopupMenuItem(
                                        value: 'set_today',
                                        child: Row(
                                          children: [
                                            Icon(Icons.star, size: 20),
                                            SizedBox(width: 8),
                                            Text('设为今日名言'),
                                          ],
                                        ),
                                      ),
                                    const PopupMenuItem(
                                      value: 'delete',
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            size: 20,
                                            color: Colors.red,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            '删除',
                                            style: TextStyle(color: Colors.red),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                  onSelected: (value) {
                                    switch (value) {
                                      case 'edit':
                                        _showEditQuoteDialog(quote);
                                        break;
                                      case 'set_today':
                                        _setTodayQuote(quote['id']);
                                        break;
                                      case 'delete':
                                        _deleteQuote(quote['id']);
                                        break;
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
