import 'package:flutter/material.dart';
import 'dart:ui';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('home_tab'),
      children: [
        const SizedBox(height: 20),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text("닉네임?", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
              _TogglePills(),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            children: [
              _GlassButton(text: "식물설명"),
              const SizedBox(height: 10),
              Row(
                children: const [
                  Expanded(child: _PillButton(text: "빛", color: Color(0xFFE4F3A3))),
                  SizedBox(width: 10),
                  Expanded(child: _PillButton(text: "물", color: Color(0xFFB6D7FF))),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 18),
        Expanded(
          child: Center(
            child: Container(
              width: 240,
              height: 320,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFE4F3A3).withOpacity(0.35),
                    blurRadius: 45,
                    spreadRadius: -10,
                    offset: const Offset(0, 24),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Image.asset(
                  'assets/images/home_main.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _missingImagePlaceholder("home_main.png"),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _TogglePills extends StatelessWidget {
  const _TogglePills();
  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        _CircleToggle(label: "빛", activeColor: Color(0xFFE4F3A3), active: true),
        SizedBox(width: 10),
        _CircleToggle(label: "물", activeColor: Color(0xFFB6D7FF), active: true),
      ],
    );
  }
}

class _CircleToggle extends StatelessWidget {
  const _CircleToggle({required this.label, required this.activeColor, required this.active});
  final String label;
  final Color activeColor;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final color = active ? activeColor : Colors.white24;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: active
            ? [
                BoxShadow(color: color.withOpacity(0.5), blurRadius: 12, spreadRadius: 2),
              ]
            : [],
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({required this.text, required this.color});
  final String text;
  final Color color;
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.8),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.5), blurRadius: 16, spreadRadius: -2),
        ],
      ),
      child: Text(text, style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w700)),
    );
  }
}

class _GlassButton extends StatelessWidget {
  const _GlassButton({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}

Widget _missingImagePlaceholder(String name) {
  return Container(
    color: Colors.black12,
    child: Center(
      child: Text("$name 추가 필요", style: const TextStyle(color: Colors.white54)),
    ),
  );
}
