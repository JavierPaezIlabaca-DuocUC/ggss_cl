// ============================================================
// public_profile_screen.dart
// Pantalla de perfil público de otro usuario.
// Recibe un [userId] y muestra su información pública aplicando
// las reglas de privacidad configuradas por el usuario.
//
// Siempre visible: alias, tipo de cuenta, fecha de ingreso.
// Condicional (cuenta personal): teléfono si show_phone=true,
//   estadísticas si show_posts=true.
// Cuenta empresa: siempre muestra toda la información pública.
//
// NO se muestra: email, RUT ni nombre completo real.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/profile_model.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_indicator.dart';
import 'profile_providers.dart';

/// Pantalla de perfil público de un usuario
class PublicProfileScreen extends ConsumerWidget {
  /// ID del usuario cuyo perfil se muestra
  final String userId;

  const PublicProfileScreen({super.key, required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(publicProfileProvider(userId));

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.publicProfileTitle),
        centerTitle: true,
      ),

      body: profileAsync.when(
        // ----------------------------------------------------------
        // Estado de carga
        // ----------------------------------------------------------
        loading: () => const LoadingIndicator(),

        // ----------------------------------------------------------
        // Estado de error con reintento
        // ----------------------------------------------------------
        error: (err, st) => AppErrorWidget(
          message: AppStrings.errorGeneral,
          onRetry: () => ref.invalidate(publicProfileProvider(userId)),
        ),

        // ----------------------------------------------------------
        // Datos cargados
        // ----------------------------------------------------------
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Perfil no encontrado.'));
          }
          return _PublicProfileBody(profile: profile, userId: userId);
        },
      ),
    );
  }
}

// ============================================================
// Cuerpo del perfil público
// ============================================================

class _PublicProfileBody extends ConsumerWidget {
  final ProfileModel profile;
  final String userId;

  const _PublicProfileBody({
    required this.profile,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(publicProfileStatsProvider(userId));

    // Las cuentas empresa siempre muestran toda la información
    final mostrarTelefono =
        profile.isEmpresa || (profile.showPhone && profile.phone != null);
    final mostrarPublicaciones = profile.isEmpresa || profile.showPosts;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --------------------------------------------------
          // Avatar con iniciales del alias
          // --------------------------------------------------
          _PublicAvatar(alias: profile.alias, fullName: profile.fullName),

          const SizedBox(height: 16),

          // --------------------------------------------------
          // Alias público (nombre principal en perfil público)
          // --------------------------------------------------
          Text(
            profile.alias?.isNotEmpty == true
                ? profile.alias!
                : AppStrings.publicProfileNoAlias,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // --------------------------------------------------
          // Badge de tipo de cuenta
          // --------------------------------------------------
          _AccountTypeBadge(accountType: profile.accountType),

          const SizedBox(height: 8),

          // --------------------------------------------------
          // Fecha de ingreso
          // --------------------------------------------------
          Text(
            '${AppStrings.publicProfileMemberSince} ${_formatearFecha(profile.createdAt)}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.7),
                ),
          ),

          // --------------------------------------------------
          // Teléfono (si privacidad lo permite)
          // --------------------------------------------------
          if (mostrarTelefono && profile.phone != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.phone_outlined,
                  size: 16,
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  profile.phone!,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],

          const SizedBox(height: 28),

          const Divider(),

          // --------------------------------------------------
          // Estadísticas de publicaciones (si privacidad lo permite)
          // --------------------------------------------------
          if (mostrarPublicaciones) ...[
            const SizedBox(height: 16),

            Text(
              AppStrings.publicProfileStats,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),

            const SizedBox(height: 12),

            statsAsync.when(
              loading: () => const SizedBox(
                height: 80,
                child: LoadingIndicator(),
              ),
              error: (err, st) => const SizedBox.shrink(),
              data: (stats) => _StatsRow(stats: stats),
            ),

            const SizedBox(height: 16),
          ] else ...[
            const SizedBox(height: 16),

            // Mensaje cuando las publicaciones están ocultas
            Text(
              'Este usuario ha ocultado sus publicaciones.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.6),
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  /// Formatea la fecha en español: "enero de 2024"
  String _formatearFecha(DateTime fecha) {
    const meses = [
      'enero', 'febrero', 'marzo', 'abril', 'mayo', 'junio',
      'julio', 'agosto', 'septiembre', 'octubre', 'noviembre', 'diciembre',
    ];
    return '${meses[fecha.month - 1]} de ${fecha.year}';
  }
}

// ============================================================
// Widget: avatar con iniciales del alias (o nombre si no hay alias)
// ============================================================

class _PublicAvatar extends StatelessWidget {
  final String? alias;
  final String fullName;

  const _PublicAvatar({required this.alias, required this.fullName});

  @override
  Widget build(BuildContext context) {
    final initials = _obtenerIniciales(alias ?? fullName);

    return CircleAvatar(
      radius: 44,
      backgroundColor: AppColors.primaryBlue,
      child: Text(
        initials,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  String _obtenerIniciales(String texto) {
    if (texto.trim().isEmpty) return '?';
    final partes = texto.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (partes.length == 1) return partes[0][0].toUpperCase();
    return (partes[0][0] + partes[1][0]).toUpperCase();
  }
}

// ============================================================
// Widget: badge de tipo de cuenta (Personal / Empresa)
// ============================================================

class _AccountTypeBadge extends StatelessWidget {
  final String accountType;

  const _AccountTypeBadge({required this.accountType});

  @override
  Widget build(BuildContext context) {
    final esEmpresa = accountType == 'empresa';
    final label = esEmpresa
        ? AppStrings.publicProfileAccountEmpresa
        : AppStrings.publicProfileAccountPersonal;
    final icono = esEmpresa ? Icons.business_outlined : Icons.person_outline;
    final color = esEmpresa
        ? AppColors.secondaryBlue
        : Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widget: fila de estadísticas (solo lectura, sin navegación)
// ============================================================

class _StatsRow extends StatelessWidget {
  final ProfileStats stats;

  const _StatsRow({required this.stats});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            count: stats.jobCount,
            label: AppStrings.profileJobsPosted,
            icon: Icons.work_outline,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            count: stats.academicCount,
            label: AppStrings.profileAcademicPosted,
            icon: Icons.school_outlined,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _StatCard(
            count: stats.forumCount,
            label: AppStrings.profileForumPosts,
            icon: Icons.chat_bubble_outline,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;

  const _StatCard({
    required this.count,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
            const SizedBox(height: 6),
            Text(
              '$count',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary,
                  ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: Theme.of(context).textTheme.labelSmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
