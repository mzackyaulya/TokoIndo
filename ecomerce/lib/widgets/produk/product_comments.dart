import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ProductComments extends StatelessWidget {
  final String produkId;

  const ProductComments({super.key, required this.produkId});

  @override
  Widget build(BuildContext context) {
    final produkRef = FirebaseFirestore.instance.collection('products').doc(produkId);

    return Container(
      width: MediaQuery.of(context).size.width,
      color: Colors.white,
      padding: const EdgeInsets.all(12),
      child: StreamBuilder<QuerySnapshot>(
        stream: produkRef.collection('comments').orderBy('createdAt', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final comments = snapshot.data?.docs ?? [];

          // Hitung rating rata-rata
          double totalRating = 0;
          for (var doc in comments) {
            final data = doc.data() as Map<String, dynamic>;
            totalRating += (data['rating'] ?? 0).toDouble();
          }
          final averageRating = comments.isNotEmpty ? totalRating / comments.length : 0;

          // Jika tidak ada komentar, tetap tampilkan bintang, rating 0, dan jumlah ulasan 0
          if (comments.isEmpty) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber),
                    const SizedBox(width: 6),
                    Text(
                      averageRating.toStringAsFixed(1), // akan 0.0
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '(0 ulasan)',
                      style: const TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                  ],
                ),
                const Divider(height: 30),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.sentiment_satisfied, color: Colors.amber, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Belum ada komentar.',
                        style: TextStyle(
                          fontSize: 16,
                          fontStyle: FontStyle.italic,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          // Jika ada komentar, tampilkan semua komentar dan rating seperti biasa
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.star, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    averageRating.toStringAsFixed(1),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '(${comments.length} ulasan)',
                    style: const TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
              const Divider(height: 30),
              const Text(
                'Komentar',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ...comments.map((doc) {
                final data = doc.data() as Map<String, dynamic>;
                final username = data['username'] ?? 'Anonim';
                final comment = data['comment'] ?? '';
                final ratingUser = (data['rating'] ?? 0).toInt();

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.zero,
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
            ],
          );
        },
      ),
    );
  }
}
