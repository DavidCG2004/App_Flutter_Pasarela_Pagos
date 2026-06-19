import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../domain/repositories/i_payment_repository.dart';
import '../providers/cart_provider.dart';
import 'catalog_screen.dart';
import 'cart_screen.dart';
import 'history_screen.dart';

class MainScreen extends StatefulWidget {
  final IProductRepository productRepository;
  final IPaymentRepository paymentRepository;

  const MainScreen({
    super.key,
    required this.productRepository,
    required this.paymentRepository,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      CatalogScreen(productRepository: widget.productRepository),
      CartScreen(paymentRepository: widget.paymentRepository),
      HistoryScreen(paymentRepository: widget.paymentRepository),
    ];
  }

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // IndexedStack preserves page state across tab switches
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: _BottomNav(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Custom bottom nav — no BottomNavigationBar widget (avoids Material defaults)
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selectedIndex, required this.onTap});

  final int selectedIndex;
  final ValueChanged<int> onTap;

  static const _ink = Color(0xFF0A0A0A);
  static const _muted = Color(0xFF9B9B9B);
  static const _border = Color(0xFFE8E8E8);

  static const _items = [
    _NavItem(
      icon: Icons.storefront_outlined,
      activeIcon: Icons.storefront_rounded,
      label: 'Catálogo',
    ),
    _NavItem(
      icon: Icons.shopping_bag_outlined,
      activeIcon: Icons.shopping_bag_rounded,
      label: 'Carrito',
    ),
    _NavItem(
      icon: Icons.receipt_long_outlined,
      activeIcon: Icons.receipt_long_rounded,
      label: 'Historial',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: _border)),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomPadding),
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(_items.length, (index) {
              final isSelected = index == selectedIndex;
              final item = _items[index];

              // Cart tab gets a badge overlay
              final iconWidget = index == 1
                  ? _CartIconWithBadge(
                      icon: isSelected ? item.activeIcon : item.icon,
                      isSelected: isSelected,
                    )
                  : Icon(
                      isSelected ? item.activeIcon : item.icon,
                      size: 22,
                      color: isSelected ? _ink : _muted,
                    );

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => onTap(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        iconWidget,
                        const SizedBox(height: 4),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 160),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.w700
                                : FontWeight.w400,
                            color: isSelected ? _ink : _muted,
                            letterSpacing: 0.1,
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Nav item data class
// ─────────────────────────────────────────────────────────────────────────────

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}

// ─────────────────────────────────────────────────────────────────────────────
// Cart icon with badge
// ─────────────────────────────────────────────────────────────────────────────

class _CartIconWithBadge extends StatelessWidget {
  const _CartIconWithBadge({required this.icon, required this.isSelected});
  final IconData icon;
  final bool isSelected;

  static const _ink = Color(0xFF0A0A0A);
  static const _muted = Color(0xFF9B9B9B);

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cart, _) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, size: 22, color: isSelected ? _ink : _muted),
            if (cart.itemCount > 0)
              Positioned(
                right: -6,
                top: -5,
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: cart.itemCount > 0 ? 1.0 : 0.0,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    decoration: BoxDecoration(
                      color: _ink,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      cart.itemCount > 99 ? '99+' : '${cart.itemCount}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
