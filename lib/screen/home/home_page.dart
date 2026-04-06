import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:greenlink_front/screen/home/tabs/home_tab.dart';
import 'package:greenlink_front/screen/home/tabs/sub_tab.dart';
import 'package:greenlink_front/screen/home/tabs/encyclopedia_tab.dart';

/// 홈(메인)/부/도감 3개 탭 하단 네비 컨테이너
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _tabIndex = 0; // 0: 홈, 1: 부, 2: 도감

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeTab(),
      const SubTab(),
      const EncyclopediaTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: Stack(
        children: [
          _buildBackgroundGlow(),
          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: IndexedStack(
                key: ValueKey(_tabIndex),
                index: _tabIndex,
                children: pages,
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildBottomNav() {
    const items = [
      _NavItem(icon: Icons.home, label: "홈"),
      _NavItem(icon: Icons.nature, label: "부"),
      _NavItem(icon: Icons.menu_book, label: "도감"),
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F0F0F),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 16, offset: const Offset(0, -6)),
        ],
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _navPill(
                  icon: items[i].icon,
                  label: items[i].label,
                  active: _tabIndex == i,
                  onTap: () => setState(() => _tabIndex = i),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _navPill({required IconData icon, required String label, required bool active, required VoidCallback onTap}) {
    final bg = active ? const Color(0xFFE4F3A3).withOpacity(0.22) : Colors.white.withOpacity(0.05);
    final color = active ? const Color(0xFFE4F3A3) : Colors.white38;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: const Color(0xFFE4F3A3).withOpacity(0.35),
                    blurRadius: 18,
                    spreadRadius: -4,
                  )
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(height: 4),
            Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundGlow() {
    return Stack(
      children: [
        Positioned(
          left: -60,
          top: 120,
          child: _glowCircle(const Color(0xFFE4F3A3), 280),
        ),
        Positioned(
          right: -80,
          bottom: 120,
          child: _glowCircle(const Color(0xFFB6D7FF), 260),
        ),
      ],
    );
  }

  Widget _glowCircle(Color color, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withOpacity(0.08),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.3), blurRadius: 90, spreadRadius: 10),
        ],
      ),
    );
  }
}

class _NavItem {
  const _NavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}
