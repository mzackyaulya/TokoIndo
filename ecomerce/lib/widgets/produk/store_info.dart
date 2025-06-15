import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StoreInfo extends StatelessWidget {
  final DocumentSnapshot tokoData;
  final VoidCallback onVisit;

  const StoreInfo({
    Key? key,
    required this.tokoData,
    required this.onVisit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final data = tokoData.data() as Map<String, dynamic>?;

    if (data == null) {
      return const SizedBox();
    }

    final String storeName = data['name'] ?? 'Nama toko tidak tersedia';
    final String? storeAddress = data['address'];
    final String? storeImageUrl = data['imageUrl']; // Pastikan field ini ada di Firestore kalau mau pakai gambar

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white, // opsional, biar tetap putih
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Gambar toko bulat
          ClipOval(
            child: storeImageUrl != null && storeImageUrl.isNotEmpty
                ? Image.network(
              storeImageUrl,
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.storefront, size: 70, color: Colors.grey),
            )
                : const Icon(Icons.storefront, size: 70, color: Colors.grey),
          ),
          const SizedBox(width: 16),

          // Nama toko dan lokasi
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  storeName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                if (storeAddress != null)
                  Text(
                    storeAddress,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.black38,
                    ),
                  ),
              ],
            ),
          ),

          // Tombol kunjungi
          OutlinedButton(
            onPressed: onVisit,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.lightBlue),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text(
              'Kunjungi',
              style: TextStyle(
                color: Colors.lightBlue,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
