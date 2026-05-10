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
//
// RouteAware: al regresar a esta pantalla, refetch los datos para
// reflejar cambios de privacidad (show_full_name_in_posts).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/route_observer.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'create_job_screen.dart';
import 'jobs_providers.dart';
import 'widgets/job_card.dart';

/// Pantalla de ofertas laborales — admite vista completa, propia o de otro usuario
class JobsScreen extends ConsumerStatefulWidget {
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
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> with RouteAware {
  // ----------------------------------------------------------
  // RouteAware: suscribir/desuscribir al observer global
  // ----------------------------------------------------------

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  /// Llamado cuando el usuario regresa a esta pantalla desde otra ruta.
  /// Invalida el proveedor para que refetch con las preferencias actualizadas.
  @override
  void didPopNext() {
    if (widget.userId != null) {
      ref.invalidate(userJobsNotifierProvider(widget.userId!));
    } else if (widget.isOwnPosts) {
      ref.invalidate(myJobsNotifierProvider);
    } else {
      ref.invalidate(jobsNotifierProvider);
    }
  }

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Seleccionar el proveedor correcto según el modo
    final jobsAsync = widget.userId != null
        ? ref.watch(userJobsNotifierProvider(widget.userId!))
        : widget.isOwnPosts
            ? ref.watch(myJobsNotifierProvider)
            : ref.watch(jobsNotifierProvider);

    Widget content = jobsAsync.when(
      loading: () => const LoadingIndicator(),

      error: (error, _) => AppErrorWidget(
        message: AppStrings.errorGeneral,
        onRetry: () {
          if (widget.userId != null) {
            ref.read(userJobsNotifierProvider(widget.userId!).notifier).refresh();
          } else if (widget.isOwnPosts) {
            ref.read(myJobsNotifierProvider.notifier).refresh();
          } else {
            ref.read(jobsNotifierProvider.notifier).refresh();
          }
        },
      ),

      data: (jobs) => RefreshIndicator(
        onRefresh: () async {
          if (widget.userId != null) {
            await ref
                .read(userJobsNotifierProvider(widget.userId!).notifier)
                .refresh();
          } else if (widget.isOwnPosts) {
            await ref.read(myJobsNotifierProvider.notifier).refresh();
          } else {
            await ref.read(jobsNotifierProvider.notifier).refresh();
          }
        },
        child: jobs.isEmpty
            ? _EmptyJobsList(
                isOwnPosts: widget.isOwnPosts,
                isUserFilter: widget.userId != null,
              )
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
    if (widget.isOwnPosts || widget.userId != null) {
      final title = widget.userId != null
          ? 'Publicaciones de ${widget.userFirstName ?? 'usuario'}'
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
