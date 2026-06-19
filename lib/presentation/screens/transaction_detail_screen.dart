import 'package:flutter/material.dart';
import '../../domain/models/transaction_model.dart';

class TransactionDetailScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailScreen({super.key, required this.transaction});

  // ── Palette ────────────────────────────────────────────────────────────────
  static const _ink = Color(0xFF0A0A0A);
  static const _muted = Color(0xFF6B6B6B);
  static const _border = Color(0xFFE8E8E8);
  static const _surface = Color(0xFFF4F4F4);

  @override
  Widget build(BuildContext context) {
    final isApproved = transaction.estado == 'APROBADO';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 40),
        children: [
          _buildStatusHeader(isApproved),
          const SizedBox(height: 24),
          _buildPaymentInfo(),
          const SizedBox(height: 24),
          _buildItemBreakdown(),
        ],
      ),
    );
  }

  // ── App bar ─────────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.only(left: 16),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            border: Border.all(color: _border),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.arrow_back_rounded, color: _ink, size: 18),
        ),
      ),
      leadingWidth: 60,
      title: const Text(
        'Detalle',
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

  // ── Status header ────────────────────────────────────────────────────────────

  Widget _buildStatusHeader(bool isApproved) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isApproved ? _ink : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: isApproved ? null : Border.all(color: _border),
            ),
            child: Icon(
              isApproved ? Icons.check_rounded : Icons.close_rounded,
              color: isApproved ? Colors.white : _muted,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isApproved ? 'Pago aprobado' : 'Pago rechazado',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.producto,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13, color: _muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Amount
          Text(
            '\$${transaction.total.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _ink,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Payment info section ─────────────────────────────────────────────────────

  Widget _buildPaymentInfo() {
    final formattedDate = _formatDate(transaction.fecha.toLocal());

    return _Section(
      title: 'Información de pago',
      child: Column(
        children: [
          _InfoRow(label: 'Fecha', value: formattedDate),
          _Divider(),
          _InfoRow(label: 'Titular', value: transaction.titular),
          _Divider(),
          _InfoRow(
            label: 'Tarjeta',
            value: '**** **** **** ${transaction.ultimos4}',
          ),
          _Divider(),
          _InfoRow(
            label: 'Estado',
            value: transaction.estado,
            valueWidget: _StatusBadge(
              isApproved: transaction.estado == 'APROBADO',
            ),
          ),
        ],
      ),
    );
  }

  // ── Item breakdown section ───────────────────────────────────────────────────

  Widget _buildItemBreakdown() {
    if (transaction.detalles.isEmpty) {
      return _Section(
        title: 'Desglose',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: const Text(
            'No hay detalles registrados para esta transacción.',
            style: TextStyle(fontSize: 13, color: _muted),
          ),
        ),
      );
    }

    final items = transaction.detalles.map((item) {
      final double unitPrice = (item['precio_unitario'] ?? 0.0).toDouble();
      final int qty = item['cantidad'] ?? 1;
      final double subtotal = unitPrice * qty;
      final String name = item['nombre'] ?? '—';
      return (name: name, qty: qty, unitPrice: unitPrice, subtotal: subtotal);
    }).toList();

    return _Section(
      title: 'Desglose de productos',
      child: Column(
        children: [
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            return Column(
              children: [
                _ProductRow(
                  name: item.name,
                  qty: item.qty,
                  unitPrice: item.unitPrice,
                  subtotal: item.subtotal,
                ),
                if (i < items.length - 1) _Divider(),
              ],
            );
          }),
          // ── Total row ──────────────────────────────────────────────
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: _border, width: 1.5)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: _ink,
                  ),
                ),
                Text(
                  '\$${transaction.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: _ink,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────────

  String _formatDate(DateTime date) {
    const months = [
      'ene',
      'feb',
      'mar',
      'abr',
      'may',
      'jun',
      'jul',
      'ago',
      'sep',
      'oct',
      'nov',
      'dic',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$min';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section wrapper
// ─────────────────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  static const _ink = Color(0xFF0A0A0A);
  static const _muted = Color(0xFF6B6B6B);
  static const _border = Color(0xFFE8E8E8);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: _muted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _border),
          ),
          child: child,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Info row
// ─────────────────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueWidget});
  final String label;
  final String value;
  final Widget? valueWidget;

  static const _ink = Color(0xFF0A0A0A);
  static const _muted = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: _muted,
              fontWeight: FontWeight.w400,
            ),
          ),
          valueWidget ??
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _ink,
                ),
              ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Product row (breakdown)
// ─────────────────────────────────────────────────────────────────────────────

class _ProductRow extends StatelessWidget {
  const _ProductRow({
    required this.name,
    required this.qty,
    required this.unitPrice,
    required this.subtotal,
  });

  final String name;
  final int qty;
  final double unitPrice;
  final double subtotal;

  static const _ink = Color(0xFF0A0A0A);
  static const _muted = Color(0xFF6B6B6B);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quantity badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F4F4),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'x$qty',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _muted,
              ),
            ),
          ),
          const SizedBox(width: 10),

          // Name + unit price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: _ink,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '\$${unitPrice.toStringAsFixed(2)} c/u',
                  style: const TextStyle(fontSize: 11, color: _muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Subtotal
          Text(
            '\$${subtotal.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: _ink,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Status badge (reused from history_screen)
// ─────────────────────────────────────────────────────────────────────────────

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.isApproved});
  final bool isApproved;

  static const _ink = Color(0xFF0A0A0A);
  static const _muted = Color(0xFF6B6B6B);
  static const _surface = Color(0xFFF4F4F4);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isApproved ? _ink.withOpacity(0.07) : _surface,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isApproved ? 'Aprobado' : 'Rechazado',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: isApproved ? _ink : _muted,
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Divider
// ─────────────────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: Color(0xFFE8E8E8));
  }
}
