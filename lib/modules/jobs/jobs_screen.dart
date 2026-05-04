// ============================================================
// jobs_screen.dart
// Pantalla principal de ofertas laborales.
// Muestra la lista de ofertas desde Supabase con pull-to-refresh.
// Embebida dentro de MainShell (sin Scaffold propio).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'jobs_providers.dart';
import 'widgets/job_card.dart';

/// Pantalla principal de ofertas laborales (embebida en MainShell)
class JobsScreen extends ConsumerWidget {
  const JobsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(jobsNotifierProvider);

    return jobsAsync.when(
      // ----------------------------------------------------------
      // Estado de carga: indicador centrado
      // ----------------------------------------------------------
      loading: () => const LoadingIndicator(),

      // ----------------------------------------------------------
      // Estado de error: mensaje con opción de reintento
      // ----------------------------------------------------------
      error: (error, _) => AppErrorWidget(
        message: AppStrings.errorGeneral,
        onRetry: () => ref.read(jobsNotifierProvider.notifier).refresh(),
      ),

      // ----------------------------------------------------------
      // Datos cargados: lista o estado vacío
      // ----------------------------------------------------------
      data: (jobs) => RefreshIndicator(
        onRefresh: () => ref.read(jobsNotifierProvider.notifier).refresh(),
        child: jobs.isEmpty
            ? _EmptyJobsList()
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: jobs.length,
                itemBuilder: (_, index) => JobCard(job: jobs[index]),
              ),
      ),
    );
  }
}

// ============================================================
// Widget interno: estado vacío scrolleable (necesario para
// que RefreshIndicator funcione sin contenido)
// ============================================================

class _EmptyJobsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const EmptyStateWidget(
          message: AppStrings.jobsNoOffers,
          icon: Icons.work_outline,
        ),
      ],
    );
  }
}
