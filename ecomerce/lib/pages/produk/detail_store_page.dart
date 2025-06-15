import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// Halaman detail store
class StoreDetailPage extends StatelessWidget {
  final String storeId;

  const StoreDetailPage({super.key, required this.storeId});

  @override
  Widget build(BuildContext context) {
    final storeRef = FirebaseFirestore.instance.collection('stores').doc(storeId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Toko'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: storeRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Toko tidak ditemukan.'));
          }

          final storeData = snapshot.data!.data() as Map<String, dynamic>;
          final name = storeData['name'] ?? 'Tanpa Nama';
          final imageUrl = storeData['imageUrl'] ?? '';
          final address = storeData['address'] ?? 'Alamat tidak tersedia';


          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: (storeData != null &&
                          storeData['imageUrl'] != null &&
                          storeData['imageUrl'].toString().isNotEmpty)
                          ? NetworkImage(storeData['imageUrl'])
                          : const AssetImage('assets/images/noimage.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Nama toko
                Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                // Alamat
                Text(address, style: const TextStyle(fontSize: 16)),
              ],
            ),
          );
        },
      ),
    );
  }
}