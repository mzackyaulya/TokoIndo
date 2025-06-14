import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce/pages/produk/produk_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class TokoPage extends StatefulWidget {
  const TokoPage({Key? key}) : super(key: key);

  @override
  _TokoPageState createState() => _TokoPageState();
}

class _TokoPageState extends State<TokoPage> {
  User? user = FirebaseAuth.instance.currentUser;
  DocumentSnapshot? tokoData;
  bool isLoading = true;
  String? tokoId; // simpan ID toko

  @override
  void initState() {
    super.initState();
    checkToko();
  }

  Future<void> checkToko() async {
    if (user == null) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    var query = await FirebaseFirestore.instance
        .collection('stores')
        .where('ownerId', isEqualTo: user!.uid)
        .limit(1)
        .get();

    if (query.docs.isNotEmpty) {
      tokoData = query.docs.first;
      tokoId = tokoData!.id;
    } else {
      tokoData = null;
      tokoId = null;
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tokoData == null) {
      // User belum punya toko → tampilkan form buat toko
      return CreateStoreWidget(onCreated: (String newTokoId) {
        tokoId = newTokoId;
        checkToko();
      });
    } else {
      // User sudah punya toko → tampilkan info toko
      return StoreDetailWidget(tokoData: tokoData!);
    }
  }
}

// Widget buat form buat toko
class CreateStoreWidget extends StatefulWidget {
  final Function(String tokoId) onCreated;
  const CreateStoreWidget({required this.onCreated, Key? key}) : super(key: key);

  @override
  _CreateStoreWidgetState createState() => _CreateStoreWidgetState();
}

class _CreateStoreWidgetState extends State<CreateStoreWidget> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();

  bool _isSaving = false;

  String? _currentAddress;
  Position? _currentPosition;
  bool _gettingLocation = false;

  Future<void> _getCurrentLocation() async {
    setState(() {
      _gettingLocation = true;
    });

    try {
      // Cek apakah lokasi aktif
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('GPS tidak aktif. Mohon aktifkan terlebih dahulu.')),
          );
        }
        return;
      }

      // Cek permission lokasi
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Izin lokasi ditolak.')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin lokasi ditolak permanen. Silakan atur di pengaturan.')),
          );
        }
        return;
      }

      // Ambil posisi saat ini dengan timeout
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _currentPosition = position;

      // Konversi ke alamat
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        String formattedAddress = '${place.subAdministrativeArea ?? ''}, ${place.administrativeArea ?? ''}';
        setState(() {
          _currentAddress = formattedAddress;
        });
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Alamat tidak ditemukan.')),
          );
        }
      }
    } on TimeoutException {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Waktu mengambil lokasi habis. Coba lagi.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal ambil lokasi: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _gettingLocation = false;
        });
      }
    }
  }

  Future<void> saveStore() async {
    if (!_formKey.currentState!.validate()) {
      if (_currentAddress == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mohon dapatkan lokasi toko terlebih dahulu')),
        );
      }
      return;
    }

    if (_currentAddress == null || _currentPosition == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mohon dapatkan lokasi toko terlebih dahulu')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final docRef = await FirebaseFirestore.instance.collection('stores').add({
        'ownerId': FirebaseAuth.instance.currentUser!.uid,
        'name': _nameController.text.trim(),
        'description': _descController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'address': _currentAddress,
        'location': GeoPoint(_currentPosition!.latitude, _currentPosition!.longitude),
      });

      widget.onCreated(docRef.id);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan toko: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Header / AppBar Custom
          Container(
            width: double.infinity,
            height: 110,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/background.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              color: Colors.black.withOpacity(0.4),
              child: const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 30),
                  child: Text(
                    'Buat Toko Anda',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Form Input
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Nama Toko',
                      hintText: 'Masukkan nama toko Anda',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: const Icon(Icons.storefront),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Nama toko harus diisi';
                      }
                      if (value.trim().length < 3) {
                        return 'Nama toko minimal 3 karakter';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 20),

                  TextFormField(
                    controller: _descController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Toko',
                      hintText: 'Ceritakan tentang toko Anda',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      prefixIcon: const Icon(Icons.description),
                      filled: true,
                      fillColor: Colors.grey.shade100,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tombol dapatkan lokasi
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _gettingLocation
                          ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.my_location),
                      label: Text(_currentAddress == null ? 'Dapatkan Lokasi Saya' : 'Lokasi: $_currentAddress'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        backgroundColor: Colors.blueAccent,
                      ),
                      onPressed: _gettingLocation ? null : _getCurrentLocation,
                    ),
                  ),

                  const SizedBox(height: 32),

                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : saveStore,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                          : const Text(
                        'Buat Toko',
                        style: TextStyle(fontSize: 18, color: Colors.black),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}


// Widget untuk tampil info toko
class StoreDetailWidget extends StatelessWidget {
  final DocumentSnapshot tokoData;
  const StoreDetailWidget({required this.tokoData, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = tokoData.data() as Map<String, dynamic>;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        margin: const EdgeInsets.only(top: 35),
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.store, size: 40, color: Colors.deepPurple),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      data['name'],
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              Text(
                data['description'] ?? 'Tidak ada deskripsi toko.',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.manage_accounts),
                  label: const Text(
                    'Kelola Produk',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.lightBlue,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ProdukPage(storeId: tokoData.id),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
