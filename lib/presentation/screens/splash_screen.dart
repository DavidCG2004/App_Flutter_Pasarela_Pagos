import 'package:flutter/material.dart';
import 'main_screen.dart';
import '../../domain/repositories/i_product_repository.dart';
import '../../domain/repositories/i_payment_repository.dart';

/// Splash screen shown on app launch.
///
/// Displays the brand mark centred on white, fades in,
/// then navigates to [MainScreen] after a brief pause.
///
/// Usage in main.dart:
/// ```dart
/// home: SplashScreen(
///   productRepository: productRepo,
///   paymentRepository: paymentRepo,
/// ),
/// ```
class SplashScreen extends StatefulWidget {
  final IProductRepository productRepository;
  final IPaymentRepository paymentRepository;

  const SplashScreen({
    super.key,
    required this.productRepository,
    required this.paymentRepository,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _scale;

  static const _ink = Color(0xFF0A0A0A);
  static const _muted = Color(0xFF6B6B6B);

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _scale = Tween<double>(
      begin: 0.88,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Start animation, then navigate after total delay
    _ctrl.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, __, ___) => MainScreen(
            productRepository: widget.productRepository,
            paymentRepository: widget.paymentRepository,
          ),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Brand mark ─────────────────────────────────────────────
                // Uses the same SVG paths as the app icon,
                // rendered as Flutter CustomPaint for zero dependencies.
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CustomPaint(painter: _SMarkPainter()),
                ),
                const SizedBox(height: 24),

                // ── App name ───────────────────────────────────────────────
                const Text(
                  'Store',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                    letterSpacing: -0.8,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Tu tienda minimalista',
                  style: TextStyle(
                    fontSize: 13,
                    color: _muted,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.1,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// S mark painter — mirrors the SVG icon paths exactly, no asset needed
// ─────────────────────────────────────────────────────────────────────────────

class _SMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Scale factor relative to the 1024-unit SVG viewBox
    final double sx = w / 1024;
    final double sy = h / 1024;

    final paint = Paint()
      ..color = const Color(0xFF0A0A0A)
      ..style = PaintingStyle.stroke
      ..strokeWidth =
          72 *
          sx // 68 in SVG, slight boost at small size
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Top arc: (364,370) → arc centre (512,222→510) → (660,370)
    path.moveTo(364 * sx, 370 * sy);
    path.arcToPoint(
      Offset(512 * sx, 222 * sy),
      radius: Radius.circular(148 * sx),
      clockwise: false,
    );
    path.arcToPoint(
      Offset(660 * sx, 370 * sy),
      radius: Radius.circular(148 * sx),
      clockwise: false,
    );

    canvas.drawPath(path, paint);

    // Diagonal connector
    canvas.drawLine(
      Offset(364 * sx, 370 * sy),
      Offset(660 * sx, 654 * sy),
      paint,
    );

    // Bottom arc: (364,654) → (512,802) → (660,654)
    final path2 = Path();
    path2.moveTo(364 * sx, 654 * sy);
    path2.arcToPoint(
      Offset(512 * sx, 802 * sy),
      radius: Radius.circular(148 * sx),
      clockwise: true,
    );
    path2.arcToPoint(
      Offset(660 * sx, 654 * sy),
      radius: Radius.circular(148 * sx),
      clockwise: true,
    );

    canvas.drawPath(path2, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
