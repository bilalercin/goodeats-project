import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hexcolor/hexcolor.dart';
import '../chat_pages/chat_page.dart';
import 'dart:convert';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  Position? _currentPosition;
  final MapController _mapController = MapController();
  bool _isLoading = true;
  List<Marker> _markers = [];
  List<Map<String, dynamic>> _tickets = [];

  @override
  void initState() {
    super.initState();
    _initializeLocation();
    _loadTickets();
  }

  Future<void> _loadTickets() async {
    try {
      FirebaseFirestore.instance
          .collection('tickets')
          .where('status', isEqualTo: 'active')
          .snapshots()
          .listen((snapshot) {
        if (mounted) {
          setState(() {
            _tickets = snapshot.docs.map((doc) => doc.data()).toList();
            _markers = _tickets.map((data) {
              return Marker(
                point: LatLng(
                  data['latitude'] as double,
                  data['longitude'] as double,
                ),
                child: GestureDetector(
                  onTap: () => _showTicketPreview(data),
                  child: Icon(
                    Icons.location_on,
                    color: HexColor("#00bf63"),
                    size: 40,
                  ),
                ),
              );
            }).toList();

            // Mevcut konum marker'ını ekle
            if (_currentPosition != null) {
              _markers.add(
                Marker(
                  point: LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude,
                  ),
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                    size: 40,
                  ),
                ),
              );
            }
          });
        }
      });
    } catch (e) {
      print('Ticket yüklenirken hata: $e');
    }
  }

  void _showTicketPreview(Map<String, dynamic> ticket) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (ticket['imageBase64'] != null)
                Image.memory(
                  base64Decode(ticket['imageBase64']),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ListTile(
                title: Text(ticket['title']),
                subtitle: Text('${ticket['startTime']} - ${ticket['endTime']}'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showTicketDetails(ticket);
                },
                child: const Text('Detayları Görüntüle'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTicketDetails(Map<String, dynamic> ticket) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (ticket['imageBase64'] != null)
              Image.memory(
                base64Decode(ticket['imageBase64']),
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 16),
            Text(
              ticket['title'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(ticket['description']),
            const SizedBox(height: 8),
            Text('Saat: ${ticket['startTime']} - ${ticket['endTime']}'),
            const SizedBox(height: 8),
            Text('Oluşturan: ${ticket['userEmail']}'),
            const SizedBox(height: 8),
            Text(
              'Oluşturulma: ${(ticket['createdAt'] as Timestamp).toDate().toString()}',
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        receiverUserEmail: ticket['userEmail'],
                        receiverUserId: ticket['userId'],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: HexColor("#00bf63"),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                ),
                child: const Text('İletişime Geç'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _initializeLocation() async {
    try {
      await _getCurrentLocation();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Önce konum servislerinin açık olup olmadığını kontrol et
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen konum servislerini açın')),
          );
        }
        return;
      }

      // Konum izinlerini kontrol et
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Konum izni reddedildi')),
            );
          }
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Konum alınamadı: $e')),
        );
      }
    }
  }

  Future<void> _centerToCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      
      setState(() {
        _currentPosition = position;
      });

      // Haritayı mevcut konuma merkezle
      _mapController.move(
        LatLng(position.latitude, position.longitude),
        15.0, // zoom seviyesi
      );
    } catch (e) {
      print('Konum alınamadı: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _currentPosition == null
              ? const Center(child: Text('Konum bulunamadı'))
              : FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: LatLng(
                      _currentPosition!.latitude,
                      _currentPosition!.longitude,
                    ),
                    zoom: 15.0,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.app',
                    ),
                    MarkerLayer(
                      markers: _markers.map((marker) {
                        return Marker(
                          point: marker.point,
                          child: GestureDetector(
                            onTap: () {
                              final data = _tickets.firstWhere(
                                (t) => t['latitude'] == marker.point.latitude &&
                                      t['longitude'] == marker.point.longitude,
                              );
                              _showTicketPreview(data);
                            },
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerToCurrentLocation,
        backgroundColor: HexColor("#00bf63"),
        child: const Icon(Icons.my_location),
      ),
    );
  }
}