import 'package:flutter/material.dart';
import 'package:greenlink_front/screen/auth/loginPage.dart';
import 'package:greenlink_front/screen/auth/signup_page.dart';
import 'package:greenlink_front/screen/home/home_page.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  KakaoSdk.init(
    nativeAppKey: const String.fromEnvironment(
      'KAKAO_NATIVE_APP_KEY',
      defaultValue: 'YOUR_KAKAO_NATIVE_APP_KEY',
    ),
  );
  runApp(const GreenLinkApp());
}

class GreenLinkApp extends StatefulWidget {
  const GreenLinkApp({super.key});

  @override
  State<GreenLinkApp> createState() => _GreenLinkAppState();
}

class _GreenLinkAppState extends State<GreenLinkApp> {
  bool _isDarkMode = false; // 기본 라이트 모드

  ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF3F5F7),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF8EA86C),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xFF1A1A1A),
        elevation: 0,
      ),
    );
  }

  ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0F0F0F),
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFE4F3A3),
        brightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greenlink',
      debugShowCheckedModeBanner: false,
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: _isDarkMode ? ThemeMode.dark : ThemeMode.light,
      
      // 1. 앱 실행 시 처음 보여줄 페이지
      initialRoute: '/login', 
      
      // 2. 페이지 경로(이름) 설정
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => HomePage(
              isDarkMode: _isDarkMode,
              onDarkModeChanged: (isDark) {
                setState(() => _isDarkMode = isDark);
              },
            ),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}
