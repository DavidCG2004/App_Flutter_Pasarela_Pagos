import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/models/product_model.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../providers/cart_provider.dart';
import '../providers/catalog_provider.dart';

class CatalogScreen extends StatefulWidget {
  final IProductRepository productRepository;

  const CatalogScreen({super.key, required this.productRepository});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  Timer? _debounce;

  // ── Palette ────────────────────────────────────────────────────────────────
  static const _ink = Color(0xFF0A0A0A);
  static const _muted = Color(0xFF6B6B6B);
  static const _border = Color(0xFFE8E8E8);
  static const _surface = Color(0xFFF4F4F4);

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      Provider.of<CatalogProvider>(context, listen: false).loadMore();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      Provider.of<CatalogProvider>(context, listen: false).search(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CatalogProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // ── Search bar ───────────────────────────────────────────────────
          _buildSearchBar(),

          // ── Category chips ───────────────────────────────────────────────
          if (provider.categories.isNotEmpty) _buildCategoryBar(provider),

          // ── Product list ─────────────────────────────────────────────────
          Expanded(child: _buildProductList(provider)),
        ],
      ),
    );
  }

  // ── App bar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Catálogo',
        style: TextStyle(
          color: Color(0xFF0A0A0A),
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _border),
      ),
    );
  }

  // ── Search bar ───────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      child: TextField(
        controller: _searchCtrl,
        onChanged: _onSearchChanged,
        style: const TextStyle(fontSize: 14, color: _ink),
        decoration: InputDecoration(
          hintText: 'Buscar productos…',
          hintStyle: const TextStyle(color: _muted, fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: _muted, size: 20),
          filled: true,
          fillColor: _surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: _ink, width: 1.5),
          ),
        ),
      ),
    );
  }

  // ── Category bar ─────────────────────────────────────────────────────────────

  Widget _buildCategoryBar(CatalogProvider provider) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          SizedBox(
            height: 48,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              itemCount: provider.categories.length + 1,
              itemBuilder: (context, index) {
                final isAll = index == 0;
                final catName = isAll ? '' : provider.categories[index - 1];
                final isSelected = isAll
                    ? provider.currentCategory.isEmpty
                    : provider.currentCategory == catName;
                final displayLabel = isAll
                    ? 'Todos'
                    : catName[0].toUpperCase() +
                          catName.substring(1).replaceAll('-', ' ');

                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _CategoryChip(
                    label: displayLabel,
                    isSelected: isSelected,
                    onTap: () {
                      if (isAll) {
                        provider.clearFilters();
                      } else {
                        provider.setCategory(catName);
                      }
                      _searchCtrl.clear();
                    },
                  ),
                );
              },
            ),
          ),
          Container(height: 1, color: _border),
        ],
      ),
    );
  }

  // ── Product list ─────────────────────────────────────────────────────────────

  Widget _buildProductList(CatalogProvider provider) {
    if (provider.products.isEmpty && provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _ink, strokeWidth: 1.5),
      );
    }
    if (provider.products.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.inbox_outlined, size: 40, color: _muted),
            const SizedBox(height: 12),
            Text(
              'Sin resultados',
              style: TextStyle(
                color: _muted,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
      itemCount: provider.products.length + (provider.hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == provider.products.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: CircularProgressIndicator(color: _ink, strokeWidth: 1.5),
            ),
          );
        }
        return _ProductCard(product: provider.products[index]);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Category chip
// ─────────────────────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  static const _ink = Color(0xFF0A0A0A);
  static const _border = Color(0xFFE8E8E8);
  static const _muted = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? _ink : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSelected ? _ink : _border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            color: isSelected ? Colors.white : _muted,
            letterSpacing: 0.1,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product card — signature: left accent bar on hover/press
// ─────────────────────────────────────────────────────────────────────────────

class _ProductCard extends StatefulWidget {
  const _ProductCard({required this.product});
  final ProductModel product;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _pressed = false;

  static const _ink = Color(0xFF0A0A0A);
  static const _muted = Color(0xFF6B6B6B);
  static const _border = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
    final outOfStock = product.stockQuantity <= 0;

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _pressed ? _ink : _border),
        ),
        child: Row(
          children: [
            // ── Signature: left accent bar ──────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 3,
              height: 88,
              decoration: BoxDecoration(
                color: _pressed ? _ink : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),

            // ── Product image ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.grey,
                    BlendMode.saturation,
                  ),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
              ),
            ),

            // ── Product info ────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          '\$${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: _ink,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          outOfStock
                              ? 'Sin stock'
                              : 'Stock: ${product.stockQuantity}',
                          style: TextStyle(
                            fontSize: 12,
                            color: outOfStock ? Colors.red.shade400 : _muted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── Add button ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _AddButton(
                enabled: !outOfStock,
                onPressed: () {
                  Provider.of<CartProvider>(
                    context,
                    listen: false,
                  ).addItem(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text(
                        'Agregado al carrito',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      backgroundColor: _ink,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      width: 64,
      height: 64,
      color: const Color(0xFFF4F4F4),
      child: const Icon(
        Icons.image_not_supported_outlined,
        size: 24,
        color: Color(0xFF6B6B6B),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add button
// ─────────────────────────────────────────────────────────────────────────────

class _AddButton extends StatelessWidget {
  const _AddButton({required this.enabled, required this.onPressed});
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: enabled ? const Color(0xFF0A0A0A) : const Color(0xFFF4F4F4),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          enabled ? 'Agregar' : 'Agotado',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: enabled ? Colors.white : const Color(0xFF6B6B6B),
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }
}
