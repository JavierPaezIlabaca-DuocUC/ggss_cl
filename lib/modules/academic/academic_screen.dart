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
import 'academic_providers.dart';
import 'create_academic_screen.dart';
import 'widgets/academic_card.dart';

/// Pantalla de ofertas académicas — admite vista completa, propia o de otro usuario
class AcademicScreen extends ConsumerStatefulWidget {
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
  ConsumerState<AcademicScreen> createState() => _AcademicScreenState();
}

class _AcademicScreenState extends ConsumerState<AcademicScreen> with RouteAware {
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
      ref.invalidate(userAcademicNotifierProvider(widget.userId!));
    } else if (widget.isOwnPosts) {
      ref.invalidate(myAcademicNotifierProvider);
    } else {
      ref.invalidate(academicNotifierProvider);
    }
  }

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Seleccionar el proveedor correcto según el modo
    final offersAsync = widget.userId != null
        ? ref.watch(userAcademicNotifierProvider(widget.userId!))
        : widget.isOwnPosts
            ? ref.watch(myAcademicNotifierProvider)
            : ref.watch(academicNotifierProvider);

    Widget content = offersAsync.when(
      loading: () => const LoadingIndicator(),

      error: (error, _) => AppErrorWidget(
        message: AppStrings.errorGeneral,
        onRetry: () {
          if (widget.userId != null) {
            ref.read(userAcademicNotifierProvider(widget.userId!).notifier).refresh();
          } else if (widget.isOwnPosts) {
            ref.read(myAcademicNotifierProvider.notifier).refresh();
          } else {
            ref.read(academicNotifierProvider.notifier).refresh();
          }
        },
      ),

      data: (offers) => RefreshIndicator(
        onRefresh: () async {
          if (widget.userId != null) {
            await ref
                .read(userAcademicNotifierProvider(widget.userId!).notifier)
                .refresh();
          } else if (widget.isOwnPosts) {
            await ref.read(myAcademicNotifierProvider.notifier).refresh();
          } else {
            await ref.read(academicNotifierProvider.notifier).refresh();
          }
        },
        child: offers.isEmpty
            ? _EmptyAcademicList(
                isOwnPosts: widget.isOwnPosts,
                isUserFilter: widget.userId != null,
              )
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: offers.length,
                itemBuilder: (_, index) => AcademicCard(offer: offers[index]),
              ),
      ),
    );

    // ----------------------------------------------------------
    // Modo con Scaffold: perfil propio o perfil de otro usuario
    // ----------------------------------------------------------
    if (widget.isOwnPosts || widget.userId != null) {
      final title = widget.userId != null
          ? 'Publicaciones de ${widget.userFirstName ?? 'usuario'}'
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
