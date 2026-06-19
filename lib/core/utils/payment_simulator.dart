import 'dart:math';

class PaymentSimulator {
  static String processPayment() {
    // 80% de probabilidad de aprobación para una mejor experiencia de prueba
    final isApproved = Random().nextInt(100) > 20; 
    return isApproved ? 'APROBADO' : 'RECHAZADO';
  }
  
  static String extractLast4(String card) {
    final cleanCard = card.replaceAll(' ', '');
    return cleanCard.substring(cleanCard.length - 4);
  }
}
