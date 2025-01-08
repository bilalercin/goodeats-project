import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:image_picker/image_picker.dart';

class RequestPage extends StatefulWidget {
  const RequestPage({super.key});

  @override
  State<RequestPage> createState() => _RequestPageState();
}

class _RequestPageState extends State<RequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  Position? _currentPosition;
  bool _isLoading = false;
  LatLng? _selectedLocation;
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;
  String? _base64Image;
  final ImagePicker _picker = ImagePicker();
  bool _showMap = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentPosition = position;
        if (_selectedLocation == null) {
          _selectedLocation = LatLng(position.latitude, position.longitude);
        }
      });
    } catch (e) {
      print("Konum alınamadı: $e");
    }
  }

  Future<void> _showTimePickerSheet(bool isStart) async {
    final times = [
      '08:00', '09:00', '10:00', '11:00', '12:00',
      '13:00', '14:00', '15:00', '16:00', '17:00',
      '18:00', '19:00', '20:00', '21:00', '22:00'
    ];

    await showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 200,
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                isStart ? 'Select Start Time' : 'Select End Time',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: times.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(times[index], textAlign: TextAlign.center),
                      onTap: () {
                        final parts = times[index].split(':');
                        setState(() {
                          if (isStart) {
                            _startTime = TimeOfDay(
                              hour: int.parse(parts[0]),
                              minute: int.parse(parts[1]),
                            );
                          } else {
                            _endTime = TimeOfDay(
                              hour: int.parse(parts[0]),
                              minute: int.parse(parts[1]),
                            );
                          }
                        });
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024, // Resmi küçült
        maxHeight: 1024,
        imageQuality: 70, // Kaliteyi düşür
      );
      
      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          _base64Image = base64Encode(bytes);
        });
      }
    } catch (e) {
      print('Resim seçilirken hata: $e');
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate() || 
        _selectedLocation == null || 
        _startTime == null || 
        _endTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        try {
          // Kullanıcının hayır kurumu olup olmadığını kontrol et
          final userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();
          
          final isCharity = userDoc.data()?['userType'] == 'charity';

          final ticketData = {
            'title': _titleController.text,
            'description': _descriptionController.text,
            'location': GeoPoint(_selectedLocation!.latitude, _selectedLocation!.longitude),
            'startTime': _formatTimeOfDay(_startTime!),
            'endTime': _formatTimeOfDay(_endTime!),
            'status': 'active',
            'userEmail': user.email,
            'userId': user.uid,
            'createdAt': FieldValue.serverTimestamp(),
            'isCharityTicket': isCharity,
            if (_base64Image != null) 'imageBase64': _base64Image,
          };

          await FirebaseFirestore.instance.collection('tickets').add(ticketData);

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket created successfully')),
            );
            _titleController.clear();
            _descriptionController.clear();
            setState(() {
              _selectedLocation = null;
              _startTime = null;
              _endTime = null;
              _base64Image = null;
            });
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: $e')),
            );
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getLocationButtonText() {
    if (_selectedLocation == null) {
      return 'Select Location';
    }
    return _showMap ? 'Edit Location' : 'Edit Location';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Başlık ve Açıklama
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Konum Seçimi
                    OutlinedButton.icon(
                      onPressed: () {
                        setState(() {
                          if (_showMap && _selectedLocation != null) {
                            _showMap = false;
                          } else {
                            _showMap = true;
                          }
                        });
                      },
                      icon: const Icon(Icons.location_on),
                      label: Text(_getLocationButtonText()),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: HexColor("#00bf63")),
                        foregroundColor: HexColor("#00bf63"),
                      ),
                    ),
                    if (_selectedLocation != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Selected Location: ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                          style: const TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (_showMap) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 250,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: FlutterMap(
                                options: MapOptions(
                                  center: _selectedLocation ?? 
                                      (_currentPosition != null 
                                          ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                                          : const LatLng(41.0082, 28.9784)),
                                  zoom: 13.0,
                                  onTap: (tapPosition, point) {
                                    setState(() {
                                      _selectedLocation = point;
                                    });
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                    userAgentPackageName: 'com.example.app',
                                  ),
                                  if (_selectedLocation != null)
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: _selectedLocation!,
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.red,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),

                    // Zaman Seçimi
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showTimePickerSheet(true),
                            child: Text(
                              _startTime == null
                                  ? 'Start Time'
                                  : 'Start: ${_formatTimeOfDay(_startTime!)}',
                              style: TextStyle(color: HexColor("#00bf63")),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => _showTimePickerSheet(false),
                            child: Text(
                              _endTime == null
                                  ? 'End Time'
                                  : 'End: ${_formatTimeOfDay(_endTime!)}',
                              style: TextStyle(color: HexColor("#00bf63")),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Fotoğraf Ekleme
                    if (_base64Image != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.memory(
                          base64Decode(_base64Image!),
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    OutlinedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.photo_camera),
                      label: Text(_base64Image == null ? 'Add Photo' : 'Change Photo'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: HexColor("#00bf63")),
                        foregroundColor: HexColor("#00bf63"),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Gönder Butonu
                    ElevatedButton(
                      onPressed: _isLoading ? null : _submitRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: HexColor("#00bf63"),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white),
                            )
                          : const Text(
                              'Create Ticket',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
} 