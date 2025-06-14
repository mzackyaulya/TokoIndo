// ... import tetap
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce/pages/produk/detail_store_page.dart';
import 'package:ecomerce/search/search_delegate.dart';
import 'package:flutter/material.dart';

class DetailProdukPage extends StatefulWidget {
  final String produkId;

  const DetailProdukPage({super.key, required this.produkId});

  @override
  State<DetailProdukPage> createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  String? selectedVariant;
  List<String> variantOptions = [];

  @override
  Widget build(BuildContext context) {
    final produkRef = FirebaseFirestore.instance.collection('products').doc(widget.produkId);

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 300, // lebarkan leading supaya muat search box dan back button
        leading: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () {
                  showSearch(
                    context: context,
                    delegate: CustomSearchDelegate(),
                  );
                },
                child: Container(
                  height: 35,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Row(
                    children: const [
                      Icon(Icons.search, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Cari produk...', style: TextStyle(color: Colors.black, fontSize: 15)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        title: null, // kosongkan title supaya gak ada space tengah
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'Keranjang',
            onPressed: () {
              Navigator.pushNamed(context, '/cart');
            },
          ),
          IconButton(
            icon: const Icon(Icons.message),
            tooltip: 'Pesan',
            onPressed: () {
              Navigator.pushNamed(context, '/messages');
            },
          ),
        ],
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: produkRef.get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (!snapshot.hasData || !snapshot.data!.exists) return const Center(child: Text('Produk tidak ditemukan'));

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = data['name'] ?? 'Tanpa Nama';
          final price = data['price'] ?? 0;
          final imageUrl = data['imageUrl'] ?? '';
          final sold = data['sold'] ?? 0;
          final rating = (data['rating'] ?? 0.0).toDouble();
          final ratingCount = data['ratingCount'] ?? 0;
          final storeId = data['storeId'] ?? '';
          final storeRef = FirebaseFirestore.instance.collection('stores').doc(storeId);

          final variantListRaw = List<Map<String, dynamic>>.from(data['variants'] ?? []);
          variantOptions = variantListRaw.isNotEmpty
              ? List<String>.from(variantListRaw[0]['pilihan'] ?? [])
              : [];
          selectedVariant ??= variantOptions.isNotEmpty ? variantOptions[0] : null;

          return FutureBuilder<DocumentSnapshot>(
            future: storeRef.get(),
            builder: (context, storeSnapshot) {
              final storeData = storeSnapshot.data?.data() as Map<String, dynamic>?;

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Gambar produk
                    imageUrl.isNotEmpty
                        ? Image.network(imageUrl,
                      height: 250,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Image.asset('assets/images/noimage.png',
                            height: 250, width: double.infinity, fit: BoxFit.cover);
                      },
                    )
                        : Image.asset('assets/images/noimage.png',
                        height: 250, width: double.infinity, fit: BoxFit.cover),

                    // Info Produk
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Rp. $price', style: const TextStyle(fontSize: 18, color: Colors.green)),
                          const SizedBox(height: 8),
                          Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('Terjual: $sold', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                    ),


                    // CARD VARIASI BARU
                    if (variantOptions.isNotEmpty)
                      Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        width: double.infinity,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Pilih Variasi', style: TextStyle(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              children: variantOptions.map((variant) {
                                final isSelected = variant == selectedVariant;
                                return ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: isSelected ? Colors.white : Colors.grey[300],
                                    foregroundColor: isSelected ? Colors.lightBlue : Colors.black,
                                    side: isSelected ? BorderSide(color: Colors.lightBlue, width: 2) : BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.zero,
                                    ),
                                    elevation: 0,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      selectedVariant = variant;
                                    });
                                  },
                                  child: Text(variant),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 8),

                    // CARD KOMENTAR & RATING
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              const SizedBox(width: 6),
                              Text(rating.toStringAsFixed(1), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                              const SizedBox(width: 12),
                              Text('($ratingCount ulasan)', style: const TextStyle(fontSize: 16, color: Colors.black54)),
                            ],
                          ),
                          const Divider(height: 30),
                          const Text('Komentar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),

                          StreamBuilder<QuerySnapshot>(
                            stream: produkRef.collection('comments').orderBy('createdAt', descending: true).snapshots(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return const Center(child: CircularProgressIndicator());
                              }

                              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                                return const Text('Belum ada komentar.');
                              }

                              return Column(
                                children: snapshot.data!.docs.map((doc) {
                                  final data = doc.data() as Map<String, dynamic>;
                                  final username = data['username'] ?? 'Anonim';
                                  final comment = data['comment'] ?? '';
                                  final ratingUser = data['rating'] ?? 0;

                                  return Container(
                                    width: double.infinity,
                                    margin: const EdgeInsets.symmetric(vertical: 6),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.zero, // POJOK KOTAK tanpa rounded
                                      boxShadow: [], // hilangkan shadow
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(username, style: const TextStyle(fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: List.generate(5, (index) {
                                            return Icon(
                                              index < ratingUser ? Icons.star : Icons.star_border,
                                              color: Colors.amber,
                                              size: 16,
                                            );
                                          }),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(comment),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Info toko
                    Container(
                      width: double.infinity,
                      color: Colors.white,
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: (storeData?['imageUrl'] ?? '').toString().isNotEmpty
                                ? Image.network(
                              storeData!['imageUrl'],
                              height: 60,
                              width: 60,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Image.asset('assets/images/noimage.png', height: 60, width: 60);
                              },
                            )
                                : Image.asset('assets/images/noimage.png', height: 60, width: 60),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(storeData?['name'] ?? 'Tanpa Nama', style: const TextStyle(fontWeight: FontWeight.bold)),
                                const SizedBox(height: 4),
                                Text(storeData?['address'] ?? 'Alamat tidak tersedia'),
                              ],
                            ),
                          ),
                          OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => StoreDetailPage(storeId: storeId)),
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Colors.lightBlue),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero,
                              ),
                            ),
                            child: const Text(
                              'Kunjungi',
                              style: TextStyle(color: Colors.lightBlue),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
