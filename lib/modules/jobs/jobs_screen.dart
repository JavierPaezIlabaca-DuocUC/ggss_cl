// ============================================================
// jobs_screen.dart
// Pantalla principal de ofertas laborales.
// Muestra la lista de ofertas desde Supabase con pull-to-refresh.
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
import 'create_job_screen.dart';
import 'jobs_providers.dart';
import 'widgets/job_card.dart';

/// Pantalla de ofertas laborales — admite vista completa, propia o de otro usuario
class JobsScreen extends ConsumerWidget {
  /// Cuando es true, muestra solo las publicaciones del usuario autenticado
  final bool isOwnPosts;

  /// Cuando está presente, muestra publicaciones de este usuario específico
  final String? userId;

  /// Primer nombre del usuario (para el título del AppBar cuando userId != null)
  final String? userFirstName;

  const JobsScreen({
    super.key,
    this.isOwnPosts = false,
    this.userId,
    this.userFirstName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Seleccionar el proveedor correcto según el modo
    final jobsAsync = userId != null
        ? ref.watch(userJobsNotifierProvider(userId!))
        : isOwnPosts
            ? ref.watch(myJobsNotifierProvider)
            : ref.watch(jobsNotifierProvider);

    // ----------------------------------------------------------
    // Construir el contenido de la lista
    // ----------------------------------------------------------
    Widget content = jobsAsync.when(
      loading: () => const LoadingIndicator(),

      error: (error, _) => AppErrorWidget(
        message: AppStrings.errorGeneral,
        onRetry: () {
          if (userId != null) {
            ref.read(userJobsNotifierProvider(userId!).notifier).refresh();
          } else if (isOwnPosts) {
            ref.read(myJobsNotifierProvider.notifier).refresh();
          } else {
            ref.read(jobsNotifierProvider.notifier).refresh();
          }
        },
      ),

      data: (jobs) => RefreshIndicator(
        onRefresh: () async {
          if (userId != null) {
            await ref
                .read(userJobsNotifierProvider(userId!).notifier)
                .refresh();
          } else if (isOwnPosts) {
            await ref.read(myJobsNotifierProvider.notifier).refresh();
          } else {
            await ref.read(jobsNotifierProvider.notifier).refresh();
          }
        },
        child: jobs.isEmpty
            ? _EmptyJobsList(isOwnPosts: isOwnPosts, isUserFilter: userId != null)
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: jobs.length,
                itemBuilder: (_, index) => JobCard(job: jobs[index]),
              ),
      ),
    );

    // ----------------------------------------------------------
    // Modo con Scaffold: perfil propio o perfil de otro usuario
    // ----------------------------------------------------------
    if (isOwnPosts || userId != null) {
      final title = userId != null
          ? 'Publicaciones de ${userFirstName ?? 'usuario'}'
          : AppStrings.myJobsTitle;

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

class _EmptyJobsList extends StatelessWidget {
  final bool isOwnPosts;
  final bool isUserFilter;

  const _EmptyJobsList({
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
              ? 'Aún no has publicado ofertas laborales.'
              : isUserFilter
                  ? 'Este usuario no tiene ofertas laborales.'
                  : AppStrings.jobsNoOffers,
          icon: Icons.work_outline,
          actionLabel: isOwnPosts || isUserFilter
              ? null
              : 'Crear primera publicación',
          onActionTap: isOwnPosts || isUserFilter
              ? null
              : () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const CreateJobScreen()),
                  ),
        ),
      ],
    );
  }
}
