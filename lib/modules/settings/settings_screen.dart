// ============================================================
// settings_screen.dart
// Pantalla de configuración de GGSS.cl.
// Accesible desde el ícono de menú (≡) en el header.
//
// Secciones:
//   1. Apariencia — selector de tema (claro / oscuro)
//   2. Sección de inicio — dropdown con las 5 secciones
//   3. Legal — términos y condiciones
//   4. Acerca de — versión y descripción de la app
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import 'settings_providers.dart';
import 'terms_screen.dart';

/// Pantalla de configuración (se muestra sobre el shell principal)
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  // ----------------------------------------------------------
  // Nombres de las 5 secciones (índice 0–4, coincide con MainShell)
  // ----------------------------------------------------------
  static const List<String> _sectionNames = [
    AppStrings.titleJobs,
    AppStrings.titleAcademic,
    AppStrings.titleOs10,
    AppStrings.titleNews,
    AppStrings.titleForum,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final notifier = ref.read(settingsNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.titleSettings),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        children: [
          // --------------------------------------------------
          // Sección 1: Apariencia (selector de tema)
          // --------------------------------------------------
          _SectionHeader(label: AppStrings.settingsAppearance),

          const SizedBox(height: 10),

          // Fila con las dos tarjetas de tema: claro y oscuro
          Row(
            children: [
              Expanded(
                child: _ThemeCard(
                  label: AppStrings.settingsThemeLight,
                  icon: Icons.light_mode_outlined,
                  isSelected: settings.themeMode == ThemeMode.light,
                  onTap: () => notifier.setThemeMode(ThemeMode.light),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ThemeCard(
                  label: AppStrings.settingsThemeDark,
                  icon: Icons.dark_mode_outlined,
                  isSelected: settings.themeMode == ThemeMode.dark,
                  onTap: () => notifier.setThemeMode(ThemeMode.dark),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),

          // --------------------------------------------------
          // Sección 2: Sección de inicio (dropdown)
          // --------------------------------------------------
          _SectionHeader(label: AppStrings.settingsDefaultSection),

          const SizedBox(height: 10),

          // Dropdown: elige la sección que se muestra al abrir la app
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: Row(
                children: [
                  const Icon(Icons.home_outlined),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<int>(
                      value: settings.defaultSectionIndex,
                      isExpanded: true,
                      underline: const SizedBox.shrink(),
                      items: List.generate(
                        _sectionNames.length,
                        (index) => DropdownMenuItem<int>(
                          value: index,
                          child: Text(_sectionNames[index]),
                        ),
                      ),
                      onChanged: (value) {
                        if (value != null) notifier.setDefaultSection(value);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),

          // --------------------------------------------------
          // Sección 3: Legal
          // --------------------------------------------------
          _SectionHeader(label: 'Legal'),

          const SizedBox(height: 10),

          Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              leading: const Icon(Icons.gavel_outlined),
              title: const Text('Términos y condiciones'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 8),

          // --------------------------------------------------
          // Sección 5: Acerca de
          // --------------------------------------------------
          _SectionHeader(label: AppStrings.settingsAbout),

          const SizedBox(height: 10),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Ícono de escudo (identidad de la app)
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.security,
                      color: AppColors.primaryBlue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Versión y descripción
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.settingsVersion,
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          AppStrings.settingsDescription,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ============================================================
// Widget: encabezado de sección con estilo uniforme
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}

// ============================================================
// Widget: tarjeta seleccionable para el tema (claro / oscuro)
// ============================================================

class _ThemeCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeCard({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          // Fondo: ligeramente azul si está seleccionado
          color: isSelected
              ? primary.withValues(alpha: 0.08)
              : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
          // Borde azul prominente si está seleccionado, neutro si no
          border: Border.all(
            color: isSelected ? primary : AppColors.divider,
            width: isSelected ? 2.0 : 0.8,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono del tema
            Icon(
              icon,
              size: 32,
              color: isSelected ? primary : Theme.of(context).iconTheme.color,
            ),
            const SizedBox(height: 8),

            // Fila: etiqueta + checkmark si está seleccionado
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.normal,
                        color: isSelected ? primary : null,
                      ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.check_circle, size: 16, color: primary),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
