import 'package:flutter/material.dart';

class ProductVariants extends StatelessWidget {
  final String variantName;
  final List<String> variantOptions;
  final String? selectedVariant;
  final ValueChanged<String> onVariantSelected;

  const ProductVariants({
    super.key,
    required this.variantName,
    required this.variantOptions,
    required this.selectedVariant,
    required this.onVariantSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (variantOptions.isEmpty) return const SizedBox();

    return Container(
      width: double.infinity,
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'Pilih $variantName',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 13),
              child: Row(
                children: variantOptions.map((variant) {
                  final isSelected = variant == selectedVariant;
                  return Container(
                    margin: const EdgeInsets.only(right: 8),
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        backgroundColor: isSelected ? Colors.lightBlue.shade100 : Colors.grey[300],
                        foregroundColor: isSelected ? Colors.lightBlue : Colors.black,
                        side: isSelected
                            ? const BorderSide(color: Colors.lightBlue, width: 2)
                            : BorderSide.none,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      onPressed: () => onVariantSelected(variant),
                      child: Text(variant, style: const TextStyle(fontSize: 16)),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

