import 'package:flutter/material.dart';
import 'package:greenlink_front/screen/home/widgets/common_glass.dart';

class EncyclopediaTab extends StatelessWidget {
  const EncyclopediaTab({super.key});

  @override
  Widget build(BuildContext context) {
    final plants = List.generate(6, (i) => "식물${i + 1}");
    return SingleChildScrollView(
      key: const ValueKey('encyclopedia_tab'),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("식물도감 페이지", style: TextStyle(color: Colors.white70, fontSize: 18, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: plants.length,
            itemBuilder: (_, idx) => glassCard(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.local_florist, color: Colors.lightGreenAccent, size: 32),
                  const SizedBox(height: 8),
                  Text(plants[idx], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
