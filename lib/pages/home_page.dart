import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:goodeats/chat_pages/chat_list_page.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'map_page.dart';
import 'profile_page.dart';
import 'request_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool _isCharity = false;
  
  @override
  void initState() {
    super.initState();
    _checkUserType();
  }

  Future<void> _checkUserType() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userData.exists) {
        setState(() {
          _isCharity = userData.data()?['userType'] == 'charity';
        });
      }
    }
  }

  List<Widget> get _pages => [
    const HomeContent(),
    const ChatListPage(),
    if (!_isCharity) const MapPage(),
    const RequestPage(),
    const ProfilePage(),
  ];

  List<BottomNavigationBarItem> get _navigationItems => [
    const BottomNavigationBarItem(
      icon: Icon(Icons.home),
      label: 'Home',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.chat),
      label: 'Messages',
    ),
    if (!_isCharity) const BottomNavigationBarItem(
      icon: Icon(Icons.map),
      label: 'Map',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.add_location),
      label: 'Ticket',
    ),
    const BottomNavigationBarItem(
      icon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "GoodEATS",
          style: TextStyle(
            fontSize: 35,
            fontWeight: FontWeight.w500,
            color: HexColor("#00bf63"),
          ),
        ),
        elevation: 5,
        centerTitle: true,
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: HexColor("#00bf63"),
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _navigationItems,
      ),
    );
  }
}

// Ana sayfa içeriği için ayrı bir widget
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome!',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: HexColor("#00bf63"),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Latest Tickets',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseAuth.instance.currentUser != null
                ? FirebaseFirestore.instance
                    .collection('tickets')
                    .orderBy('createdAt', descending: true)
                    .snapshots()
                : null,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text('An error occurred'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No tickets shared yet'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final ticket = snapshot.data!.docs[index];
                    final data = ticket.data() as Map<String, dynamic>;
                    
                    return Card(
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Row(
                          children: [
                            Expanded(
                              child: Text(
                                data['title'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            if (data['isCharityTicket'] == true)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: HexColor("#00bf63").withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  'Charity',
                                  style: TextStyle(
                                    color: HexColor("#00bf63"),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            Text(data['description'] ?? ''),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.access_time, 
                                  size: 16, 
                                  color: HexColor("#00bf63")
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${data['startTime']} - ${data['endTime']}',
                                  style: TextStyle(
                                    color: HexColor("#00bf63"),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.person, 
                                  size: 16, 
                                  color: Colors.grey[600]
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  data['userEmail'] ?? '',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: data['imageBase64'] != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  base64Decode(data['imageBase64']),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : null,
                        onTap: () {
                          // Ticket detaylarını göstermek için bir dialog
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text(data['title'] ?? ''),
                              content: SingleChildScrollView(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (data['imageBase64'] != null) ...[
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(8),
                                        child: Image.memory(
                                          base64Decode(data['imageBase64']),
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                    ],
                                    Text(data['description'] ?? ''),
                                    const SizedBox(height: 16),
                                    Text('Time: ${data['startTime']} - ${data['endTime']}'),
                                    const SizedBox(height: 8),
                                    Text('Contact: ${data['userEmail']}'),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
