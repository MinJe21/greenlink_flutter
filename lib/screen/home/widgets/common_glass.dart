import 'dart:ui';
import 'package:flutter/material.dart';

Widget glassCard({required Widget child}) {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withOpacity(0.06) : Colors.black.withOpacity(0.04),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: isDark ? Colors.white.withOpacity(0.12) : Colors.black12),
            ),
            child: child,
          ),
        ),
      );
    },
  );
}

Widget glassButton({required String text, required VoidCallback onTap}) {
  return Builder(
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return GestureDetector(
        onTap: onTap,
        child: glassCard(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                text,
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF1A1A1A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
