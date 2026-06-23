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

    // Extract real product names from the response for labelling
    final products = data['products'] ?? {};
    final String nameA = (products['product_a']?['name'] ?? 'Product A').toString();
    final String nameB = (products['product_b']?['name'] ?? 'Product B').toString();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall Winner Banner
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black, width: 1.5),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Overall Winner",
                      style: TextStyle(fontSize: 14, color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      winner,
                      // FIX: was Colors.black87 — invisible on black background
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Executive Summary Card
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Executive Summary", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const Divider(),
                Text(summary, style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black54)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Recommendation Matrix — use real product names instead of "Product A/B"
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildAdviceCard("Buy $nameA if:", buyAIf, Colors.blue.shade700)),
            const SizedBox(width: 12),
            Expanded(child: _buildAdviceCard("Buy $nameB if:", buyBIf, Colors.purple.shade700)),
          ],
        ),
        const SizedBox(height: 16),

        // Feature Breakdown Specifications Table
        const Text("Feature Breakdown", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(item['category_name'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                          child: Text("Winner: ${item['category_winner'] ?? 'Tie'}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // FIX: use real product names instead of hardcoded "Product A / Product B"
                    Text("$nameA: ${item['product_a_details'] ?? ''}", style: const TextStyle(fontSize: 13, color: Colors.black87)),
                    const SizedBox(height: 4),
                    Text("$nameB: ${item['product_b_details'] ?? ''}", style: const TextStyle(fontSize: 13, color: Colors.black54)),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: accentColor, fontSize: 14)),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text("• $item", style: const TextStyle(fontSize: 12, height: 1.3)),
          )),
        ],
      ),
    );
  }
}