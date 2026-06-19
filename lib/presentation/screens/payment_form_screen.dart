import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../core/utils/payment_simulator.dart';
import '../../core/utils/validators.dart';
import '../../domain/repositories/i_payment_repository.dart';
import '../providers/cart_provider.dart';
import 'result_screen.dart';

class PaymentFormScreen extends StatefulWidget {
  final String productName;
  final double amount;
  final IPaymentRepository repository;

  const PaymentFormScreen({
    super.key,
    required this.productName,
    required this.amount,
    required this.repository,
  });

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
  // ── Palette ────────────────────────────────────────────────────────────────
  static const _ink = Color(0xFF0A0A0A);
  static const _muted = Color(0xFF6B6B6B);
  static const _border = Color(0xFFE8E8E8);
  static const _surface = Color(0xFFF4F4F4);
  static const _error = Color(0xFFD94F4F);

  final _formKey = GlobalKey<FormState>();
  final _titularCtrl = TextEditingController();
  final _tarjetaCtrl = TextEditingController();
  final _expiracionCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _titularCtrl.dispose();
    _tarjetaCtrl.dispose();
    _expiracionCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  // ── Checkout logic (unchanged) ───────────────────────────────────────────────

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));
    final status = PaymentSimulator.processPayment();

    if (!mounted) return;
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final detalles = cartProvider.items.values
        .map(
          (item) => {
            'nombre': item.product.name,
            'cantidad': item.quantity,
            'precio_unitario': item.product.price,
          },
        )
        .toList();

    try {
      await widget.repository.saveTransaction(
        producto: widget.productName,
        total: widget.amount,
        titular: _titularCtrl.text,
        tarjeta: _tarjetaCtrl.text,
        estado: status,
        detalles: detalles,
      );
      if (status == 'APROBADO' && mounted) {
        cartProvider.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error guardando transacción: $e',
              style: const TextStyle(fontSize: 13),
            ),
            backgroundColor: _ink,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          ),
        );
      }
    }

    setState(() => _isLoading = false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(status: status)),
      );
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
            children: [
              _buildOrderSummary(),
              const SizedBox(height: 32),
              _buildSectionLabel('Datos de la tarjeta'),
              const SizedBox(height: 16),
              _buildField(
                controller: _titularCtrl,
                label: 'Nombre del titular',
                hint: 'Como aparece en la tarjeta',
                inputType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                validator: (val) =>
                    (val == null || val.trim().isEmpty) ? 'Requerido' : null,
              ),
              const SizedBox(height: 14),
              _buildField(
                controller: _tarjetaCtrl,
                label: 'Número de tarjeta',
                hint: '0000 0000 0000 0000',
                inputType: TextInputType.number,
                formatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  _CardNumberFormatter(),
                ],
                maxLength: 19, // 16 digits + 3 spaces
                validator: FormValidators.validateCard,
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _buildField(
                      controller: _expiracionCtrl,
                      label: 'Vencimiento',
                      hint: 'MM/YY',
                      inputType: TextInputType.number,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _ExpiryDateFormatter(),
                      ],
                      maxLength: 5, // MM/YY
                      validator: _validateExpiry,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: _buildField(
                      controller: _cvvCtrl,
                      label: 'CVV',
                      hint: '•••',
                      inputType: TextInputType.number,
                      obscureText: true,
                      formatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                      validator: FormValidators.validateCVV,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              _buildPayButton(),
            ],
          ),
        ),
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
        'Checkout',
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

  // ── Order summary ────────────────────────────────────────────────────────────

  Widget _buildOrderSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _ink,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shopping_bag_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resumen',
                  style: TextStyle(
                    fontSize: 11,
                    color: _muted,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.productName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '\$${widget.amount.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: _ink,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  // ── Section label ────────────────────────────────────────────────────────────

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: _muted,
        letterSpacing: 0.3,
      ),
    );
  }

  // ── Reusable field ───────────────────────────────────────────────────────────

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType inputType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? formatters,
    bool obscureText = false,
    int? maxLength,
    FormFieldValidator<String>? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: inputType,
      textCapitalization: textCapitalization,
      inputFormatters: formatters,
      obscureText: obscureText,
      maxLength: maxLength,
      validator: validator,
      style: const TextStyle(
        fontSize: 15,
        color: _ink,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        labelStyle: const TextStyle(
          fontSize: 13,
          color: _muted,
          fontWeight: FontWeight.w400,
        ),
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFFBBBBBB)),
        counterText: '', // hide the maxLength counter
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _error, width: 1.5),
        ),
        errorStyle: const TextStyle(
          fontSize: 11,
          color: _error,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ── Pay button ───────────────────────────────────────────────────────────────

  Widget _buildPayButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _processCheckout,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: _isLoading ? const Color(0xFF3A3A3A) : _ink,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Text(
                'Pagar ahora',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
      ),
    );
  }

  // ── Validators ───────────────────────────────────────────────────────────────

  String? _validateExpiry(String? val) {
    if (val == null || val.isEmpty) return 'Requerido';
    if (val.length < 5) return 'Formato inválido';
    final parts = val.split('/');
    final month = int.tryParse(parts[0]);
    if (month == null || month < 1 || month > 12) return 'Mes inválido';
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Expiry date formatter  →  inserts "/" automatically after MM
// Input: digits only  |  Output: MM/YY
// ─────────────────────────────────────────────────────────────────────────────

class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll('/', '');

    // Cap at 4 digits (MMYY)
    final capped = digits.length > 4 ? digits.substring(0, 4) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < capped.length; i++) {
      if (i == 2) buffer.write('/');
      buffer.write(capped[i]);
    }

    final result = buffer.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Card number formatter  →  groups digits as  0000 0000 0000 0000
// ─────────────────────────────────────────────────────────────────────────────

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final capped = digits.length > 16 ? digits.substring(0, 16) : digits;

    final buffer = StringBuffer();
    for (int i = 0; i < capped.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(capped[i]);
    }

    final result = buffer.toString();
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
