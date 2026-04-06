import 'package:flutter/material.dart';
import 'package:greenlink_front/data/auth_service.dart';

/// 회원가입 화면 - 백엔드 DTO(username, password, email, nickname, phoneNumber, address)에 맞춤
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _username = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _nickname = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _auth = AuthService();
  bool _loading = false;

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _nickname.dispose();
    _phone.dispose();
    _address.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white70),
        title: const Text("회원가입", style: TextStyle(color: Colors.white70)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              _input("아이디", _username, Icons.person_outline),
              const SizedBox(height: 14),
              _input("이메일", _email, Icons.email_outlined),
              const SizedBox(height: 14),
              _input("비밀번호", _password, Icons.lock_outline, obscure: true),
              const SizedBox(height: 14),
              _input("닉네임", _nickname, Icons.face_2_outlined),
              const SizedBox(height: 14),
              _input("전화번호", _phone, Icons.phone_iphone),
              const SizedBox(height: 14),
              _input("주소", _address, Icons.home_outlined),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4F3A3),
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: _loading ? null : _onSignup,
                  child: _loading
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Text("가입하기", style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c, IconData icon, {bool obscure = false}) {
    return TextField(
      controller: c,
      obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: Icon(icon, color: Colors.white54),
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      ),
    );
  }

  Future<void> _onSignup() async {
    if (_username.text.isEmpty || _email.text.isEmpty || _password.text.isEmpty) {
      _toast("아이디/이메일/비밀번호는 필수입니다.");
      return;
    }
    setState(() => _loading = true);
    try {
      await _auth.signup(
        username: _username.text.trim(),
        password: _password.text,
        email: _email.text.trim(),
        nickname: _nickname.text.trim(),
        phoneNumber: _phone.text.trim(),
        address: _address.text.trim(),
      );
      if (!mounted) return;
      _toast("회원가입 성공! 로그인해주세요.");
      Navigator.pop(context);
    } catch (e) {
      _toast("회원가입 실패: $e");
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
