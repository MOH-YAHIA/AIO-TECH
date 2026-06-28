import 'package:flutter/material.dart';

class ProductSearchResult extends StatelessWidget {
  final Map<String, dynamic> data;

  const ProductSearchResult({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    // Support both field names: DB uses 'current_price_egp', detailed uses 'price_egp'
    final String name = data['name'] ?? 'Unknown Product';
    final dynamic rawPrice = data['current_price_egp'] ?? data['price_egp'];
    final String priceEgp = rawPrice != null ? rawPrice.toString() : 'N/A';
    final String priceUsd = data['global_usd_price']?.toString() ?? '';
    final String imageUrl = data['image_url'] ?? '';
    final List pros = data['pros'] ?? [];
    final List cons = data['cons'] ?? [];
    // Support both field names: DB uses 'sentiment_summary', detailed uses 'why_it_matches'
    final String summary = (data['sentiment_summary'] ?? data['why_it_matches'] ?? '').toString();

    return Card(
      elevation: 3,
      color: Colors.white.withOpacity(0.8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Header
            Row(
              children: [
                _buildProductImage(imageUrl, name),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 6),
                      Text(
                        "EGP $priceEgp",
                        style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 16),
                      ),
                      if (priceUsd.isNotEmpty)
                        Text(
                          "Global: \$$priceUsd",
                          style: const TextStyle(
                              color: Colors.grey, fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // AI Summary / Why it matches
            if (summary.isNotEmpty) ...[
              const Text("AI Summary",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 8),
              Text(summary,
                  style: const TextStyle(
                      color: Colors.black87, height: 1.4, fontSize: 13)),
              const Divider(height: 24),
            ],

            // Pros
            if (pros.isNotEmpty) ...[
              const Text("Pros",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.green)),
              const SizedBox(height: 8),
              ...pros.map((pro) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_circle,
                        color: Colors.green, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(pro.toString(),
                            style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
              const SizedBox(height: 12),
            ],

            // Cons
            if (cons.isNotEmpty) ...[
              const Text("Cons",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.red)),
              const SizedBox(height: 8),
              ...cons.map((con) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.cancel,
                        color: Colors.red, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(con.toString(),
                            style: const TextStyle(fontSize: 13))),
                  ],
                ),
              )),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProductImage(String imageUrl, String name) {
    // Fallback avatar using the first letter of the product name
    final Widget fallback = Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: const Color(0xFF2E373C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold),
        ),
      ),
    );

    if (imageUrl.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        imageUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        // Add browser-like headers so Google Shopping thumbnails load
        headers: const {
          'User-Agent':
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36',
          'Referer': 'https://www.google.com/',
        },
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2)),
          );
        },
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }
}