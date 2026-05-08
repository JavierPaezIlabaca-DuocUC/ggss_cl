// ============================================================
// main.dart
// Punto de entrada de GGSS.cl.
//
// Responsabilidades:
//   1. Inicializar SharedPreferences y Supabase antes de arrancar
//   2. Configurar Riverpod como gestor de estado global
//   3. Sobreescribir sharedPreferencesProvider con la instancia real
//   4. Aplicar el tema (claro/oscuro) leído desde SettingsNotifier
//      para que los cambios en Settings se reflejen al instante
//   5. Escuchar el estado de autenticación para enrutar al usuario:
//        - Sesión activa → MainShell (app principal)
//        - Sin sesión     → LoginScreen
//        - Verificando    → SplashScreen (pantalla de carga)
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/constants/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'modules/auth/auth_providers.dart';
import 'modules/auth/login_screen.dart';
import 'modules/settings/settings_providers.dart';
import 'modules/shell/main_shell.dart';

// ----------------------------------------------------------
// Punto de entrada: inicializar dependencias y arrancar la app
// ----------------------------------------------------------

Future<void> main() async {
  // Necesario antes de cualquier llamada asíncrona en main()
  WidgetsFlutterBinding.ensureInitialized();

  // Registrar mensajes en español para el paquete timeago
  timeago.setLocaleMessages('es', timeago.EsMessages());

  // Cargar preferencias locales ANTES de runApp para que el tema
  // esté disponible sincrónicamente desde el primer frame
  final prefs = await SharedPreferences.getInstance();

  // Inicializar Supabase con las credenciales del proyecto GGSS.cl.
  // authFlowType: PKCE activa el flujo seguro de código para deep links.
  // authCallbackUrlHostname: coincide con android:host del intent-filter
  // (ggss://app), permitiendo que el SDK confirme la sesión automáticamente
  // cuando el usuario toca el enlace de verificación de correo.
  await Supabase.initialize(
    url: SupabaseConfig.projectUrl,
    anonKey: SupabaseConfig.anonKey,
    authOptions: const FlutterAuthClientOptions(
      authFlowType: AuthFlowType.pkce,
      autoRefreshToken: true,
    ),
  );

  // Envolver con ProviderScope e inyectar la instancia de SharedPreferences
  // para que SettingsNotifier la use sincrónicamente al construirse
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const GgssApp(),
    ),
  );
}

// ----------------------------------------------------------
// Widget raíz: aplica tema y enruta según autenticación
// ----------------------------------------------------------

/// Widget raíz de GGSS.cl.
/// ConsumerWidget para leer el tema guardado desde SettingsNotifier.
class GgssApp extends ConsumerWidget {
  const GgssApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Leer el tema activo desde las preferencias del usuario
    final themeMode = ref.watch(
      settingsNotifierProvider.select((s) => s.themeMode),
    );

    // Escuchar el stream de cambios de autenticación de Supabase
    final authStateAsync = ref.watch(authStateChangesProvider);

    return MaterialApp(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,

      // Tema claro: fondo blanco, acentos azules
      theme: AppTheme.lightTheme,

      // Tema oscuro: fondo gris oscuro, acentos azules
      darkTheme: AppTheme.darkTheme,

      // Tema controlado por SettingsNotifier (no el sistema)
      // Cambia inmediatamente al tocar los botones en SettingsScreen
      themeMode: themeMode,

      // ----------------------------------------------------------
      // Pantalla inicial: determinada por el estado de autenticación
      // ----------------------------------------------------------
      home: authStateAsync.when(
        // Estado de carga: verificando si hay sesión activa
        loading: () => const _SplashScreen(),

        // Error del stream: redirigir a login por seguridad
        error: (err, st) => const LoginScreen(),

        // Estado conocido: decidir según la sesión activa
        data: (authState) {
          // Si hay sesión activa, mostrar el shell principal de la app
          if (authState.session != null) {
            return const MainShell();
          }
          // Si no hay sesión, mostrar la pantalla de inicio de sesión
          return const LoginScreen();
        },
      ),
    );
  }
}

// ----------------------------------------------------------
// Pantalla de splash / carga inicial
// ----------------------------------------------------------

/// Pantalla de carga que se muestra mientras Supabase verifica la sesión.
/// Se reemplaza automáticamente en cuanto se conoce el estado de auth.
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.primaryBlue,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Logo de la app
            Icon(
              Icons.security,
              color: Colors.white,
              size: 72,
            ),
            SizedBox(height: 24),
            // Nombre de la app
            Text(
              AppStrings.appName,
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 48),
            // Indicador de carga
            CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2.5,
            ),
          ],
        ),
      ),
    );
  }
}
