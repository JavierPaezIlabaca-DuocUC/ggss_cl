// ============================================================
// main.dart
// Punto de entrada de GGSS.cl.
// Responsabilidades:
//   1. Inicializar Supabase antes de arrancar la app
//   2. Configurar Riverpod como gestor de estado global
//   3. Aplicar los temas claro y oscuro desde AppTheme
//   4. Mostrar el shell principal de navegación
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/constants/app_strings.dart';
import 'core/constants/supabase_config.dart';
import 'core/theme/app_theme.dart';
import 'modules/shell/main_shell.dart';

// ----------------------------------------------------------
// Punto de entrada: inicializa Supabase y arranca la app
// ----------------------------------------------------------

Future<void> main() async {
  // Necesario antes de cualquier operación asíncrona en main()
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase con las credenciales del proyecto GGSS.cl
  await Supabase.initialize(
    url: SupabaseConfig.projectUrl,
    anonKey: SupabaseConfig.anonKey,
  );

  // Envolver la app con ProviderScope para habilitar Riverpod
  runApp(
    const ProviderScope(
      child: GgssApp(),
    ),
  );
}

// ----------------------------------------------------------
// Widget raíz de la aplicación
// ----------------------------------------------------------

/// Widget raíz de GGSS.cl
class GgssApp extends StatelessWidget {
  const GgssApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Nombre de la app (se muestra en la barra de tareas del SO)
      title: AppStrings.appName,

      // Desactivar el banner de debug
      debugShowCheckedModeBanner: false,

      // Tema claro: fondo blanco, acentos azules
      theme: AppTheme.lightTheme,

      // Tema oscuro: fondo gris oscuro, acentos azules
      darkTheme: AppTheme.darkTheme,

      // Seguir el tema del sistema operativo por defecto
      // (se puede sobrescribir desde SettingsScreen en Módulo 10)
      themeMode: ThemeMode.system,

      // Pantalla inicial: shell con navegación inferior
      // TODO(módulo 2): reemplazar con router que verifica autenticación
      home: const MainShell(),
    );
  }
}
