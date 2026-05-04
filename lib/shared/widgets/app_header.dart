// ============================================================
// app_header.dart
// Header fijo de GGSS.cl con dos filas:
//   Fila 1: [Avatar usuario] [Barra de búsqueda] [Menú hamburguesa]
//   Fila 2: [Título de la sección actual — centrado]
//
// Este widget se usa como PreferredSizeWidget en el Scaffold
// para que permanezca fijo y no haga scroll.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_dimensions.dart';
import 'app_search_bar.dart';

/// Header fijo de dos filas de GGSS.cl
class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  /// Título de la sección actual (se muestra en la fila 2)
  final String sectionTitle;

  /// URL del avatar del usuario (null muestra ícono genérico)
  final String? userAvatarUrl;

  /// Callback al tocar el avatar del usuario (abre perfil)
  final VoidCallback onAvatarTap;

  /// Callback al tocar la barra de búsqueda (abre SearchScreen)
  final VoidCallback onSearchTap;

  /// Callback al tocar el menú hamburguesa (abre Settings)
  final VoidCallback onMenuTap;

  const AppHeader({
    super.key,
    required this.sectionTitle,
    this.userAvatarUrl,
    required this.onAvatarTap,
    required this.onSearchTap,
    required this.onMenuTap,
  });

  @override
  // Altura total del header: dos filas de altura fija
  Size get preferredSize =>
      const Size.fromHeight(AppDimensions.headerHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // Color de fondo desde el tema (cambia automáticamente en modo oscuro)
      color: theme.appBarTheme.backgroundColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --------------------------------------------------
            // Fila 1: Avatar | Barra de búsqueda | Menú
            // --------------------------------------------------
            SizedBox(
              height: AppDimensions.headerRowHeight,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingXs,
                ),
                child: Row(
                  children: [
                    // Avatar del usuario (abre perfil al tocar)
                    GestureDetector(
                      onTap: onAvatarTap,
                      child: _UserAvatar(avatarUrl: userAvatarUrl),
                    ),

                    const SizedBox(width: AppDimensions.spacingSm),

                    // Barra de búsqueda (ocupa el espacio restante)
                    Expanded(
                      child: AppSearchBar(onTap: onSearchTap),
                    ),

                    const SizedBox(width: AppDimensions.spacingSm),

                    // Menú hamburguesa (abre configuración)
                    IconButton(
                      icon: const Icon(Icons.menu),
                      onPressed: onMenuTap,
                      tooltip: 'Configuración',
                    ),
                  ],
                ),
              ),
            ),

            // --------------------------------------------------
            // Fila 2: Título de la sección actual (centrado)
            // --------------------------------------------------
            SizedBox(
              height: AppDimensions.headerRowHeight - 8,
              child: Center(
                child: Text(
                  sectionTitle,
                  style: theme.textTheme.titleLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),

            // Línea divisoria inferior del header
            const Divider(height: 1),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Widget interno: avatar circular del usuario
// ============================================================

class _UserAvatar extends StatelessWidget {
  final String? avatarUrl;

  const _UserAvatar({this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: AppDimensions.avatarSizeHeader / 2,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      backgroundColor: Theme.of(context).colorScheme.primary,
      // Muestra ícono genérico si no hay avatar
      child: avatarUrl == null
          ? const Icon(
              Icons.person,
              color: Colors.white,
              size: AppDimensions.iconSm + 4,
            )
          : null,
    );
  }
}
