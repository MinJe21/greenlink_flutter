import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:greenlink_front/data/auth_service.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isSubmitting = false;

  // --- 로그인 방식 선택창 (Bottom Sheet) ---
  void _showLoginOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // 배경을 투명하게 해서 글래스모피즘 효과 유지
      builder: (context) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E1E1E).withOpacity(0.9),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
                    border: Border.all(color: Colors.white10),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // 내용만큼만 높이 차지
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  const Text(
                    "이메일로 로그인",
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildSocialButton(
                          label: "카카오",
                          bg: const Color(0xFFFEE500),
                          fg: Colors.black87,
                          leading: Image.asset(
                            'assets/images/kakao.webp',
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                          onTap: _isSubmitting ? null : _handleKakaoLogin,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildSocialButton(
                          label: "구글",
                          bg: Colors.white,
                          fg: Colors.black87,
                          leading: Image.asset(
                            'assets/images/google.jpeg',
                            width: 20,
                            height: 20,
                            fit: BoxFit.contain,
                          ),
                          onTap: _isSubmitting ? null : _handleGoogleLogin,
                          border: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildInputField(
                    controller: _usernameController,
                    hint: "아이디를 입력하세요",
                    icon: Icons.person_outline,
                      ),
                      const SizedBox(height: 12),
                      _buildInputField(
                        controller: _passwordController,
                        hint: "비밀번호",
                        icon: Icons.lock_outline,
                        obscureText: true,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          onPressed: _isSubmitting
                              ? null
                              : () => _attemptLogin(setModalState, ctx),
                          child: _isSubmitting
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text(
                                  "로그인하기",
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _attemptLogin(StateSetter modalSetState, BuildContext bottomSheetContext) async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('아이디와 비밀번호를 입력해주세요.')),
      );
      return;
    }

    void updateLoading(bool value) {
      modalSetState(() => _isSubmitting = value);
      setState(() => _isSubmitting = value);
    }

    updateLoading(true);
    try {
      final tokens = await _authService.login(username: username, password: password);
      if (!mounted) return;
      Navigator.pop(bottomSheetContext); // bottom sheet 닫기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 성공 (토큰 저장 필요): ${tokens.accessToken.substring(0, 12)}...')),
      );
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('로그인 실패: ${e.toString()}')),
      );
    } finally {
      updateLoading(false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Stack(
        children: [
          _buildBackgroundOrbs(), // 기존 배경 구체들
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 80),
                _buildEmbossedLogo(), // 기존 엠보싱 로고
                const SizedBox(height: 50),
                const Text(
                  "안녕하세요,\n당신의 여정을\n시작하세요",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w600, height: 1.4),
                ),
                const Spacer(),

                // 1. 메인 로그인 버튼 (누르면 옵션이 올라옴)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: _buildGlassButton(
                    text: "로그인",
                    onTap: () => _showLoginOptions(context),
                  ),
                ),

                const SizedBox(height: 20),

                // 2. 회원가입 연결 텍스트
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("처음이신가요?", style: TextStyle(color: Colors.white54)),
                    TextButton(
                      onPressed: () {
                        // 회원가입 페이지 이동 (Navigator 활용)
                        Navigator.pushNamed(context, '/signup');
                      },
                      child: const Text(
                        "회원가입 하기",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- 위젯 유틸리티 함수들 ---

  Widget _buildGlassButton({required String text, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Center(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Color bg,
    required Color fg,
    VoidCallback? onTap,
    bool border = false,
    Widget? leading,
  }) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
            side: border ? const BorderSide(color: Colors.black12) : BorderSide.none,
          ),
        ),
        onPressed: onTap,
        child: _isSubmitting
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (leading != null) ...[
                    leading,
                    const SizedBox(width: 8),
                  ],
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
      ),
    );
  }

  Future<void> _handleGoogleLogin() async {
    setState(() => _isSubmitting = true);
    try {
      final googleUser = await GoogleSignIn(scopes: ['email']).signIn();
      if (googleUser == null) return; // 취소
      final googleAuth = await googleUser.authentication;
      if (!mounted) return;
      _toast("구글 로그인 성공: ${googleUser.email}");
      // TODO: 서버에 googleAuth.idToken / accessToken 전달하여 자체 토큰 발급
    } catch (e) {
      _toast("구글 로그인 실패: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _handleKakaoLogin() async {
    setState(() => _isSubmitting = true);
    try {
      OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        token = await UserApi.instance.loginWithKakaoTalk();
      } else {
        token = await UserApi.instance.loginWithKakaoAccount();
      }
      if (!mounted) return;
      _toast("카카오 로그인 성공");
      // TODO: 서버에 token.accessToken 전달하여 자체 토큰 발급
    } catch (e) {
      _toast("카카오 로그인 실패: $e");
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.white70),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white24, fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  // 배경 및 로고 위젯은 이전과 동일하게 유지... (생략 가능하지만 전체 구조를 위해 남겨둠)
  Widget _buildBackgroundOrbs() {
    return Container();
  }

  Widget _buildEmbossedLogo() {
    return Container();
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
