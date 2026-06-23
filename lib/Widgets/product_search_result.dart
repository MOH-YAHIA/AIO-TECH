import 'package:flutter/material.dart';

class ProductSearchResult extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProductSearchResult({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // 1. Map the exact keys coming from your FastAPI backend
    final String name = data['name'] ?? 'Unknown Product';
    final String priceEgp = data['current_price_egp']?.toString() ?? 'N/A';
    final String priceUsd = data['global_usd_price']?.toString() ?? '';
    final String imageUrl = data['image_url'] ?? '';
    final List pros = data['pros'] ?? [];
    final List cons = data['cons'] ?? [];
    final String summary = data['sentiment_summary'] ?? '';

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
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  clipBehavior: Clip.hardEdge,
                  // Safely load the network image from the API
                  child: imageUrl.isNotEmpty
                      ? Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.image, size: 40, color: Colors.grey),
                  )
                      : const Icon(Icons.image, size: 40, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        "EGP $priceEgp",
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      if (priceUsd.isNotEmpty)
                        Text(
                          "Global: $priceUsd",
                          style: const TextStyle(color: Colors.grey, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // AI Sentiment Summary
            if (summary.isNotEmpty) ...[
              const Text("AI Summary", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(summary, style: const TextStyle(color: Colors.black87, height: 1.4, fontSize: 13)),
              const Divider(height: 24),
            ],

            // Pros
            if (pros.isNotEmpty) ...[
              const Text("Pros", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.green)),
              const SizedBox(height: 8),
              ...pros.map((pro) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(pro.toString(), style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
              const SizedBox(height: 12),
            ],

            // Cons
            if (cons.isNotEmpty) ...[
              const Text("Cons", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red)),
              const SizedBox(height: 8),
              ...cons.map((con) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.cancel, color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(con.toString(), style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }
}