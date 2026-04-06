import 'dart:ui';
import 'package:flutter/material.dart';

Widget glassCard({required Widget child}) {
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
        child: child,
      ),
    ),
  );
}

Widget glassButton({required String text, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: glassCard(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        ),
      ),
    ),
  );
}
