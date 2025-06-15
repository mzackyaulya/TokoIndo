import 'package:flutter/material.dart';

class BottomActionBar extends StatelessWidget {
  final VoidCallback onChatPressed;
  final VoidCallback onCartPressed;
  final VoidCallback onBuyPressed;

  const BottomActionBar({
    Key? key,
    required this.onChatPressed,
    required this.onCartPressed,
    required this.onBuyPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: const BoxDecoration(
        color: Colors.lightBlue,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: onChatPressed,
          ),
          Container(
            width: 1,
            height: 24,  // atur sesuai tinggi garis yang kamu mau
            color: Colors.white.withOpacity(0.5), // warna garis (bisa diubah)
            margin: const EdgeInsets.symmetric(horizontal: 8), // jarak kiri kanan garis
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: onCartPressed,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ElevatedButton(
                onPressed: onBuyPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Beli Sekarang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
