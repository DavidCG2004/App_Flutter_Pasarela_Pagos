import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/supabase_payment_repository.dart';
import 'data/repositories/api_product_repository.dart';
import 'presentation/providers/cart_provider.dart';
import 'presentation/providers/catalog_provider.dart';
import 'presentation/screens/splash_screen.dart'; // ← nuevo import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://zjjalezwyjrlykkhtwcj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InpqamFsZXp3eWpybHlra2h0d2NqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxNzU1ODQsImV4cCI6MjA5Mzc1MTU4NH0._yegNjxY491ppNIj5BFAgtYK5HwlWVipMFKc9bFCOyg',
  );

  final paymentRepository = SupabasePaymentRepository();
  final productRepository = ApiProductRepository();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(
          create: (_) => CatalogProvider(repository: productRepository),
        ),
      ],
      child: MyApp(
        paymentRepository: paymentRepository,
        productRepository: productRepository,
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final SupabasePaymentRepository paymentRepository;
  final ApiProductRepository productRepository;

  const MyApp({
    super.key,
    required this.paymentRepository,
    required this.productRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pasarela V2',
      theme: AppTheme.minimalistTheme,
      debugShowCheckedModeBanner: false,
      home: SplashScreen(
        // ← reemplaza MainScreen
        productRepository: productRepository,
        paymentRepository: paymentRepository,
      ),
    );
  }
}
