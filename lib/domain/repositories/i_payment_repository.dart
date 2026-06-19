import '../models/transaction_model.dart';

abstract class IPaymentRepository {
  Future<void> saveTransaction({
    required String producto,
    required double total,
    required String titular,
    required String tarjeta, // Se truncará internamente por seguridad
    required String estado,
    required List<Map<String, dynamic>> detalles,
  });
  
  Future<List<TransactionModel>> getHistory();
}
