import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/i_payment_repository.dart';
import '../../domain/models/transaction_model.dart';

class SupabasePaymentRepository implements IPaymentRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<void> saveTransaction({
    required String producto,
    required double total,
    required String titular,
    required String tarjeta,
    required String estado,
    required List<Map<String, dynamic>> detalles,
  }) async {
    // SECURITY: Truncado de tarjeta a nivel de repositorio.
    final ultimos4 = tarjeta.replaceAll(' ', '');
    final safeDigits = ultimos4.substring(ultimos4.length - 4);

    try {
      await _client.from('pagos_simulados').insert({
        'producto': producto,
        'total': total,
        'titular': titular,
        'ultimos4': safeDigits,
        'estado': estado,
        'detalles': detalles,
        // 'fecha' se maneja automáticamente en PostgreSQL con default now()
      });
    } catch (e) {
      throw Exception('Error guardando la transacción: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getHistory() async {
    try {
      final response = await _client
          .from('pagos_simulados')
          .select()
          .order('fecha', ascending: false);

      return (response as List).map((json) => TransactionModel(
        id: json['id'].toString(),
        producto: json['producto'] ?? '',
        total: (json['total'] as num).toDouble(),
        titular: json['titular'] ?? '',
        ultimos4: json['ultimos4'] ?? '',
        estado: json['estado'] ?? '',
        fecha: DateTime.parse(json['fecha']),
        detalles: List<Map<String, dynamic>>.from(json['detalles'] ?? []),
      )).toList();
    } catch (e) {
      throw Exception('Error obteniendo el historial: $e');
    }
  }
}
