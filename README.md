# 🚀 Pasarela V2 

![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-Ready-000000?style=for-the-badge&logo=apple&logoColor=white)
![Android](https://img.shields.io/badge/Android-Ready-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)

## 📖 Visión General y Propuesta de Valor

**Pasarela V2** es una solución móvil de comercio electrónico y pasarela de pagos de última generación. Creada para maximizar las tasas de conversión, esta aplicación resuelve la fricción común en los procesos de *checkout* móviles, ofreciendo una experiencia de compra ultra-rápida, segura y visualmente inmersiva.

**¿Por qué Pasarela V2? (ROI y Ventaja Competitiva)**
- **Conversión Optimizada:** Flujos de usuario diseñados bajo principios de UX/UI minimalistas que reducen el abandono del carrito.
- **Escalabilidad Inmediata:** Arquitectura modular (*Clean Architecture*) que permite iterar nuevas funcionalidades o integrar nuevas pasarelas de pago sin afectar el núcleo del negocio.
- **Historial y Trazabilidad:** Las transacciones se almacenan de manera segura en Supabase, ofreciendo historiales de compra detallados al instante.

## ✨ Características Principales

- 🛍️ **Catálogo Dinámico:** Consumo de productos en tiempo real vía REST API con gestión de estado reactiva, paginación o carga asíncrona.
- 🛒 **Carrito de Compras Inteligente:** Gestión de órdenes, cálculos de subtotales y estado global en tiempo real.
- 💳 **Pasarela de Pagos Segura:** Integración nativa con backend transaccional a través de `SupabasePaymentRepository`.
- 📊 **Historial de Transacciones:** Visualización del historial de compras y detalles de transacciones (`history_screen` y `transaction_detail_screen`).
- 🎨 **Diseño Minimalista (UI/UX):** Tema personalizado (AppTheme) enfocado en la claridad visual y el protagonismo del producto.
- ⚡ **Experiencia de Arranque:** *Splash screen* con branding nativo (Dark/Light mode support) y validación de estado inicial sin latencia perceptible.

## 📱 Capturas de Pantalla

A continuación se muestra el flujo principal de la aplicación:

| Splash & Home | Catálogo de Productos | Carrito de Compras |
| :---: | :---: | :---: |
| <img width="220"  alt="WhatsApp Image 2026-06-19 at 3 58 13 PM" src="https://github.com/user-attachments/assets/0386c1db-db92-407a-9fcb-6f2660d8c07e" /> 
<img width="220" alt="WhatsApp Image 2026-06-19 at 3 58 12 PM" src="https://github.com/user-attachments/assets/82478377-8c25-4a6f-bd26-739ddd72a64d" />

| <img src="assets/screenshots/catalog.png" width="220" alt="Catálogo"/> | <img src="assets/screenshots/cart.png" width="220" alt="Carrito"/> |

| Pasarela de Pagos | Resultado de Transacción | Historial de Compras |
| :---: | :---: | :---: |
| <img src="assets/screenshots/payment.png" width="220" alt="Formulario de Pago"/> | <img src="assets/screenshots/result.png" width="220" alt="Resultado"/> | <img src="assets/screenshots/history.png" width="220" alt="Historial"/> |

*(Nota: Reemplaza las rutas `assets/screenshots/...` con tus imágenes reales o elimina las columnas que no apliquen).*

## 🛠️ Tech Stack y Arquitectura

El proyecto está diseñado bajo los principios de **Clean Architecture**, promoviendo la separación de responsabilidades:

- **Framework:** Flutter (Material 3 & Native Splash)
- **Lenguaje:** Dart
- **Gestión de Estado:** `provider` (Manejo de estado global reactivo mediante `CartProvider` y `CatalogProvider`)
- **Backend & BaaS:** `supabase_flutter` (Base de datos y transacciones)
- **Red:** `http` para consumo de APIs REST externas (`api_product_repository.dart`)
- **Hardware/Media:** `image_picker`

## 🏗️ Estructura del Proyecto (`/lib`)

El código fuente está altamente modularizado:

```text
lib/
 ├── core/                    # Núcleo de la aplicación
 │    ├── theme/              # Configuraciones de diseño (AppTheme)
 │    └── utils/              # Utilidades, formateadores y helpers compartidos
 │
 ├── data/                    # Capa de datos e integraciones externas
 │    └── repositories/       # Implementaciones concretas (SupabasePaymentRepository, ApiProductRepository)
 │
 ├── domain/                  # Lógica de negocio pura
 │    ├── models/             # Entidades de negocio (Product, CartItem, Transaction, ProductResponse)
 │    └── repositories/       # Interfaces o contratos de los repositorios
 │
 ├── presentation/            # Capa de Interfaz de Usuario (UI)
 │    ├── providers/          # Controladores de estado global (CartProvider, CatalogProvider)
 │    └── screens/            # Vistas principales de la App:
 │         ├── splash_screen.dart           # Pantalla de carga nativa
 │         ├── main_screen.dart             # Scaffold principal con BottomNavigationBar
 │         ├── catalog_screen.dart          # Listado principal de la tienda
 │         ├── products_screen.dart         # Detalles/Subcategorías de productos
 │         ├── cart_screen.dart             # Resumen del carrito de compras
 │         ├── payment_form_screen.dart     # Formulario de tarjeta/pago seguro
 │         ├── result_screen.dart           # Pantalla de éxito o fallo de la compra
 │         ├── history_screen.dart          # Historial general de transacciones
 │         └── transaction_detail_screen.dart # Detalle de una orden pagada
 │
 └── main.dart                # Punto de entrada, configuración de Supabase e Inyección de Providers
```

## ⚙️ Requisitos Previos

Asegúrate de tener instalado y configurado en tu entorno local:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Versión 3.11.4 o superior)
- [Dart SDK](https://dart.dev/get-dart)
- Credenciales de **Supabase** configuradas en `main.dart`

## 🚀 Instalación y Ejecución

Sigue estos pasos para levantar el entorno de desarrollo:

1. **Clona el repositorio**
   ```bash
   git clone https://github.com/tu-usuario/flutter_application_pasarela.git
   cd flutter_application_pasarela
   ```

2. **Instala las dependencias**
   ```bash
   flutter pub get
   ```

3. **Configura el backend (Opcional)**
   Si utilizas un proyecto de Supabase propio, reemplaza la URL y la *anon_key* en la inicialización de `main.dart`.

4. **Ejecuta la aplicación**
   ```bash
   flutter run
   ```

## 📬 Contacto

**Tech Lead / Desarrollador:** [Tu Nombre o Equipo]  
**Portafolio:** [Enlace a tu Portafolio / LinkedIn]  
**Email:** [tu-correo@ejemplo.com]

---
*Construido con pasión y Flutter.* 💙
