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

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/app_header.dart';

// Importación de las pantallas principales de cada sección
import '../jobs/jobs_screen.dart';
import '../academic/academic_screen.dart';
import '../os10/os10_screen.dart';
import '../news/news_screen.dart';
import '../forum/forum_screen.dart';

/// Shell principal de navegación de GGSS.cl
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  // ----------------------------------------------------------
  // Estado: índice de la sección activa (0 = Ofertas laborales)
  // ----------------------------------------------------------
  int _currentSectionIndex = 0;

  // ----------------------------------------------------------
  // Secciones de la app (en el orden de la barra de navegación)
  // ----------------------------------------------------------

  /// Títulos de cada sección (mostrados en la fila 2 del header)
  static const List<String> _sectionTitles = [
    AppStrings.titleJobs,
    AppStrings.titleAcademic,
    AppStrings.titleOs10,
    AppStrings.titleNews,
    AppStrings.titleForum,
  ];

  /// Pantallas correspondientes a cada sección
  static const List<Widget> _sectionScreens = [
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
  // Acción del FAB según la sección activa
  // ----------------------------------------------------------

  void _onFabPressed() {
    // TODO(módulos): navegar a la pantalla de creación correspondiente
    // Módulo 4 (Ofertas laborales): navegar a CreateJobScreen
    // Módulo 5 (Ofertas académicas): navegar a CreateAcademicScreen
    // Módulo 8 (Foro): navegar a CreatePostScreen
  }

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final bool showFab = _sectionsWithFab.contains(_currentSectionIndex);

    return Scaffold(
      // Header fijo de dos filas
      appBar: AppHeader(
        sectionTitle: _sectionTitles[_currentSectionIndex],
        onAvatarTap: _navigateToProfile,
        onSearchTap: _navigateToSearch,
        onMenuTap: _navigateToSettings,
      ),

      // Pantalla de la sección activa
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
          // 3. Simulador OS10 (central, destacado)
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

      // FAB: visible solo en Ofertas, Academia y Foro
      // Posicionado en la esquina inferior derecha
      floatingActionButton: showFab
          ? FloatingActionButton(
              onPressed: _onFabPressed,
              tooltip: 'Crear nuevo',
              child: const Icon(Icons.add),
            )
          : null,

      // Alineación del FAB para que quede sobre el último ícono
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  // ----------------------------------------------------------
  // Métodos de navegación (se implementan con GoRouter en Módulo 3)
  // ----------------------------------------------------------

  void _navigateToProfile() {
    // TODO(módulo 9): navegar a ProfileScreen con GoRouter
  }

  void _navigateToSearch() {
    // TODO(módulo 11): navegar a SearchScreen con GoRouter
  }

  void _navigateToSettings() {
    // TODO(módulo 10): navegar a SettingsScreen con GoRouter
  }
}
