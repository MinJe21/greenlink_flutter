import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:greenlink_front/screen/home/pages/inventory_page.dart';
import 'package:greenlink_front/screen/home/pages/quest_page.dart';
import 'package:greenlink_front/screen/home/widgets/common_glass.dart';

class SubTab extends StatelessWidget {
  const SubTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      key: const ValueKey('sub_tab'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 4),
          const Text("부 페이지", style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          glassCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("닉네임?", style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _pillButton("퀘스트1", const Color(0xFFDDF8A5), () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestPage()));
                      }),
                      const SizedBox(width: 12),
                      _pillButton("퀘스트2", const Color(0xFFF5C6B0), () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestPage()));
                      }),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _buildCalendar(),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: glassButton(
                      text: "인벤토리",
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryPage())),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pillButton(String text, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.8),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.5), blurRadius: 16, spreadRadius: -2),
          ],
        ),
        child: Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildCalendar() {
    final days = [
      " ", " ", " ", " ", "1", "2", "3",
      "4", "5", "6", "7", "8", "9", "10",
      "11", "12", "13", "14", "15", "16", "17",
      "18", "19", "20", "21", "22", "23", "24",
      "25", "26", "27", "28", "29", "30", "31",
    ];
    final marks = {5: "🙂", 6: "🙂", 9: "🙂", 12: "😐", 14: "😀", 21: "😀", 23: "😀", 24: "🙂", 25: "🙂"};
    return glassCard(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
        child: Column(
          children: [
            const Text("5월", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 6,
                crossAxisSpacing: 6,
                childAspectRatio: 1.1,
              ),
              itemCount: days.length,
              itemBuilder: (context, index) {
                final label = days[index];
                final mark = marks[index] ?? "";
                final isToday = label == "23";
                return Container(
                  decoration: BoxDecoration(
                    color: isToday ? const Color(0xFFE4F3A3).withOpacity(0.22) : Colors.white.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(label, style: TextStyle(color: Colors.white.withOpacity(label.trim().isEmpty ? 0.2 : 0.9), fontSize: 12)),
                        if (mark.isNotEmpty) Text(mark, style: const TextStyle(fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
