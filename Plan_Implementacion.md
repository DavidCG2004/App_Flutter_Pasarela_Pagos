# Plan de Implementación: Pasarela de Pago Simulada en Flutter 📱💳

Como desarrollador senior, mi enfoque para este proyecto es garantizar que el código sea **escalable, mantenible y seguro**, utilizando **Clean Architecture** (separación de responsabilidades) y el patrón **Repository** para abstraer la base de datos (Supabase o Firebase). 

A nivel visual, aplicaremos principios de **UI/UX minimalista**, con uso intensivo de espacios en blanco (White Space), jerarquía tipográfica clara y una **paleta monocromática** (blanco, negro y escalas de gris) que transmite elegancia y profesionalismo.

---

## 1. Arquitectura y Estructura del Proyecto 🏗️

Utilizaremos una arquitectura basada en características (**Feature-First**) combinada con el patrón **Repository** para facilitar el cambio entre Firebase y Supabase sin afectar la UI.

```text
lib/
 ┣ core/
 ┃ ┣ theme/             # Configuración de paleta monocromática y tipografía
 ┃ ┣ utils/             # Validadores y formateadores (tarjetas, fechas)
 ┣ domain/
 ┃ ┣ models/            # Product, Transaction (Modelos de datos)
 ┃ ┣ repositories/      # IPaymentRepository (Interfaz abstracta)
 ┣ data/
 ┃ ┣ repositories/      # SupabasePaymentRepo / FirebasePaymentRepo
 ┣ presentation/
 ┃ ┣ screens/           # Products, PaymentForm, Result, History
 ┃ ┣ widgets/           # Botones, Inputs, Tarjetas reutilizables
 ┣ main.dart            # Punto de entrada e inyección de dependencias
```

---

## 2. Sistema de Diseño (UI/UX Minimalista) 🎨

Implementaremos un tema estricto en el `core/theme/app_theme.dart`. Se evitarán las sombras excesivas, prefiriendo bordes finos (`1px solid grey`) y un alto contraste para la accesibilidad.

### Paleta Monocromática
*   **Fondo principal:** Blanco (`#FFFFFF`)
*   **Superficies / Tarjetas:** Gris muy claro (`#F9F9F9`)
*   **Textos principales / Botones:** Negro (`#111111`)
*   **Textos secundarios / Bordes:** Gris medio (`#888888` / `#E5E5E5`)

### Código del Tema en Flutter
```dart
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData get minimalistTheme => ThemeData(
        scaffoldBackgroundColor: Colors.white,
        colorScheme: const ColorScheme.light(
          primary: Colors.black,
          secondary: Colors.grey,
          surface: Colors.white,
          error: Colors.black54, // Errores en gris oscuro para mantener el monocromatismo
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.black),
          titleTextStyle: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF9F9F9),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Color(0xFFE5E5E5)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.black),
          ),
          labelStyle: const TextStyle(color: Colors.black54),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2),
          ),
        ),
      );
}
```

---

## 3. Capa de Dominio (Modelos y Repositorio) 🧠

Definimos los modelos puros y la interfaz para el backend. Esto nos permite usar **Firebase** o **Supabase** sin cambiar ni una línea de la interfaz gráfica.

### Modelo de Transacción (`transaction_model.dart`)
```dart
class TransactionModel {
  final String id;
  final String producto;
  final double total;
  final String titular;
  final String ultimos4;
  final String estado;
  final DateTime fecha;

  TransactionModel({
    required this.id,
    required this.producto,
    required this.total,
    required this.titular,
    required this.ultimos4,
    required this.estado,
    required this.fecha,
  });
}
```

### Contrato del Repositorio (`i_payment_repository.dart`)
```dart
abstract class IPaymentRepository {
  Future<void> saveTransaction({
    required String producto,
    required double total,
    required String titular,
    required String tarjeta, // Se truncará internamente por seguridad
    required String estado,
  });
  
  Future<List<TransactionModel>> getHistory();
}
```

---

## 4. Lógica de Negocio y Seguridad 🛡️

Crearemos una clase de utilidad para las validaciones estrictas requeridas en el formulario.

### Validadores (`validators.dart`)
```dart
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
```

### Simulador de Pago (`payment_simulator.dart`)
```dart
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
```

---

## 5. Implementación de Vistas (UI Minimalista) 📱

### 5.1. Pantalla de Formulario de Pago (`payment_form_screen.dart`)
Sigue la ley de Fitts (botones grandes y accesibles) y usa el espacio en blanco para guiar la vista del usuario de arriba hacia abajo.

```dart
import 'package:flutter/material.dart';

class PaymentFormScreen extends StatefulWidget {
  final String productName;
  final double amount;
  final IPaymentRepository repository;

  const PaymentFormScreen({
    Key? key,
    required this.productName,
    required this.amount,
    required this.repository,
  }) : super(key: key);

  @override
  State<PaymentFormScreen> createState() => _PaymentFormScreenState();
}

class _PaymentFormScreenState extends State<PaymentFormScreen> {
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

  Future<void> _processCheckout() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // 1. Simular Pago local
    await Future.delayed(const Duration(seconds: 2)); // UX: Feedback de procesamiento
    final status = PaymentSimulator.processPayment();

    // 2. Guardar en Backend (Firebase/Supabase) asegurando solo guardar los últimos 4 dígitos
    await widget.repository.saveTransaction(
      producto: widget.productName,
      total: widget.amount,
      titular: _titularCtrl.text,
      tarjeta: _tarjetaCtrl.text, // El repo se encargará de truncarla
      estado: status,
    );

    setState(() => _isLoading = false);

    // 3. Navegar a resultado
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(status: status)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              // Resumen minimalista
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Resumen de compra', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('\$${widget.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              // Inputs de Tarjeta
              TextFormField(
                controller: _titularCtrl,
                decoration: const InputDecoration(labelText: 'Nombre del Titular'),
                validator: (val) => val!.isEmpty ? 'Requerido' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _tarjetaCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Número de Tarjeta'),
                validator: FormValidators.validateCard,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _expiracionCtrl,
                      decoration: const InputDecoration(labelText: 'MM/YY', hintText: '12/25'),
                      validator: (val) => val!.isEmpty ? 'Requerido' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _cvvCtrl,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'CVV'),
                      validator: FormValidators.validateCVV,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 48),
              
              // Botón de pago
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _processCheckout,
                  child: _isLoading 
                      ? const SizedBox(
                          height: 20, width: 20, 
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                        )
                      : const Text('PAGAR AHORA'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
```

### 5.2 Pantalla de Resultados (`result_screen.dart`)
Una pantalla clara, usando íconos vectoriales básicos (check/cross) con colores monocromáticos.

```dart
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  final String status;
  const ResultScreen({Key? key, required this.status}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isApproved = status == 'APROBADO';
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isApproved ? Icons.check_circle_outline : Icons.error_outline,
                size: 100,
                color: Colors.black, // Manteniendo el tema monocromático
              ),
              const SizedBox(height: 24),
              Text(
                isApproved ? 'Pago Exitoso' : 'Pago Rechazado',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                isApproved 
                  ? 'Tu transacción simulada ha sido registrada.' 
                  : 'Hubo un error al procesar tu tarjeta.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: const BorderSide(color: Colors.black),
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                  child: const Text('VOLVER AL INICIO'),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
```

---

## 6. Integración del Backend (Ejemplo Supabase) ☁️

Implementación concreta de nuestro repositorio usando Supabase, respetando las buenas prácticas de seguridad (truncado antes de enviar al backend).

```dart
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/repositories/i_payment_repository.dart';

class SupabasePaymentRepository implements IPaymentRepository {
  final SupabaseClient _client = Supabase.instance.client;

  @override
  Future<void> saveTransaction({
    required String producto,
    required double total,
    required String titular,
    required String tarjeta,
    required String estado,
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
        // 'fecha' se maneja automáticamente en PostgreSQL con default now()
      });
    } catch (e) {
      throw Exception('Error guardando la transacción: $e');
    }
  }

  @override
  Future<List<TransactionModel>> getHistory() async {
    // Implementación del Select para el historial
    // ...
    return [];
  }
}
```

---

## 7. Entregables y Checklist de Buenas Prácticas ✅

Al finalizar el taller, los estudiantes deben verificar que su aplicación cumple con lo siguiente:

1. **UX/UI:** Uso estricto de componentes nativos estilizados bajo la paleta monocromática estipulada en `ThemeData`. Los inputs deben tener un área táctil mínima de 48x48dp.
2. **Clean Code:** Los métodos del ciclo de vida (`dispose()`) están implementados en el `TextEditingController` para evitar fugas de memoria (*Memory Leaks*).
3. **Seguridad (Zero-Trust Local):** El CVV y la tarjeta completa **no salen** de la clase `_PaymentFormScreenState`. El truncamiento se hace antes de hacer el envío HTTP al BaaS.
4. **Resiliencia UI:** Uso de `setState` para bloquear el botón de pago (`_isLoading = true`) e impedir el doble envío (*Double Tap Submission*).