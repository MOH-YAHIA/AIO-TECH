import 'package:aio_tech/Widgets/aio_tech_logo.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../services/auth_services.dart';
import '../services/product_analysis_service.dart';
import '../utils/product_analysis_model.dart';

class DrawerDesign extends StatefulWidget {
  final Function(int) onDestinationSelected;
  final Function(String) onSearchProduct; // Added this callback
  final int selectedIndex;

  const DrawerDesign({
    super.key,
    required this.onDestinationSelected,
    required this.onSearchProduct, // Required here
    required this.selectedIndex,
  });

  @override
  State<DrawerDesign> createState() => _DrawerDesignState();
}

class _DrawerDesignState extends State<DrawerDesign> {
  final AuthService _authService = AuthService();
  final ProductAnalysisService _productAnalysisService = ProductAnalysisService();

  List<ProductAnalysisModel> _recentProducts = [];
  bool _isLoadingHistory = false;

  @override
  void initState() {
    super.initState();
    _loadRecentProducts();
  }

  Future<void> _loadRecentProducts() async {
    setState(() => _isLoadingHistory = true);

    final result = await _productAnalysisService.getMyProducts();

    if (mounted) {
      setState(() {
        _isLoadingHistory = false;
        if (result['success']) {
          _recentProducts = (result['data'] as List<ProductAnalysisModel>)
              .take(10) // Show last 10 items max
              .toList();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.sidebarBackground.withOpacity(0.9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
            child: const AIOTechLogo(),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Text(
              tr('menu'),
              style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
          ),

          ListTile(
            leading: const Icon(Icons.search, color: AppColors.iconColor),
            title: Text(
              tr('smart search'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            selected: widget.selectedIndex == 2,
            onTap: () => widget.onDestinationSelected(2),
          ),
          ListTile(
            leading: const Icon(Icons.balance, color: AppColors.iconColor),
            title:  Text(
              tr('compare'),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            selected: widget.selectedIndex == 5,
            onTap: () => widget.onDestinationSelected(5),
          ),
          ListTile(
            leading: const Icon(Icons.favorite_border, color: AppColors.iconColor),
            title: const Text(
              "WatchList",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            selected: widget.selectedIndex == 3,
            onTap: () => widget.onDestinationSelected(3),
          ),
          ListTile(
            leading: const Icon(Icons.person_outline, color: AppColors.iconColor),
            title: const Text(
              "DashBoard",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
            ),
            selected: widget.selectedIndex == 4,
            onTap: () => widget.onDestinationSelected(4),
          ),

          // ── History Section ──────────────────────────────────────
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        tr('recent products'),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.access_time, color: Colors.white, size: 20),
                          const SizedBox(width: 8),
                          // Refresh button
                          GestureDetector(
                            onTap: _loadRecentProducts,
                            child: const Icon(Icons.refresh, color: Colors.grey, size: 18),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // History list
                  Expanded(
                    child: _isLoadingHistory
                        ? const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white38,
                      ),
                    )
                        : _recentProducts.isEmpty
                        ? Center(
                      child: Text(
                        tr('no recent products'),
                        style: const TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    )
                        : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: _recentProducts.length,
                      separatorBuilder: (_, __) => const Divider(
                        color: Colors.white10,
                        height: 1,
                      ),
                      itemBuilder: (context, index) {
                        final product = _recentProducts[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          leading: _buildProductAvatar(product),
                          title: Text(
                            product.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            "EGP ${product.currentPriceEgp.toStringAsFixed(0)}",
                            style: const TextStyle(
                              color: Colors.greenAccent,
                              fontSize: 11,
                            ),
                          ),
                          onTap: () {
                            // Call the search product callback
                            widget.onSearchProduct(product.name);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(color: Colors.grey),

          // ── User Footer ──────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.all(15),
            child: ListTile(
              trailing: IconButton(
                icon: const Icon(Icons.logout, color: AppColors.iconColor, size: 40),
                isSelected: widget.selectedIndex == 0,
                onPressed: () => widget.onDestinationSelected(0),
              ),
              leading: const Icon(Icons.account_circle, color: AppColors.iconColor, size: 40),
              title: FutureBuilder<String?>(
                future: _authService.getFullName(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return  Text(
                      tr('loading'),
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
                    );
                  }
                  return Text(
                    snapshot.data ?? "Guest",
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.white),
                  );
                },
              ),
              subtitle: Text(
                tr('free plan'),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductAvatar(ProductAnalysisModel product) {
    if (product.imageUrl != null && product.imageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          product.imageUrl!,
          width: 36,
          height: 36,
          fit: BoxFit.cover,
          headers: const {
            'User-Agent': 'Mozilla/5.0 (Linux; Android 10) AppleWebKit/537.36 Chrome/120 Mobile Safari/537.36',
            'Referer': 'https://www.google.com/',
          },
          errorBuilder: (_, __, ___) => _textAvatar(product.name),
        ),
      );
    }
    return _textAvatar(product.name);
  }

  Widget _textAvatar(String name) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.buttonBackground.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}