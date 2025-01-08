import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hexcolor/hexcolor.dart';
import 'chat_page.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  State<ChatListPage> createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 60),
        child: StreamBuilder<QuerySnapshot>(
          stream: _firestore
              .collection('users')
              .where(FieldPath.documentId, isNotEqualTo: _auth.currentUser!.uid)
              .snapshots(),
          builder: (context, userSnapshot) {
            if (userSnapshot.hasError) {
              return Center(child: Text('An error occurred'));
            }

            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!userSnapshot.hasData || userSnapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No messages yet'));
            }

            final users = userSnapshot.data?.docs ?? [];

            if (users.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 80, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz başka kullanıcı yok',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              );
            }

            return StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chat_rooms')
                  .where('participants', arrayContains: _auth.currentUser!.uid)
                  .orderBy('lastMessageTime', descending: true)
                  .snapshots(),
              builder: (context, chatSnapshot) {
                final chatRooms = chatSnapshot.data?.docs ?? [];
                
                Map<String, Map<String, dynamic>> chatRoomMap = {};
                for (var room in chatRooms) {
                  final data = room.data() as Map<String, dynamic>;
                  final participants = List<String>.from(data['participants'] ?? []);
                  final otherUserId = participants.firstWhere(
                    (id) => id != _auth.currentUser!.uid,
                    orElse: () => '',
                  );
                  if (otherUserId.isNotEmpty) {
                    chatRoomMap[otherUserId] = data;
                  }
                }

                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final userData = users[index].data() as Map<String, dynamic>?;
                    final userId = users[index].id;
                    
                    if (userData == null) return const SizedBox();

                    final chatRoom = chatRoomMap[userId];
                    final hasChat = chatRoom != null;
                    final lastMessage = hasChat ? chatRoom['lastMessage'] as String? : null;
                    final lastSenderId = hasChat ? chatRoom['lastSenderId'] as String? : null;
                    final lastMessageTime = hasChat ? chatRoom['lastMessageTime'] as Timestamp? : null;

                    String subtitle = 'Sohbet başlatmak için tıklayın';
                    if (hasChat && lastMessage != null && lastSenderId != null) {
                      subtitle = lastSenderId == _auth.currentUser!.uid
                          ? 'Siz: $lastMessage'
                          : '${userData['email']}: $lastMessage';
                    }

                    return ListTile(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChatPage(
                              receiverUserEmail: userData['email'] ?? 'Anonim',
                              receiverUserId: userId,
                            ),
                          ),
                        );
                      },
                      leading: CircleAvatar(
                        backgroundColor: HexColor("#00bf63"),
                        child: Text(
                          (userData['email'] ?? 'A')[0].toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        userData['email'] ?? 'Anonim',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: hasChat ? Colors.black87 : Colors.grey[600],
                          fontWeight: hasChat ? FontWeight.normal : FontWeight.normal,
                        ),
                      ),
                      trailing: hasChat && lastMessageTime != null
                          ? Text(
                              _formatTimestamp(lastMessageTime),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            )
                          : null,
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    final now = DateTime.now();
    final date = timestamp.toDate();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Şimdi';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}d';
    } else if (diff.inDays < 1) {
      return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    } else if (diff.inDays == 1) {
      return 'Dün';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} gün';
    } else {
      return '${date.day}/${date.month}';
    }
  }
}