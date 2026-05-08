// ============================================================
// academic_screen.dart
// Pantalla principal de ofertas académicas.
// Muestra la lista desde Supabase con pull-to-refresh.
//
// Modos de uso:
//   - isOwnPosts = false (por defecto): embebida en MainShell,
//     muestra todas las ofertas. Sin Scaffold propio.
//   - isOwnPosts = true: ruta independiente empujada desde el
//     perfil del usuario. Muestra solo sus publicaciones.
//     Incluye Scaffold propio con AppBar.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'academic_providers.dart';
import 'create_academic_screen.dart';
import 'widgets/academic_card.dart';

/// Pantalla de ofertas académicas — admite vista completa o filtrada por usuario
class AcademicScreen extends ConsumerWidget {
  /// Cuando es true, muestra solo las publicaciones del usuario autenticado
  final bool isOwnPosts;

  const AcademicScreen({super.key, this.isOwnPosts = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Seleccionar el proveedor correcto según el modo
    final offersAsync = isOwnPosts
        ? ref.watch(myAcademicNotifierProvider)
        : ref.watch(academicNotifierProvider);

    // ----------------------------------------------------------
    // Construir el contenido de la lista
    // ----------------------------------------------------------
    Widget content = offersAsync.when(
      // Estado de carga
      loading: () => const LoadingIndicator(),

      // Estado de error con reintento
      error: (error, _) => AppErrorWidget(
        message: AppStrings.errorGeneral,
        onRetry: () => isOwnPosts
            ? ref.read(myAcademicNotifierProvider.notifier).refresh()
            : ref.read(academicNotifierProvider.notifier).refresh(),
      ),

      // Datos cargados: lista o estado vacío
      data: (offers) => RefreshIndicator(
        onRefresh: () => isOwnPosts
            ? ref.read(myAcademicNotifierProvider.notifier).refresh()
            : ref.read(academicNotifierProvider.notifier).refresh(),
        child: offers.isEmpty
            ? _EmptyAcademicList(isOwnPosts: isOwnPosts)
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: offers.length,
                itemBuilder: (_, index) =>
                    AcademicCard(offer: offers[index]),
              ),
      ),
    );

    // ----------------------------------------------------------
    // Modo "mis publicaciones": envolver en Scaffold con AppBar
    // ----------------------------------------------------------
    if (isOwnPosts) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.myAcademicTitle),
          centerTitle: true,
        ),
        body: content,
      );
    }

    // Modo normal: sin Scaffold (embebida en MainShell)
    return content;
  }
}

// ============================================================
// Estado vacío scrolleable (necesario para RefreshIndicator)
// ============================================================

class _EmptyAcademicList extends StatelessWidget {
  final bool isOwnPosts;

  const _EmptyAcademicList({this.isOwnPosts = false});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        EmptyStateWidget(
          message: isOwnPosts
              ? 'Aún no has publicado ofertas académicas.'
              : AppStrings.academicNoOffers,
          icon: Icons.school_outlined,
          actionLabel: isOwnPosts ? null : 'Crear primera publicación',
          onActionTap: isOwnPosts
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const CreateAcademicScreen()),
                  ),
        ),
      ],
    );
  }
}
