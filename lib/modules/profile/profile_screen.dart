// ============================================================
// profile_screen.dart
// Pantalla de perfil del usuario autenticado.
// Muestra: alias (nombre principal), nombre real debajo,
// correo, avatar con iniciales, estadísticas de publicaciones
// clickeables, y botones de acción.
// Se abre sobre el shell principal al tocar el avatar.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../models/profile_model.dart';
import '../../shared/widgets/error_widget.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../academic/academic_screen.dart';
import '../auth/auth_providers.dart';
import '../auth/login_screen.dart';
import '../forum/forum_screen.dart';
import '../jobs/jobs_screen.dart';
import 'edit_profile_screen.dart';
import 'privacy_screen.dart';
import 'profile_providers.dart';

/// Pantalla de perfil del usuario (se muestra sobre el shell)
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final statsAsync = ref.watch(profileStatsProvider);
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.titleProfile),
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
          onRetry: () =>
              ref.read(profileNotifierProvider.notifier).refresh(),
        ),

        // ----------------------------------------------------------
        // Datos cargados
        // ----------------------------------------------------------
        data: (profile) => SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // --------------------------------------------------
              // Avatar con iniciales del primer nombre o nombre completo
              // --------------------------------------------------
              _ProfileAvatar(
                displayName: profile?.firstName ?? profile?.fullName,
                avatarUrl: profile?.avatarUrl,
              ),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // Primer nombre (nombre de visualización, prominente)
              // --------------------------------------------------
              Text(
                profile?.firstName.isNotEmpty == true
                    ? profile!.firstName
                    : (profile?.fullName.isNotEmpty == true
                        ? profile!.fullName
                        : 'Usuario'),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                textAlign: TextAlign.center,
              ),

              // --------------------------------------------------
              // Nombre completo real (debajo en texto gris más pequeño)
              // --------------------------------------------------
              if (profile?.fullName.isNotEmpty == true) ...[
                const SizedBox(height: 4),
                Text(
                  profile!.fullName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.6),
                      ),
                  textAlign: TextAlign.center,
                ),
              ],

              const SizedBox(height: 4),

              // --------------------------------------------------
              // Correo electrónico (desde Supabase Auth)
              // --------------------------------------------------
              Text(
                currentUser?.email ?? '',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.color
                          ?.withValues(alpha: 0.75),
                    ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              // --------------------------------------------------
              // Teléfono (siempre visible en perfil propio)
              // --------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.color
                        ?.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatPhone(profile?.phone),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.color
                              ?.withValues(alpha: 0.75),
                        ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              const Divider(),

              const SizedBox(height: 16),

              // --------------------------------------------------
              // Estadísticas de publicaciones (clickeables)
              // --------------------------------------------------
              Text(
                AppStrings.profileStats,
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
                data: (stats) => _StatsRow(
                  stats: stats,
                  onTapJobs: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const JobsScreen(isOwnPosts: true),
                    ),
                  ),
                  onTapAcademic: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const AcademicScreen(isOwnPosts: true),
                    ),
                  ),
                  onTapForum: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) =>
                          const ForumScreen(isOwnPosts: true),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              const Divider(),

              const SizedBox(height: 20),

              // --------------------------------------------------
              // Botón: editar perfil
              // --------------------------------------------------
              if (profile != null)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text(AppStrings.profileEdit),
                    onPressed: () => _navigateToEdit(context, ref, profile),
                  ),
                ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // Botón: privacidad del perfil
              // --------------------------------------------------
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.lock_outline),
                  label: const Text(AppStrings.privacyProfileButton),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const PrivacyScreen(),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // Botón: cerrar sesión
              // --------------------------------------------------
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.logout),
                  label: const Text(AppStrings.profileLogout),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: () => _showLogoutDialog(context, ref),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // Navegación a pantalla de edición
  // ----------------------------------------------------------

  // ----------------------------------------------------------
  // Formatea +56912345678 → "+569 12 34 56 78"
  // ----------------------------------------------------------

  String _formatPhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'No registrado';
    if (!phone.startsWith('+569') || phone.length < 12) return phone;
    final digits = phone.substring(4); // 8 dígitos
    final spaced = digits.replaceAllMapped(
      RegExp(r'(.{2})'),
      (m) => '${m[1]} ',
    ).trim();
    return '+569 $spaced';
  }

  void _navigateToEdit(
    BuildContext context,
    WidgetRef ref,
    ProfileModel profile,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(profile: profile),
      ),
    );
  }

  // ----------------------------------------------------------
  // Diálogo de confirmación para cerrar sesión
  // ----------------------------------------------------------

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.profileLogoutConfirmTitle),
        content: const Text(AppStrings.profileLogoutConfirmBody),
        actions: [
          // Cancelar
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(AppStrings.actionCancel),
          ),
          // Confirmar cierre de sesión
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              // Cerrar el diálogo primero
              Navigator.of(ctx).pop();
              // Ejecutar cierre de sesión y esperar a que complete
              await ref.read(authNotifierProvider.notifier).signOut();
              // Limpiar caché de perfil para evitar que datos de esta
              // cuenta se muestren si otra cuenta inicia sesión después
              ref.invalidate(profileNotifierProvider);
              ref.invalidate(profileStatsProvider);
              // Limpiar toda la pila de navegación y redirigir al login
              if (context.mounted) {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
            child: const Text(AppStrings.profileLogout),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Widget: avatar circular con iniciales
// ============================================================

class _ProfileAvatar extends StatelessWidget {
  final String? displayName;
  final String? avatarUrl;

  const _ProfileAvatar({this.displayName, this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials(displayName);

    return CircleAvatar(
      radius: 48,
      backgroundColor: AppColors.primaryBlue,
      backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl!) : null,
      child: avatarUrl == null
          ? Text(
              initials,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  /// Genera las iniciales desde el nombre (máximo 2 letras).
  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}

// ============================================================
// Widget: fila de estadísticas con 3 contadores clickeables
// ============================================================

class _StatsRow extends StatelessWidget {
  final ProfileStats stats;
  final VoidCallback onTapJobs;
  final VoidCallback onTapAcademic;
  final VoidCallback onTapForum;

  const _StatsRow({
    required this.stats,
    required this.onTapJobs,
    required this.onTapAcademic,
    required this.onTapForum,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Ofertas laborales publicadas
        Expanded(
          child: _StatCard(
            count: stats.jobCount,
            label: AppStrings.profileJobsPosted,
            icon: Icons.work_outline,
            onTap: onTapJobs,
          ),
        ),
        const SizedBox(width: 8),
        // Ofertas académicas publicadas
        Expanded(
          child: _StatCard(
            count: stats.academicCount,
            label: AppStrings.profileAcademicPosted,
            icon: Icons.school_outlined,
            onTap: onTapAcademic,
          ),
        ),
        const SizedBox(width: 8),
        // Posts en el foro
        Expanded(
          child: _StatCard(
            count: stats.forumCount,
            label: AppStrings.profileForumPosts,
            icon: Icons.chat_bubble_outline,
            onTap: onTapForum,
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Widget: tarjeta individual de estadística (toca para ver lista)
// ============================================================

class _StatCard extends StatelessWidget {
  final int count;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _StatCard({
    required this.count,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
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
      ),
    );
  }
}
