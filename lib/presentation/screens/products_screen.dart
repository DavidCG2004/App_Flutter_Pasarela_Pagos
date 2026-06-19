import 'package:flutter/material.dart';
import '../../domain/repositories/i_payment_repository.dart';
import 'payment_form_screen.dart';

class ProductsScreen extends StatelessWidget {
  final IPaymentRepository repository;

  const ProductsScreen({super.key, required this.repository});

  // ── Palette ────────────────────────────────────────────────────────────────
  static const _ink = Color(0xFF0A0A0A);
  static const _muted = Color(0xFF6B6B6B);
  static const _border = Color(0xFFE8E8E8);
  static const _surface = Color(0xFFF4F4F4);

  // ── Static product list ───────────────────────────────────────────────────
  static const _products = [
    (name: 'Reloj Minimalista Negro', price: 150.00),
    (name: 'Mochila de Cuero', price: 85.50),
    (name: 'Auriculares Inalámbricos', price: 120.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
        itemCount: _products.length,
        itemBuilder: (context, index) => _ProductCard(
          name: _products[index].name,
          price: _products[index].price,
          repository: repository,
          ink: _ink,
          muted: _muted,
          border: _border,
          surface: _surface,
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: const Text(
        'Productos',
        style: TextStyle(
          color: _ink,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// Product card
// ─────────────────────────────────────────────────────────────────────────────

class _ProductCard extends StatefulWidget {
  const _ProductCard({
    required this.name,
    required this.price,
    required this.repository,
    required this.ink,
    required this.muted,
    required this.border,
    required this.surface,
  });

  final String name;
  final double price;
  final IPaymentRepository repository;
  final Color ink;
  final Color muted;
  final Color border;
  final Color surface;

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PaymentFormScreen(
              productName: widget.name,
              amount: widget.price,
              repository: widget.repository,
            ),
          ),
        );
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _pressed ? widget.ink : widget.border),
        ),
        child: Row(
          children: [
            // ── Signature: left accent bar ──────────────────────────────
            AnimatedContainer(
              duration: const Duration(milliseconds: 120),
              width: 3,
              height: 80,
              decoration: BoxDecoration(
                color: _pressed ? widget.ink : Colors.transparent,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),

            // ── Product icon placeholder ────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 16),
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: _pressed ? widget.ink : widget.surface,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.inventory_2_outlined,
                  size: 22,
                  color: _pressed ? Colors.white : widget.muted,
                ),
              ),
            ),

            // ── Name & price ────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: widget.ink,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${widget.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: widget.ink,
                    ),
                  ),
                ],
              ),
            ),

            // ── Buy chevron ─────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _pressed ? widget.ink : widget.surface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: _pressed ? Colors.white : widget.muted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
