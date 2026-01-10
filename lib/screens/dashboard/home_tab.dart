import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/app_colors.dart';
import '../../domain/providers/cart_provider.dart';
import '../../domain/services/api_service.dart';
import 'p_card.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  bool isLoading = true;

  List<Map<String, dynamic>> allProducts = [];
  List<Map<String, dynamic>> filteredProducts = [];

  String selectedCategory = "All";
  String searchQuery = "";

  final List<Map<String, dynamic>> categories = [
    {"name": "All", "icon": Icons.grid_view},
    {"name": "Fruits", "icon": Icons.apple},
    {"name": "Vegetables", "icon": Icons.eco},
    {"name": "Snacks", "icon": Icons.fastfood},
    {"name": "Beverages", "icon": Icons.local_drink},
    {"name": "Bakery", "icon": Icons.cake},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();
  }

  Future<void> _loadProducts() async {
    setState(() => isLoading = true);
    final data = await ApiService.fetchProducts();
    if (!mounted) return;

    setState(() {
      allProducts = data;
      _applyFilters();
      isLoading = false;
    });
  }

  void _applyFilters() {
    filteredProducts = allProducts.where((p) {
      final matchCategory =
          selectedCategory == "All" || p['category'] == selectedCategory;

      final matchSearch = p['name']
          .toString()
          .toLowerCase()
          .contains(searchQuery.toLowerCase());

      return matchCategory && matchSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    final width = MediaQuery.of(context).size.width;

    final crossAxisCount = width > 900
        ? 4
        : width > 600
            ? 3
            : 2;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,

      /// 🛒 STICKY CART BAR (SYNCED)
      bottomNavigationBar: cart.totalItems == 0
          ? null
          : InkWell(
              onTap: () => Navigator.pushNamed(context, '/cart'),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${cart.totalItems} items | ₹${cart.totalAmount}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Text(
                      "View Cart →",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

      body: Column(
        children: [
          /// 🔰 HEADER + SEARCH (ANIMATION + DISABLE + SHAKE)
          Container(
            padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, Color(0xFF7E57C2)],
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "GrocDrop",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    /// 🛒 CART ICON (BOUNCE + SHAKE + DISABLE)
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, animation) {
                        final shake =
                            Tween<double>(begin: 0, end: 1).animate(animation);
                        return AnimatedBuilder(
                          animation: shake,
                          child: child,
                          builder: (context, child) {
                            final offset =
                                cart.lastAction == CartAction.maxReached
                                    ? 6 * (1 - shake.value)
                                    : 0;
                            return Transform.translate(
                            offset: Offset(offset.toDouble(), 0),
                              child: child,
                            );
                          },
                        );
                      },
                      child: InkWell(
                        key: ValueKey(cart.totalItems),
                        onTap: cart.totalItems == 0
                            ? null
                            : () => Navigator.pushNamed(context, '/cart'),
                        child: Opacity(
                          opacity: cart.totalItems == 0 ? 0.4 : 1.0,
                          child: AnimatedScale(
                            scale: cart.totalItems > 0 ? 1.0 : 0.9,
                            duration: const Duration(milliseconds: 200),
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                const Icon(
                                  Icons.shopping_cart,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                if (cart.totalItems > 0)
                                  Positioned(
                                    right: -4,
                                    top: -4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        cart.totalItems.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  onChanged: (v) {
                    setState(() {
                      searchQuery = v;
                      _applyFilters();
                    });
                  },
                  decoration: InputDecoration(
                    hintText: "Search products",
                    prefixIcon: const Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🟢 CATEGORY ICONS
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                final isSelected = cat['name'] == selectedCategory;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedCategory = cat['name'];
                      _applyFilters();
                    });
                  },
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 26,
                          backgroundColor:
                              isSelected ? AppColors.primary : Colors.white,
                          child: Icon(
                            cat['icon'],
                            color: isSelected
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          cat['name'],
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          /// 🧺 PRODUCT GRID
          Expanded(
            child: isLoading
                ? _skeleton()
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 12,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filteredProducts.length,
                    itemBuilder: (context, index) {
                      final product = filteredProducts[index];
                      return ProductCard(
                        key: ValueKey(product['_id']),
                        product: product,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _skeleton() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 12,
        childAspectRatio: 0.72,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
