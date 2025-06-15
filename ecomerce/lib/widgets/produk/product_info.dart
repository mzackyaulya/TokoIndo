import 'package:flutter/material.dart';

class ProductInfo extends StatelessWidget {
  final String name;
  final int price;
  final int sold;

  const ProductInfo({
    super.key,
    required this.name,
    required this.price,
    required this.sold,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Rp. $price', style: const TextStyle(fontSize: 18, color: Colors.green)),
        const SizedBox(height: 8),
        Text(name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text('Terjual: $sold', style: const TextStyle(fontSize: 16)),
      ],
    );
  }
}
