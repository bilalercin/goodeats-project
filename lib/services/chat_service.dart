import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Mesaj gönderme
  Future<void> sendMessage(String receiverId, String message) async {
    // Geçerli kullanıcı bilgileri
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();

    // Yeni mesaj
    Message newMessage = Message(
      senderId: currentUserId,
      senderEmail: currentUserEmail,
      receiverId: receiverId,
      message: message,
      timestamp: timestamp,
    );

    // Chat odası ID'si oluştur
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // ID'leri sırala ki her zaman aynı sırada olsun
    String chatRoomId = ids.join("_");

    // Mesajı Firestore'a kaydet
    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());

    // Chat odasını güncelle
    await _firestore.collection('chat_rooms').doc(chatRoomId).set({
      'participants': [currentUserId, receiverId],
      'lastMessage': message,
      'lastMessageTime': timestamp,
      'lastSenderId': currentUserId,
    }, SetOptions(merge: true));
  }

  // Mesajları getir
  Stream<QuerySnapshot> getMessages(String userId) {
    List<String> ids = [_firebaseAuth.currentUser!.uid, userId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Sohbet listesini getir
  Stream<QuerySnapshot> getChatRooms() {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: _firebaseAuth.currentUser!.uid)
        .snapshots();
  }

  // Kullanıcı listesini getir
  Stream<QuerySnapshot> getAllUsers() {
    return _firestore
        .collection('users')
        .where('uid', isNotEqualTo: _firebaseAuth.currentUser!.uid)
        .snapshots();
  }
}

// Mesaj modeli
class Message {
  final String senderId;
  final String senderEmail;
  final String receiverId;
  final String message;
  final Timestamp timestamp;

  Message({
    required this.senderId,
    required this.senderEmail,
    required this.receiverId,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'senderEmail': senderEmail,
      'receiverId': receiverId,
      'message': message,
      'timestamp': timestamp,
    };
  }
}