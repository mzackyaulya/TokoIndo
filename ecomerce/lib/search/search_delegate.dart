import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomSearchDelegate extends SearchDelegate {
  final CollectionReference produkCollection = FirebaseFirestore.instance.collection('products');

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Bisa kasih suggestion kosong atau sama dengan results
    return _buildSearchResults();
  }

  Widget _buildSearchResults() {
    if (query.isEmpty) {
      return const Center(child: Text('Masukkan kata kunci pencarian'));
    }

    // Convert query to lowercase for case-insensitive search
    String searchLower = query.toLowerCase();

    // Firestore query dengan prefix search by name (lowercase)
    // Catatan: kamu harus menyimpan field 'nameLower' di dokumen produk yang isinya name lowercase,
    // supaya query ini bisa optimal dan case insensitive
    // Jika tidak punya, kamu bisa search case sensitive, atau simpan dulu di DB kamu.

    return StreamBuilder<QuerySnapshot>(
      stream: produkCollection
          .where('nameLower', isGreaterThanOrEqualTo: searchLower)
          .where('nameLower', isLessThan: searchLower + 'z')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('Produk tidak ditemukan'));
        }

        final docs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final data = docs[index].data()! as Map<String, dynamic>;
            final name = data['name'] ?? 'Tanpa Nama';
            final price = data['price'] ?? 0;
            final imageUrl = data['imageUrl'] ?? '';

            return ListTile(
              leading: imageUrl.isNotEmpty
                  ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.image_not_supported),
              title: Text(name),
              subtitle: Text('Rp $price'),
              onTap: () {
                // Bisa navigasi ke detail produk
                // Navigator.push(...);
              },
            );
          },
        );
      },
    );
  }
}
