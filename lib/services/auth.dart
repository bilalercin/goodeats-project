import 'package:firebase_auth/firebase_auth.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Mevcut kullanıcıyı al
  User? get currentUser => _firebaseAuth.currentUser;

  // Kullanıcı durumu stream'i
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Yeni kullanıcı oluştur
  Future<UserCredential> createUser({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'Bu e-posta adresi zaten kullanımda';
        case 'weak-password':
          throw 'Şifre çok zayıf';
        case 'invalid-email':
          throw 'Geçersiz e-posta adresi';
        default:
          throw 'Bir hata oluştu: ${e.message}';
      }
    }
  }

  // Giriş yap
  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw 'Kullanıcı bulunamadı';
        case 'wrong-password':
          throw 'Yanlış şifre';
        case 'user-disabled':
          throw 'Kullanıcı hesabı devre dışı bırakılmış';
        case 'invalid-email':
          throw 'Geçersiz e-posta adresi';
        default:
          throw 'Giriş yapılamadı: ${e.message}';
      }
    }
  }

  // Şifre sıfırlama
  Future<void> sendPasswordReset(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw 'Geçersiz e-posta adresi';
        case 'user-not-found':
          throw 'Bu e-posta adresiyle kayıtlı kullanıcı bulunamadı';
        default:
          throw 'Şifre sıfırlama e-postası gönderilemedi: ${e.message}';
      }
    }
  }

  // Çıkış yap
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // E-posta doğrulama
  Future<void> sendEmailVerification() async {
    try {
      await _firebaseAuth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw 'E-posta doğrulama gönderilemedi: ${e.message}';
    }
  }
}