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

class GreenLinkApp extends StatelessWidget {
  const GreenLinkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Greenlink',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: Brightness.dark), // 어두운 테마 유지
      
      // 1. 앱 실행 시 처음 보여줄 페이지
      initialRoute: '/login', 
      
      // 2. 페이지 경로(이름) 설정
      routes: {
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
        '/signup': (context) => const SignUpPage(),
      },
    );
  }
}
