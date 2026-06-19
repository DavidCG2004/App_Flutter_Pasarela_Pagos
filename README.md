# 🚀 Pasarela V2 

![Flutter](https://img.shields.io/badge/Flutter-3.11+-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-Ready-000000?style=for-the-badge&logo=apple&logoColor=white)
![Android](https://img.shields.io/badge/Android-Ready-3DDC84?style=for-the-badge&logo=android&logoColor=white)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=for-the-badge&logo=supabase&logoColor=white)

## 📖 Visión General y Propuesta de Valor

**Pasarela V2** es una solución móvil de comercio electrónico y pagos de última generación. Creada para maximizar las tasas de conversión, esta aplicación resuelve la fricción común en los procesos de *checkout* móviles, ofreciendo una experiencia de compra ultra-rápida, segura y visualmente inmersiva.

**¿Por qué Pasarela V2? (ROI y Ventaja Competitiva)**
- **Conversión Optimizada:** Flujos de usuario diseñados bajo principios de UX/UI minimalistas que reducen el abandono del carrito.
- **Escalabilidad Inmediata:** Arquitectura modular (*Clean Architecture*) que permite iterar nuevas funcionalidades o integrar nuevas pasarelas de pago sin afectar el núcleo del negocio.
- **Infraestructura Robusta:** Conectividad en tiempo real y alta disponibilidad gracias a su integración nativa con Supabase y consumo de APIs REST eficientes.

## ✨ Características Principales

- 🛍️ **Catálogo Dinámico:** Consumo de productos vía REST API con gestión de estado reactiva y eficiente.
- 🛒 **Carrito de Compras Inteligente:** Gestión de órdenes y control de estado en tiempo real.
- 💳 **Pasarela de Pagos Segura:** Integración con backend transaccional (`SupabasePaymentRepository`).
- 🎨 **Diseño Minimalista (UI/UX):** Tema personalizado enfocado en la claridad y el protagonismo del producto.
- ⚡ **Experiencia de Arranque Fluida:** Splash screen nativo y validación de estado inicial sin latencia perceptible.

## 🛠️ Tech Stack

El proyecto se sustenta en herramientas modernas del ecosistema Flutter:

- **Framework:** Flutter (Material 3 & Native Splash)
- **Lenguaje:** Dart
- **Arquitectura:** Clean Architecture (Domain, Data, Presentation, Core)
- **Gestión de Estado:** `provider` (`CartProvider`, `CatalogProvider`)
- **Backend & BaaS:** `supabase_flutter` (Base de datos y transacciones)
- **Red:** `http` para consumo de APIs REST externas
- **Hardware/Media:** `image_picker`

## ⚙️ Requisitos Previos

Asegúrate de tener instalado y configurado en tu entorno local:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Versión 3.11.4 o superior)
- [Dart SDK](https://dart.dev/get-dart)
- Android Studio / Xcode (para emuladores y compilación nativa)
- Un editor de código (VS Code, IntelliJ, etc.)

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

3. **Ejecuta la aplicación** (con un emulador abierto o dispositivo conectado)
   ```bash
   flutter run
   ```

*(Nota: Asegúrate de configurar correctamente las variables de entorno o el archivo de configuración de Supabase si cambias el proyecto base).*

## 🏗️ Estructura del Proyecto

El código fuente está organizado siguiendo los principios de **Clean Architecture**, promoviendo la separación de responsabilidades y la mantenibilidad:

```text
lib/
 ├── core/            # Configuración global, temas (AppTheme) y utilidades
 ├── data/            # Implementación de repositorios (SupabasePayment, ApiProduct)
 ├── domain/          # Lógica de negocio pura, entidades y contratos (Interfaces)
 ├── presentation/    # Interfaz de usuario
 │    ├── providers/  # Gestores de estado (CartProvider, CatalogProvider)
 │    ├── screens/    # Vistas de la aplicación (SplashScreen, etc.)
 │    └── widgets/    # Componentes UI reutilizables
 └── main.dart        # Punto de entrada de la aplicación e inyección de dependencias
```

## 📬 Contacto

**Tech Lead / Desarrollador:** [Tu Nombre o Equipo]  
**Portafolio:** [Enlace a tu Portafolio / LinkedIn]  
**Email:** [tu-correo@ejemplo.com]

---
*Construido con pasión y Flutter.* 💙
