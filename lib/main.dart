import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'config/naver_map_key.dart';
import 'firebase_options.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FlutterNaverMap().init(clientId: naverMapClientId);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '맠카로드',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // 맠카님 테마 색상
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00887A)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
