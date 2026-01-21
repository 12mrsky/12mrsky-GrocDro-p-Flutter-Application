import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/app_colors.dart';
import '../../domain/providers/cart_provider.dart';
import '../../domain/services/api_service.dart';
import 'cart_screen.dart';
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

  final ScrollController _scrollController = ScrollController();
  bool _isCollapsed = false;

  final List<Map<String, dynamic>> categories = [
    {"name": "All", "icon": Icons.grid_view},
    {"name": "Fruits", "icon": Icons.local_grocery_store},
    {"name": "Vegetables", "icon": Icons.eco},
    {"name": "Snacks", "icon": Icons.fastfood},
    {"name": "Beverages", "icon": Icons.local_drink},
    {"name": "Bakery", "icon": Icons.cake},
  ];

  @override
  void initState() {
    super.initState();
    _loadProducts();

    _scrollController.addListener(() {
      if (_scrollController.offset > 30 && !_isCollapsed) {
        setState(() => _isCollapsed = true);
      } else if (_scrollController.offset <= 30 && _isCollapsed) {
        setState(() => _isCollapsed = false);
      }
    });
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

  void _openCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CartScreen()),
    );
  }

  double _responsiveGap(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    if (w > 900) return 20;
    if (w > 600) return 16;
    return 12;
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

      /// 🛒 STICKY VIEW CART BAR
      bottomNavigationBar: cart.totalItems == 0
          ? null
          : InkWell(
              onTap: _openCart,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: const Offset(0, -3),
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
                      ),
                    ),
                    const Text(
                      "View Cart →",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

      body: Column(
        children: [
          /// 🔰 STICKY + ANIMATED HEADER
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: EdgeInsets.fromLTRB(
              16,
              _isCollapsed ? 32 : 48,
              16,
              _isCollapsed ? 10 : 16,
            ),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.primary, Color(0xFF7E57C2)],
              ),
              boxShadow: _isCollapsed
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      )
                    ]
                  : [],
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
                    InkWell(
                      onTap: cart.totalItems == 0 ? null : _openCart,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          const Icon(Icons.shopping_cart,
                              color: Colors.white, size: 26),
                          if (cart.totalItems > 0)
                            Positioned(
                              right: -4,
                              top: -4,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
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
                  ],
                ),
                const SizedBox(height: 12),
                AnimatedOpacity(
                  opacity: _isCollapsed ? 0.9 : 1,
                  duration: const Duration(milliseconds: 250),
                  child: TextField(
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
                ),
              ],
            ),
          ),

          /// 🌫 DIVIDER WITH SHADOW
          Container(
            height: 8,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
          ),

          SizedBox(height: _responsiveGap(context)),

          /// 🟢 CATEGORY LIST
          SizedBox(
            height: 90,
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

          /// 🧺 PRODUCTS
          Expanded(
            child: isLoading
                ? _skeleton()
                : GridView.builder(
                    controller: _scrollController,
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
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
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
