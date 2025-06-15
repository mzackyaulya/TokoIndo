import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce/pages/keranjang_page.dart';
import 'package:ecomerce/pages/produk/detail_produk_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  final List<Map<String, String>> kategori = const [
    {'name': 'Electronics', 'icon': 'assets/images/electronics.png'},
    {'name': 'Fashion', 'icon': 'assets/images/fashion.png'},
    {'name': 'Beauty', 'icon': 'assets/images/beauty.png'},
    {'name': 'Book', 'icon': 'assets/images/book.png'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                color: Colors.white,
                padding: EdgeInsets.zero,
                child: SafeArea(
                  bottom: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Image.asset(
                          'assets/images/logo.png',
                          width: 150,
                          height: 40,
                          fit: BoxFit.contain,
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.shopping_cart, color: Colors.black),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const CartPage()),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.message, color: Colors.black),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Kategori
              Container(
                width: double.infinity,
                color: Colors.white, // background putih full lebar
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: kategori.length,
                    itemBuilder: (context, index) {
                      final item = kategori[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundImage: AssetImage(item['icon']!),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              item['name']!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Produk dari Firestore
              Card(
                margin: EdgeInsets.zero,
                color: Colors.white70,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            child: Text(
                              'Produk Pilihan',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ),

                        const SizedBox(height: 5),


                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('products')
                            .orderBy('createdAt', descending: true)
                            .limit(10)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('Belum ada produk'));
                          }

                          final produkList = snapshot.data!.docs;

                          return GridView.count(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 6,
                            mainAxisSpacing: 12,
                            childAspectRatio: 3/5,
                            children: produkList.map((item) {
                              final data = item.data() as Map<String, dynamic>;
                              final imageUrl = data['imageUrl'] as String?;
                              final productName = data['name'] ?? 'Tanpa Nama';
                              final productPrice = data['price'] ?? 0;
                              final storeId = data['storeId'];

                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DetailProdukPage(produkId: item.id),
                                    ),
                                  );
                                },
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  elevation: 0,
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: const BorderRadius.only(
                                            topLeft: Radius.circular(8),
                                            topRight: Radius.circular(8),
                                          ),
                                          child: SizedBox(
                                            height: 140,
                                            child: imageUrl != null && imageUrl.isNotEmpty
                                                ? Image.network(
                                              imageUrl,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder: (context, error, stackTrace) =>
                                                  Image.asset('assets/images/noimage.jpg', fit: BoxFit.cover),
                                            )
                                                : Image.asset(
                                              'assets/images/noimage.jpg',
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: Text(
                                          productName,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8 ,vertical: 10),
                                        child: Text(
                                          'Rp${NumberFormat.decimalPattern('id_ID').format(productPrice)}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ),

                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        child: FutureBuilder<DocumentSnapshot>(
                                          future: FirebaseFirestore.instance.collection('stores').doc(storeId).get(),
                                          builder: (context, storeSnapshot) {
                                            if (storeSnapshot.connectionState == ConnectionState.waiting) {
                                              return const Text('Memuat alamat...', style: TextStyle(fontSize: 12, color: Colors.grey));
                                            }
                                            if (!storeSnapshot.hasData || !storeSnapshot.data!.exists) {
                                              return const Text('Alamat tidak ditemukan', style: TextStyle(fontSize: 12, color: Colors.grey));
                                            }
                                            final storeData = storeSnapshot.data!.data() as Map<String, dynamic>;
                                            final storeAddress = storeData['address'] ?? 'Alamat tidak tersedia';
                                            return Text(
                                              storeAddress,
                                              style: const TextStyle(fontSize: 12, color: Colors.black54),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
    );
  }
}
