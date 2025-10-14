import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('每日精选')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          SectionCard(title: '今日文章', content: '人生若只如初见……'),
          SectionCard(title: '今日名言', content: 'Stay hungry, stay foolish.'),
          SectionCard(title: '今日音乐', content: '🎵 《平凡之路》'),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  final String title;
  final String content;

  const SectionCard({required this.title, required this.content, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(content),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      ),
    );
  }
}
