import 'package:flutter/material.dart';
import 'package:greenlink_front/screen/home/widgets/common_glass.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = List.generate(6, (i) => "아이템${i + 1}");
    final icons = [
      Icons.water_drop,
      Icons.cleaning_services,
      Icons.biotech,
      Icons.favorite,
      Icons.grass,
      Icons.energy_savings_leaf,
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        title: const Text("인벤토리", style: TextStyle(color: Colors.white70)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.15,
          ),
          itemCount: items.length,
          itemBuilder: (_, idx) => glassCard(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icons[idx % icons.length], color: Colors.lightGreenAccent, size: 30),
                const SizedBox(height: 8),
                Text(items[idx], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
