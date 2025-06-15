import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VariantPickerModal extends StatefulWidget {
  final List<Map<String, dynamic>> variants;
  final Map<String, String?> selectedVariants;
  final ValueChanged<Map<String, String?>> onSelected;
  final String imageUrl;
  final String productName;
  final int productPrice;
  final int productStock;

  const VariantPickerModal({
    super.key,
    required this.variants,
    required this.selectedVariants,
    required this.onSelected,
    required this.imageUrl,
    required this.productName,
    required this.productPrice,
    required this.productStock,
  });

  @override
  State<VariantPickerModal> createState() => _VariantPickerModalState();
}

class _VariantPickerModalState extends State<VariantPickerModal> {

  late Map<String, String?> tempSelectedVariants;
  int getStockForSelectedVariant() {
    for (var variant in widget.variants) {
      // Jika varian memiliki kombinasi dan stok
      if (variant.containsKey('kombinasi') && variant.containsKey('stok')) {
        final kombinasi = Map<String, dynamic>.from(variant['kombinasi']);
        bool cocok = true;
        for (var key in tempSelectedVariants.keys) {
          if (kombinasi[key] != tempSelectedVariants[key]) {
            cocok = false;
            break;
          }
        }
        if (cocok) return variant['stok'] ?? 0;
      }
    }

    return widget.productStock; // fallback stok default
  }

  @override
  void initState() {
    super.initState();
    tempSelectedVariants = Map<String, String?>.from(widget.selectedVariants);

  }
  void addToCartWithVariants(String produkId, Map<String, dynamic> produkData, Map<String, String?> selectedVariants) async {
    final cartRef = FirebaseFirestore.instance.collection('cart');

    await cartRef.add({
      'produkId': produkId,
      'name': produkData['name'],
      'price': produkData['price'],
      'imageUrl': produkData['imageUrl'],
      'quantity': 1,
      'selectedVariants': selectedVariants,
      'userId': FirebaseAuth.instance.currentUser!.uid,  // Wajib untuk sesuai rules Firestore
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Produk dengan varian berhasil ditambahkan ke keranjang')),
    );
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 70),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header produk
                  Row(
                    children: [
                      Container(
                        width: 100, // atur lebar
                        height: 100, // atur tinggi
                        decoration: BoxDecoration( // jika ingin sedikit rounded
                          image: DecorationImage(
                            image: NetworkImage(widget.imageUrl),
                            fit: BoxFit.cover, // supaya gambar full
                          ),
                          color: Colors.grey[200], // fallback jika gambar loading
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.productName, // ganti sesuai nama field stok kamu
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Rp ${NumberFormat('#,###', 'id_ID').format(widget.productPrice)}',
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 17,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Stok: ${getStockForSelectedVariant()}', // ganti sesuai nama field stok kamu
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black38,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const Divider(height: 20),

                  // Daftar varian
                  Expanded(
                    child: ListView(
                      children: widget.variants.map((variant) {
                        final varName = variant['nama'] ?? 'Varian';
                        final options = List<String>.from(variant['pilihan'] ?? []);
                        final selectedOption = tempSelectedVariants[varName];

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              varName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: options.map((option) {
                                final isSelected = option == selectedOption;
                                return GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      tempSelectedVariants[varName] = option;
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                    decoration: BoxDecoration(
                                      color: isSelected ? Colors.blue : Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected ? Colors.blue : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Text(
                                      option,
                                      style: TextStyle(
                                        color: isSelected ? Colors.white : Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                            const SizedBox(height: 20),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),

            // Tombol bawah
            Positioned(
              bottom: 10,
              left: 16,
              right: 16,
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSelected(tempSelectedVariants);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Tambah ke Keranjang',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
