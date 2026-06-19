import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String status;

  const ResultScreen({super.key, required this.status});

  // ── Palette ────────────────────────────────────────────────────────────────
  static const _ink = Color(0xFF0A0A0A);
  static const _muted = Color(0xFF6B6B6B);
  static const _border = Color(0xFFE8E8E8);
  static const _surface = Color(0xFFF4F4F4);

  @override
  Widget build(BuildContext context) {
    final isApproved = status == 'APROBADO';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Icon ────────────────────────────────────────────────────
              _StatusIcon(isApproved: isApproved),
              const SizedBox(height: 32),

              // ── Title ───────────────────────────────────────────────────
              Text(
                isApproved ? 'Pago exitoso' : 'Pago rechazado',
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                  letterSpacing: -0.8,
                  height: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // ── Subtitle ─────────────────────────────────────────────
              Text(
                isApproved
                    ? 'Tu transacción fue registrada correctamente.'
                    : 'No pudimos procesar tu tarjeta.\nRevisa los datos e intenta de nuevo.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: _muted,
                  height: 1.6,
                ),
              ),

              const Spacer(flex: 2),

              // ── Status pill ──────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: _border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: isApproved ? _ink : const Color(0xFFBBBBBB),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isApproved
                          ? 'Transacción aprobada'
                          : 'Transacción rechazada',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _ink,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(flex: 1),

              // ── CTA button ───────────────────────────────────────────
              _ReturnButton(
                label: 'Volver al inicio',
                onTap: () =>
                    Navigator.popUntil(context, (route) => route.isFirst),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Animated status icon
// ─────────────────────────────────────────────────────────────────────────────

class _StatusIcon extends StatefulWidget {
  const _StatusIcon({required this.isApproved});
  final bool isApproved;

  @override
  State<_StatusIcon> createState() => _StatusIconState();
}

class _StatusIconState extends State<_StatusIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  static const _ink = Color(0xFF0A0A0A);
  static const _surface = Color(0xFFF4F4F4);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: widget.isApproved ? _ink : _surface,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Icon(
            widget.isApproved ? Icons.check_rounded : Icons.close_rounded,
            color: widget.isApproved ? Colors.white : const Color(0xFF6B6B6B),
            size: 44,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Return button with press feedback
// ─────────────────────────────────────────────────────────────────────────────

class _ReturnButton extends StatefulWidget {
  const _ReturnButton({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  State<_ReturnButton> createState() => _ReturnButtonState();
}

class _ReturnButtonState extends State<_ReturnButton> {
  bool _pressed = false;

  static const _ink = Color(0xFF0A0A0A);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _pressed ? const Color(0xFF3A3A3A) : _ink,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }
}
