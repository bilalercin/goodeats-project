import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcı kaydı
  Future<UserCredential> registerUser({
    required String name,
    required String surname,
    required String email,
    required String password,
  }) async {
    try {
      // Giriş bilgilerini doğrula
      if (email.isEmpty || !email.contains('@')) {
        throw 'Geçerli bir e-posta adresi giriniz';
      }
      if (password.length < 6) {
        throw 'Şifre en az 6 karakter olmalıdır';
      }
      if (name.isEmpty || surname.isEmpty) {
        throw 'Ad ve soyad alanları boş bırakılamaz';
      }

      // Firebase Authentication ile kullanıcı oluştur
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Kullanıcı profil bilgilerini güncelle
      await userCredential.user?.updateDisplayName('$name $surname');

      // Kullanıcı bilgilerini Firestore'a kaydet
      await _saveUserData(
        uid: userCredential.user!.uid,
        name: name,
        surname: surname,
        email: email,
      );

      return userCredential;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw 'Bu e-posta adresi zaten kullanımda';
        case 'invalid-email':
          throw 'Geçersiz e-posta adresi';
        case 'operation-not-allowed':
          throw 'E-posta/şifre hesapları etkin değil';
        case 'weak-password':
          throw 'Şifre çok zayıf';
        default:
          throw 'Kayıt işlemi başarısız: ${e.message}';
      }
    } catch (e) {
      throw 'Beklenmeyen bir hata oluştu: $e';
    }
  }

  // Kullanıcı bilgilerini Firestore'a kaydet
  Future<void> _saveUserData({
    required String uid,
    required String name,
    required String surname,
    required String email,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'name': name,
        'surname': surname,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
        'isActive': true,
      });
    } catch (e) {
      throw 'Kullanıcı bilgileri kaydedilemedi: $e';
    }
  }

  // Kullanıcı bilgilerini güncelle
  Future<void> updateUserData({
    required String uid,
    String? name,
    String? surname,
    String? email,
  }) async {
    try {
      final Map<String, dynamic> updates = {
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (name != null) updates['name'] = name;
      if (surname != null) updates['surname'] = surname;
      if (email != null) updates['email'] = email;

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      throw 'Kullanıcı bilgileri güncellenemedi: $e';
    }
  }
}
