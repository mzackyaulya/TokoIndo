import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ecomerce/pages/keranjang_page.dart';
import 'package:ecomerce/pages/produk/Variant_picker.dart';
import 'package:ecomerce/pages/produk/detail_store_page.dart';
import 'package:ecomerce/widgets/produk/product_info.dart';
import 'package:ecomerce/widgets/produk/product_comments.dart';
import 'package:ecomerce/widgets/produk/store_info.dart';
import 'package:ecomerce/widgets/produk/bottom_action_bar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DetailProdukPage extends StatefulWidget {
  final String produkId;
  const DetailProdukPage({super.key, required this.produkId});

  @override
  State<DetailProdukPage> createState() => _DetailProdukPageState();
}

class _DetailProdukPageState extends State<DetailProdukPage> {
  Map<String, String?> selectedVariants = {};
  List<Map<String, dynamic>> variants = [];

  Future<void> addToCartWithVariants(
      String produkId,
      Map<String, dynamic> produkData,
      Map<String, String?> selectedVariants,
      ) async {
    final cartRef = FirebaseFirestore.instance.collection('cart');

    try {
      await cartRef.add({
        'produkId': produkId,
        'name': produkData['name'],
        'price': produkData['price'],
        'imageUrl': produkData['imageUrl'],
        'quantity': 1,
        'selectedVariants': selectedVariants,
        'userId': FirebaseAuth.instance.currentUser!.uid,
        'addedAt': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Produk berhasil ditambahkan ke keranjang')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menambahkan ke keranjang: $e')),
      );
    }
  }

  void addToCartDirectly(String produkId, Map<String, dynamic> produkData) async {
    final cartRef = FirebaseFirestore.instance.collection('cart');

    await cartRef.add({
      'produkId': produkId,
      'name': produkData['name'],
      'price': produkData['price'],
      'imageUrl': produkData['imageUrl'],
      'quantity': 1,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk ditambahkan ke keranjang')),
    );
  }


  @override
  Widget build(BuildContext context) {
    final produkRef =
    FirebaseFirestore.instance.collection('products').doc(widget.produkId);

    return FutureBuilder<DocumentSnapshot>(
      future: produkRef.get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const Scaffold(
            body: Center(child: Text('Produk tidak ditemukan')),
          );
        }

        final data = snapshot.data!.data() as Map<String, dynamic>;
        final storeId = data['storeId'] ?? '';
        final imageUrl = data['imageUrl'] ?? '';
        final productStock = data['stock'] ?? 0;

        variants = List<Map<String, dynamic>>.from(data['variants'] ?? []);

        if (selectedVariants.isEmpty && variants.isNotEmpty) {
          for (var variant in variants) {
            final name = variant['nama'] ?? 'Varian';
            final pilihan = List<String>.from(variant['pilihan'] ?? []);
            if (pilihan.isNotEmpty) {
              selectedVariants[name] = pilihan[0];
            }
          }
        }

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const CartPage()),
                  );
                },
              ),
              IconButton(icon: const Icon(Icons.chat), onPressed: () {}),
            ],
          ),
          body: Stack(
            children: [
              SingleChildScrollView(
                padding: EdgeInsets.zero,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: 400,
                        width: double.infinity,
                        child: imageUrl.isNotEmpty
                            ? Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Image.asset('assets/images/noimage.png',
                                fit: BoxFit.cover);
                          },
                        )
                            : Image.asset('assets/images/noimage.png',
                            fit: BoxFit.cover),
                      ),

                      // Card Info Produk
                      Card(
                        margin: EdgeInsets.zero,
                        color: Colors.white,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: ProductInfo(
                            name: data['name'] ?? '',
                            price: data['price'] ?? 0,
                            sold: data['sold'] ?? 0,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Card Variasi Produk
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        color: Colors.white,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Pilih Variasi (${variants.length} Varian)',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () async {
                                      await showModalBottomSheet(
                                        context: context,
                                        isScrollControlled: true,
                                        builder: (_) => VariantPickerModal(
                                          variants: variants,
                                          selectedVariants: selectedVariants,
                                          onSelected: (newSelection) {
                                            setState(() {
                                              selectedVariants = newSelection;
                                            });
                                          },
                                          imageUrl: imageUrl,
                                          productName: data['name'] ?? '',
                                          productPrice: data['price'] ?? 0,
                                          productStock: productStock,
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Lihat semua >',
                                      style: TextStyle(
                                        color: Colors.black38,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              if (variants.isNotEmpty) ...[
                                Text(
                                  'Varian ${variants[0]['nama']}',
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: List<String>.from(
                                        variants[0]['pilihan'] ?? [])
                                        .map((option) {
                                      final isSelected =
                                          selectedVariants[
                                          variants[0]['nama']] ==
                                              option;
                                      return Padding(
                                        padding:
                                        const EdgeInsets.only(right: 8),
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedVariants[
                                              variants[0]['nama']] = option;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 14, vertical: 10),
                                            decoration: BoxDecoration(
                                              color: isSelected
                                                  ? Colors.blue
                                                  : Colors.grey[200],
                                              borderRadius:
                                              BorderRadius.circular(8),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Colors.blue
                                                    : Colors.grey.shade300,
                                                width: isSelected ? 2 : 1,
                                              ),
                                            ),
                                            child: Text(
                                              option,
                                              style: TextStyle(
                                                color: isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ),
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      // Komentar
                      Card(
                        margin: EdgeInsets.zero,
                        elevation: 0,
                        shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.zero),
                        child: ProductComments(produkId: widget.produkId),
                      ),

                      const SizedBox(height: 15),

                      // Info toko
                      if (storeId.isNotEmpty)
                        FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance
                              .collection('stores')
                              .doc(storeId)
                              .get(),
                          builder: (context, tokoSnapshot) {
                            if (tokoSnapshot.connectionState ==
                                ConnectionState.waiting ||
                                !tokoSnapshot.hasData ||
                                !tokoSnapshot.data!.exists) {
                              return const SizedBox.shrink();
                            }
                            final tokoData = tokoSnapshot.data!;
                            return Container(
                              width: double.infinity,
                              color: Colors.white,
                              child: Card(
                                margin: EdgeInsets.zero,
                                elevation: 0,
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero),
                                child: StoreInfo(
                                  tokoData: tokoData,
                                  onVisit: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => StoreDetailPage(
                                            storeId: tokoData.id),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 80), // buat spasi bottom bar
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomActionBar(
            onChatPressed: () {
              print('Chat ditekan');
            },
            onCartPressed: () async {
              if (variants.isNotEmpty) {
                final newSelection = await showModalBottomSheet<Map<String, String?>>(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => VariantPickerModal(
                    variants: variants,
                    selectedVariants: selectedVariants,
                    onSelected: (selection) {
                      Navigator.pop(context, selection);
                    },
                    imageUrl: imageUrl,
                    productName: data['name'] ?? '',
                    productPrice: data['price'] ?? 0,
                    productStock: productStock,
                  ),
                );

                if (newSelection != null) {
                  setState(() {
                    selectedVariants = newSelection;
                  });
                  addToCartWithVariants(widget.produkId, data, selectedVariants);
                }
              } else {
                addToCartDirectly(widget.produkId, data);
              }
            },
            onBuyPressed: () {
              print('Beli Sekarang ditekan');
            },
          ),
        );
      },
    );
  }
}
