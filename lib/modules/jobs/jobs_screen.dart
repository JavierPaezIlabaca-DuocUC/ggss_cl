// ============================================================
// jobs_screen.dart
// Pantalla principal de ofertas laborales.
// Muestra la lista de ofertas desde Supabase con pull-to-refresh.
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
import 'create_job_screen.dart';
import 'jobs_providers.dart';
import 'widgets/job_card.dart';

/// Pantalla de ofertas laborales — admite vista completa o filtrada por usuario
class JobsScreen extends ConsumerWidget {
  /// Cuando es true, muestra solo las publicaciones del usuario autenticado
  final bool isOwnPosts;

  const JobsScreen({super.key, this.isOwnPosts = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Seleccionar el proveedor correcto según el modo
    final jobsAsync = isOwnPosts
        ? ref.watch(myJobsNotifierProvider)
        : ref.watch(jobsNotifierProvider);

    // ----------------------------------------------------------
    // Construir el contenido de la lista
    // ----------------------------------------------------------
    Widget content = jobsAsync.when(
      // Estado de carga: indicador centrado
      loading: () => const LoadingIndicator(),

      // Estado de error: mensaje con opción de reintento
      error: (error, _) => AppErrorWidget(
        message: AppStrings.errorGeneral,
        onRetry: () => isOwnPosts
            ? ref.read(myJobsNotifierProvider.notifier).refresh()
            : ref.read(jobsNotifierProvider.notifier).refresh(),
      ),

      // Datos cargados: lista o estado vacío
      data: (jobs) => RefreshIndicator(
        onRefresh: () => isOwnPosts
            ? ref.read(myJobsNotifierProvider.notifier).refresh()
            : ref.read(jobsNotifierProvider.notifier).refresh(),
        child: jobs.isEmpty
            ? _EmptyJobsList(isOwnPosts: isOwnPosts)
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: jobs.length,
                itemBuilder: (_, index) => JobCard(job: jobs[index]),
              ),
      ),
    );

    // ----------------------------------------------------------
    // Modo "mis publicaciones": envolver en Scaffold con AppBar
    // ----------------------------------------------------------
    if (isOwnPosts) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.myJobsTitle),
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

  const _EmptyJobsList({this.isOwnPosts = false});

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        EmptyStateWidget(
          message: isOwnPosts
              ? 'Aún no has publicado ofertas laborales.'
              : AppStrings.jobsNoOffers,
          icon: Icons.work_outline,
          actionLabel: isOwnPosts ? null : 'Crear primera publicación',
          onActionTap: isOwnPosts
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
