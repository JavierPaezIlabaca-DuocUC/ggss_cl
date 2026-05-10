// ============================================================
// academic_screen.dart
// Pantalla principal de ofertas académicas.
// Muestra la lista desde Supabase con pull-to-refresh.
//
// Modos de uso:
//   - Por defecto: embebida en MainShell, muestra todas las ofertas.
//     Sin Scaffold propio.
//   - isOwnPosts = true: muestra solo las publicaciones del usuario
//     autenticado. Incluye Scaffold propio con AppBar.
//   - userId != null: muestra publicaciones de otro usuario específico.
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

/// Pantalla de ofertas académicas — admite vista completa, propia o de otro usuario
class AcademicScreen extends ConsumerWidget {
  /// Cuando es true, muestra solo las publicaciones del usuario autenticado
  final bool isOwnPosts;

  /// Cuando está presente, muestra publicaciones de este usuario específico
  final String? userId;

  /// Primer nombre del usuario (para el título del AppBar cuando userId != null)
  final String? userFirstName;

  const AcademicScreen({
    super.key,
    this.isOwnPosts = false,
    this.userId,
    this.userFirstName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Seleccionar el proveedor correcto según el modo
    final offersAsync = userId != null
        ? ref.watch(userAcademicNotifierProvider(userId!))
        : isOwnPosts
            ? ref.watch(myAcademicNotifierProvider)
            : ref.watch(academicNotifierProvider);

    // ----------------------------------------------------------
    // Construir el contenido de la lista
    // ----------------------------------------------------------
    Widget content = offersAsync.when(
      loading: () => const LoadingIndicator(),

      error: (error, _) => AppErrorWidget(
        message: AppStrings.errorGeneral,
        onRetry: () {
          if (userId != null) {
            ref.read(userAcademicNotifierProvider(userId!).notifier).refresh();
          } else if (isOwnPosts) {
            ref.read(myAcademicNotifierProvider.notifier).refresh();
          } else {
            ref.read(academicNotifierProvider.notifier).refresh();
          }
        },
      ),

      data: (offers) => RefreshIndicator(
        onRefresh: () async {
          if (userId != null) {
            await ref
                .read(userAcademicNotifierProvider(userId!).notifier)
                .refresh();
          } else if (isOwnPosts) {
            await ref.read(myAcademicNotifierProvider.notifier).refresh();
          } else {
            await ref.read(academicNotifierProvider.notifier).refresh();
          }
        },
        child: offers.isEmpty
            ? _EmptyAcademicList(
                isOwnPosts: isOwnPosts, isUserFilter: userId != null)
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
    // Modo con Scaffold: perfil propio o perfil de otro usuario
    // ----------------------------------------------------------
    if (isOwnPosts || userId != null) {
      final title = userId != null
          ? 'Publicaciones de ${userFirstName ?? 'usuario'}'
          : AppStrings.myAcademicTitle;

      return Scaffold(
        appBar: AppBar(
          title: Text(title),
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
  final bool isUserFilter;

  const _EmptyAcademicList({
    this.isOwnPosts = false,
    this.isUserFilter = false,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        EmptyStateWidget(
          message: isOwnPosts
              ? 'Aún no has publicado ofertas académicas.'
              : isUserFilter
                  ? 'Este usuario no tiene ofertas académicas.'
                  : AppStrings.academicNoOffers,
          icon: Icons.school_outlined,
          actionLabel: isOwnPosts || isUserFilter
              ? null
              : 'Crear primera publicación',
          onActionTap: isOwnPosts || isUserFilter
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
