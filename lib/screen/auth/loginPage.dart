import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 배경 디자인
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xFF1A1A1A),
            child: Stack(
              children: [
                _buildBlurCircle(const Color(0xFFD4E09B), 50, 100),
                _buildBlurCircle(const Color(0xFFB8C0FF), 500, 50),
              ],
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("😊", style: TextStyle(fontSize: 60)),
                  const SizedBox(height: 20),
                  const Text(
                    "안녕하세요,\n당신의 여정을 시작하세요",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 60),

                  // 카카오 로그인 버튼
                  _buildLoginButton(
                    text: "카카오로 시작하기",
                    color: const Color(0xFFFEE500),
                    textColor: Colors.black87,
                    onTap: () => Navigator.pushReplacementNamed(context, '/home'), // 홈으로 이동
                  ),
                  const SizedBox(height: 12),

                  // 구글 로그인 버튼
                  _buildLoginButton(
                    text: "구글로 시작하기",
                    color: Colors.white,
                    textColor: Colors.black87,
                    onTap: () => Navigator.pushReplacementNamed(context, '/home'),
                  ),
                  const SizedBox(height: 12),

                  // 자체 로그인 (이메일)
                  _buildLoginButton(
                    text: "이메일 로그인",
                    color: Colors.white.withOpacity(0.1),
                    textColor: Colors.white,
                    isBorder: true,
                    onTap: () => Navigator.pushNamed(context, '/signup'), // 회원가입/로그인 이동
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBlurCircle(Color color, double top, double left) {
    return Positioned(
      top: top,
      left: left,
      child: Container(
        width: 200, height: 200,
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 100, spreadRadius: 50)],
        ),
      ),
    );
  }

  Widget _buildLoginButton({required String text, required Color color, required Color textColor, required VoidCallback onTap, bool isBorder = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 300, height: 55,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(15),
          border: isBorder ? Border.all(color: Colors.white24) : null,
        ),
        child: Center(child: Text(text, style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w600))),
      ),
    );
  }
}