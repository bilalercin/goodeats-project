import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:goodeats/firebase_options.dart';
import 'package:goodeats/pages/login_page.dart';
import 'package:goodeats/pages/home_page.dart';
import 'package:goodeats/onboarding/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Debug modunda reCAPTCHA'yı devre dışı bırak
  if (kDebugMode) {
    await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  }

  // Mevcut oturum kontrolü
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    // Kullanıcı verilerini kontrol et
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    // Eğer kullanıcı verisi yoksa oluştur
    if (!userDoc.exists) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({
        'email': user.email,
        'userType': 'default',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  final prefs = await SharedPreferences.getInstance();
  final bool isFirstTime = prefs.getBool('isFirstTime') ?? true;

  runApp(MyApp(isFirstTime: isFirstTime, isLoggedIn: user != null));
}

class MyApp extends StatelessWidget {
  final bool isFirstTime;
  final bool isLoggedIn;
  const MyApp({super.key, required this.isFirstTime, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GoodEats',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: isFirstTime ? '/onboarding' : (isLoggedIn ? '/home' : '/login'),
      routes: {
        '/onboarding': (context) => const OnboardingPage(),
        '/login': (context) => const LoginPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
