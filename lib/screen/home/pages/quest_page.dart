import 'package:flutter/material.dart';
import 'package:greenlink_front/screen/home/widgets/common_glass.dart';

class QuestPage extends StatelessWidget {
  const QuestPage({super.key});

  @override
  Widget build(BuildContext context) {
    final quests = List.generate(5, (i) => "퀘스트");
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
            ...quests.map((q) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: glassCard(
                    child: ListTile(
                      title: Text(q, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                      trailing: const Icon(Icons.bar_chart, color: Colors.white70),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
