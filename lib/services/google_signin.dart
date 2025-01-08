import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class GoogleSignInService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Google ile giriş yap
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Google Sign-In akışını başlat
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      // Google kimlik bilgilerini al
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Firebase kimlik bilgilerini oluştur
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase ile giriş yap
      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      // Kullanıcı bilgilerini Firestore'a kaydet
      if (userCredential.user != null) {
        await _saveUserToFirestore(userCredential.user!);
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'account-exists-with-different-credential':
          throw 'Bu e-posta adresi başka bir giriş yöntemi ile ilişkilendirilmiş';
        case 'invalid-credential':
          throw 'Geçersiz kimlik bilgileri';
        case 'operation-not-allowed':
          throw 'Google ile giriş şu anda devre dışı';
        case 'user-disabled':
          throw 'Kullanıcı hesabı devre dışı bırakılmış';
        default:
          throw 'Google ile giriş yapılamadı: ${e.message}';
      }
    } catch (e) {
      throw 'Beklenmeyen bir hata oluştu: $e';
    }
  }

  // Kullanıcı bilgilerini Firestore'a kaydet
  Future<void> _saveUserToFirestore(User user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'photoURL': user.photoURL,
        'lastSignIn': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Kullanıcı bilgileri kaydedilemedi: $e');
    }
  }

  // Google ile çıkış yap
  Future<void> signOut(BuildContext context) async {
    try {
      await Future.wait([
        _auth.signOut(),
        _googleSignIn.signOut(),
      ]);
      
      // Login sayfasına yönlendir
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/login',
        (route) => false,
      );
    } catch (e) {
      throw 'Çıkış yapılırken bir hata oluştu: $e';
    }
  }

  // Mevcut kullanıcıyı al
  User? get currentUser => _auth.currentUser;

  // Kullanıcı durumu değişikliklerini dinle
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}