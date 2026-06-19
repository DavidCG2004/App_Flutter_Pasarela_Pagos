class FormValidators {
  static String? validateCard(String? value) {
    if (value == null || value.isEmpty) return 'Requerido';
    final cleanValue = value.replaceAll(' ', '');
    if (cleanValue.length < 16) return 'Debe tener al menos 16 dígitos';
    if (int.tryParse(cleanValue) == null) return 'Solo números';
    return null;
  }

  static String? validateCVV(String? value) {
    if (value == null || value.isEmpty) return 'Requerido';
    if (value.length != 3) return 'Debe tener 3 dígitos';
    return null;
  }
}
