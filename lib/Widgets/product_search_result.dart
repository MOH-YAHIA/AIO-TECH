import 'package:flutter/material.dart';

class ProductSearchResult extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProductSearchResult({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final product = data['product'] ?? {};
    final String name = product['name'] ?? 'Unknown Product';
    final String estPrice = product['estimated_price'] ?? 'N/A';
    final List stores = product['available_stores'] ?? [];
    final Map specs = product['specs'] ?? {};

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Core Header
            Row(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("Est. Market Price: $estPrice", style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 15)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Hardware Specs List
            const Text("Key Specifications", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...specs.entries.map((entry) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(entry.key, style: const TextStyle(color: Colors.grey)),
                  Text(entry.value.toString(), style: const TextStyle(fontWeight: FontWeight.w500)),
                ],
              ),
            )),
            const Divider(height: 24),

            // Store Availability
            const Text("Available Offers In Egypt", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            ...stores.map((store) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.storefront, color: Colors.blueGrey),
              title: Text(store['store_name'] ?? ''),
              subtitle: Text(store['stock_status'] ?? 'In Stock'),
              trailing: Text(
                store['price'] ?? '',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            )),
          ],
        ),
      ),
    );
  }
}