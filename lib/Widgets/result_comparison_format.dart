import 'package:flutter/material.dart';

class ResultComparisonFormat extends StatelessWidget {
  final Map<String, dynamic> data;

  const ResultComparisonFormat({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final aiCompare = data['ai_comparison'] ?? {};
    final String winner = aiCompare['overall_winner'] ?? 'Tie';
    final String summary = aiCompare['executive_summary'] ?? '';
    final List buyAIf = aiCompare['buy_product_a_if'] ?? [];
    final List buyBIf = aiCompare['buy_product_b_if'] ?? [];
    final List breakdowns = aiCompare['feature_breakdowns'] ?? [];

    // Real product data (includes prices and images)
    final products = data['products'] ?? {};
    final Map<String, dynamic> productA =
    Map<String, dynamic>.from(products['product_a'] ?? {});
    final Map<String, dynamic> productB =
    Map<String, dynamic>.from(products['product_b'] ?? {});
    final String nameA = productA['name'] ?? 'Product A';
    final String nameB = productB['name'] ?? 'Product B';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Product Price Cards ─────────────────────────────────
        Row(
          children: [
            Expanded(child: _buildProductCard(productA, Colors.blue.shade700)),
            const SizedBox(width: 12),
            Expanded(child: _buildProductCard(productB, Colors.purple.shade700)),
          ],
        ),
        const SizedBox(height: 16),

        // ── Overall Winner Banner ───────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Overall Winner",
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.bold)),
                    Text(winner,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white)), // FIX: white on black
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Executive Summary ───────────────────────────────────
        Card(
          elevation: 2,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Executive Summary",
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                Text(summary,
                    style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: Colors.black54)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // ── Buy Recommendations ─────────────────────────────────
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: _buildAdviceCard(
                    "Buy $nameA if:", buyAIf, Colors.blue.shade700)),
            const SizedBox(width: 12),
            Expanded(
                child: _buildAdviceCard(
                    "Buy $nameB if:", buyBIf, Colors.purple.shade700)),
          ],
        ),
        const SizedBox(height: 16),

        // ── Feature Breakdown ───────────────────────────────────
        const Text("Feature Breakdown",
            style:
            TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: breakdowns.length,
          itemBuilder: (context, index) {
            final item = breakdowns[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(item['category_name'] ?? '',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(
                              "Winner: ${item['category_winner'] ?? 'Tie'}",
                              style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    _buildDetailRow(nameA, item['product_a_details'], Colors.blue.shade700),
                    const SizedBox(height: 4),
                    _buildDetailRow(nameB, item['product_b_details'], Colors.purple.shade700),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  /// Mini card showing product image, name, and price
  Widget _buildProductCard(Map<String, dynamic> product, Color accentColor) {
    final String name = product['name'] ?? 'Unknown';
    final dynamic rawPrice =
        product['current_price_egp'] ?? product['price_egp'];
    final String price =
    rawPrice != null ? 'EGP ${rawPrice.toString()}' : 'N/A';
    final String imageUrl = product['image_url'] ?? '';

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: accentColor.withOpacity(0.4)),
        borderRadius: BorderRadius.circular(12),
        color: accentColor.withOpacity(0.05),
      ),
      child: Row(
        children: [
          _buildThumb(imageUrl, name, accentColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 13),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                Text(price,
                    style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumb(String imageUrl, String name, Color accentColor) {
    final Widget fallback = Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: accentColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.bold,
              fontSize: 20),
        ),
      ),
    );

    if (imageUrl.isEmpty) return fallback;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.network(
        imageUrl,
        width: 48,
        height: 48,
        fit: BoxFit.cover,
        headers: const {
          'User-Agent':
          'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36',
          'Referer': 'https://www.google.com/',
        },
        errorBuilder: (context, error, stackTrace) => fallback,
      ),
    );
  }

  Widget _buildDetailRow(String label, dynamic detail, Color labelColor) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: '$label: ',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: labelColor),
          ),
          TextSpan(
            text: detail?.toString() ?? '',
            style: const TextStyle(fontSize: 13, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Widget _buildAdviceCard(String title, List items, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                  fontSize: 14)),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text("• $item",
                style:
                const TextStyle(fontSize: 12, height: 1.3)),
          )),
        ],
      ),
    );
  }
}