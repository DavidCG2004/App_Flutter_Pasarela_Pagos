class TransactionModel {
  final String id;
  final String producto;
  final double total;
  final String titular;
  final String ultimos4;
  final String estado;
  final DateTime fecha;
  final List<Map<String, dynamic>> detalles;

  TransactionModel({
    required this.id,
    required this.producto,
    required this.total,
    required this.titular,
    required this.ultimos4,
    required this.estado,
    required this.fecha,
    this.detalles = const [],
  });
}
