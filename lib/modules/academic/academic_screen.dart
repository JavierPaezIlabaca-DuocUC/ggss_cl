// ============================================================
// academic_screen.dart
// Pantalla principal de ofertas académicas.
// Muestra la lista desde Supabase con pull-to-refresh.
// Embebida dentro de MainShell (sin Scaffold propio).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/widgets/empty_state_widget.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'academic_providers.dart';
import 'widgets/academic_card.dart';

/// Pantalla principal de ofertas académicas (embebida en MainShell)
class AcademicScreen extends ConsumerWidget {
  const AcademicScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offersAsync = ref.watch(academicNotifierProvider);

    return offersAsync.when(
      // ----------------------------------------------------------
      // Estado de carga
      // ----------------------------------------------------------
      loading: () => const LoadingIndicator(),

      // ----------------------------------------------------------
      // Estado de error con reintento
      // ----------------------------------------------------------
      error: (error, _) => AppErrorWidget(
        message: AppStrings.errorGeneral,
        onRetry: () => ref.read(academicNotifierProvider.notifier).refresh(),
      ),

      // ----------------------------------------------------------
      // Datos cargados: lista o estado vacío
      // ----------------------------------------------------------
      data: (offers) => RefreshIndicator(
        onRefresh: () =>
            ref.read(academicNotifierProvider.notifier).refresh(),
        child: offers.isEmpty
            ? _EmptyAcademicList()
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: offers.length,
                itemBuilder: (_, index) =>
                    AcademicCard(offer: offers[index]),
              ),
      ),
    );
  }
}

// ============================================================
// Estado vacío scrolleable (necesario para RefreshIndicator)
// ============================================================

class _EmptyAcademicList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const EmptyStateWidget(
          message: AppStrings.academicNoOffers,
          icon: Icons.school_outlined,
        ),
      ],
    );
  }
}
