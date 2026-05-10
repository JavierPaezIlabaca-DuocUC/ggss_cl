// ============================================================
// main_shell.dart
// Shell principal de la app: contiene el header fijo,
// la barra de navegación inferior y el FAB contextual.
// Cada sección se carga según el índice seleccionado.
//
// Este widget es el "esqueleto" visual de toda la app
// una vez que el usuario está autenticado.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/app_header.dart';
import '../auth/auth_providers.dart';
import '../settings/settings_providers.dart';

// Importación de las pantallas principales de cada sección
import '../jobs/jobs_screen.dart';
import '../academic/academic_screen.dart';
import '../os10/os10_screen.dart';
import '../news/news_screen.dart';
import '../forum/forum_screen.dart';

// Importación de las pantallas destino de navegación
import '../profile/profile_screen.dart';
import '../settings/settings_screen.dart';
import '../search/search_screen.dart';
import '../jobs/create_job_screen.dart';
import '../academic/create_academic_screen.dart';
import '../forum/create_post_screen.dart';

/// Shell principal de navegación de GGSS.cl.
/// ConsumerStatefulWidget para acceder al usuario autenticado vía Riverpod.
class MainShell extends ConsumerStatefulWidget {
  const MainShell({super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  // ----------------------------------------------------------
  // Estado: índice de la sección activa
  // Se inicializa con la sección de inicio guardada en Configuración.
  // ----------------------------------------------------------
  late int _currentSectionIndex;

  // ----------------------------------------------------------
  // Inicialización: leer sección de inicio desde Configuración
  // ----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    // Leer el índice de sección guardado en SharedPreferences a través
    // del SettingsNotifier. ref.read es seguro en initState.
    _currentSectionIndex =
        ref.read(settingsNotifierProvider).defaultSectionIndex;
  }

  // ----------------------------------------------------------
  // Configuración de secciones
  // ----------------------------------------------------------

  /// Títulos de cada sección (mostrados en la fila 2 del header)
  static const List<String> _sectionTitles = [
    AppStrings.titleJobs,
    AppStrings.titleAcademic,
    AppStrings.titleOs10,
    AppStrings.titleNews,
    AppStrings.titleForum,
  ];

  /// Pantallas correspondientes a cada sección.
  /// Se mantienen vivas con IndexedStack para preservar el scroll.
  /// No son const: ConsumerStatefulWidget necesita instancias mutables
  /// para que RouteAware pueda suscribirse correctamente.
  final List<Widget> _sectionScreens = const [
    JobsScreen(),
    AcademicScreen(),
    Os10Screen(),
    NewsScreen(),
    ForumScreen(),
  ];

  /// Índices de secciones donde el FAB debe ser visible
  static const Set<int> _sectionsWithFab = {
    0, // Ofertas laborales
    1, // Ofertas académicas
    4, // Foro
  };

  // ----------------------------------------------------------
  // Cambio de sección
  // ----------------------------------------------------------

  void _onSectionChanged(int index) {
    setState(() {
      _currentSectionIndex = index;
    });
  }

  // ----------------------------------------------------------
  // Acción del FAB: navega a la pantalla de creación de la sección activa
  // ----------------------------------------------------------

  void _onFabPressed() {
    Widget destination;

    switch (_currentSectionIndex) {
      case 0:
        destination = const CreateJobScreen();
      case 1:
        destination = const CreateAcademicScreen();
      case 4:
        destination = const CreatePostScreen();
      default:
        return; // Sección sin FAB: no hacer nada
    }

    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => destination),
    );
  }

  // ----------------------------------------------------------
  // Navegación a pantallas secundarias (pushed sobre el shell)
  // ----------------------------------------------------------

  void _navigateToProfile() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const ProfileScreen()),
    );
  }

  void _navigateToSearch() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  void _navigateToSettings() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SettingsScreen()),
    );
  }

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Obtener URL del avatar del usuario actual (null si no tiene foto)
    final currentUser = ref.watch(currentUserProvider);
    final avatarUrl = currentUser?.userMetadata?['avatar_url'] as String?;

    final bool showFab = _sectionsWithFab.contains(_currentSectionIndex);

    return Scaffold(
      // Header fijo de dos filas
      appBar: AppHeader(
        sectionTitle: _sectionTitles[_currentSectionIndex],
        userAvatarUrl: avatarUrl,
        onAvatarTap: _navigateToProfile,
        onSearchTap: _navigateToSearch,
        onMenuTap: _navigateToSettings,
      ),

      // Pantalla de la sección activa.
      // IndexedStack mantiene el estado de cada sección aunque no esté visible.
      body: IndexedStack(
        index: _currentSectionIndex,
        children: _sectionScreens,
      ),

      // Barra de navegación inferior con 5 íconos
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentSectionIndex,
        onTap: _onSectionChanged,
        items: const [
          // 1. Ofertas laborales
          BottomNavigationBarItem(
            icon: Icon(Icons.work_outline),
            activeIcon: Icon(Icons.work),
            label: AppStrings.navJobs,
          ),
          // 2. Ofertas académicas
          BottomNavigationBarItem(
            icon: Icon(Icons.school_outlined),
            activeIcon: Icon(Icons.school),
            label: AppStrings.navAcademic,
          ),
          // 3. Simulador OS10 (central)
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment),
            label: AppStrings.navOs10,
          ),
          // 4. Noticias
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_outlined),
            activeIcon: Icon(Icons.newspaper),
            label: AppStrings.navNews,
          ),
          // 5. Foro comunitario
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: AppStrings.navForum,
          ),
        ],
      ),

      // FAB: visible solo en Ofertas Laborales, Académicas y Foro.
      // Posicionado en la esquina inferior derecha, alineado con el ícono del Foro.
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: _onFabPressed,
              tooltip: 'Crear nuevo',
              child: const Icon(Icons.add),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
