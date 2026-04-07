import 'package:flutter/material.dart';
import 'package:greenlink_front/data/resource_service.dart';
import 'package:greenlink_front/screen/home/widgets/common_glass.dart';

class QuestPage extends StatefulWidget {
  const QuestPage({super.key});

  @override
  State<QuestPage> createState() => _QuestPageState();
}

class _QuestPageState extends State<QuestPage> {
  final ResourceService _service = ResourceService();
  bool _showMine = true;
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() {
    return _showMine ? _service.fetchUserQuests() : _service.fetchQuests();
  }

  void _toggle(bool mine) {
    setState(() {
      _showMine = mine;
      _future = _load();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("퀘스트", style: TextStyle(color: Colors.white70)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: _pill("내 퀘스트", _showMine, () => _toggle(true))),
                const SizedBox(width: 10),
                Expanded(child: _pill("전체 퀘스트", !_showMine, () => _toggle(false))),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator()));
                }
                if (snapshot.hasError) {
                  return Text("불러오기 실패: ${snapshot.error}", style: const TextStyle(color: Colors.redAccent));
                }
                final data = snapshot.data ?? [];
                if (data.isEmpty) {
                  return const Text("표시할 퀘스트가 없습니다.", style: TextStyle(color: Colors.white70));
                }
                return Column(
                  children: data.map((q) {
                    final title = q['title']?.toString() ?? q['name']?.toString() ?? '퀘스트';
                    final progress = q['progress']?.toString();
                    final reward = q['reward']?.toString();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: glassCard(
                        child: ListTile(
                          title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (progress != null) Text("진행: $progress", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                              if (reward != null) Text("보상: $reward", style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            ],
                          ),
                          trailing: const Icon(Icons.bar_chart, color: Colors.white70),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.white.withOpacity(0.15) : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
        ),
        child: Center(
          child: Text(text, style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)),
        ),
      ),
    );
  }
}
