// ============================================================
// privacy_screen.dart
// Pantalla de configuración de privacidad del perfil.
// Accesible desde ProfileScreen.
//
// Cuenta personal: 5 toggles de visibilidad.
// Cuenta empresa: mensaje informativo (sin toggles).
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/utils/post_name_preference.dart';
import '../academic/academic_providers.dart';
import '../forum/forum_providers.dart';
import '../jobs/jobs_providers.dart';
import 'profile_providers.dart';

/// Pantalla de privacidad del perfil del usuario autenticado
class PrivacyScreen extends ConsumerWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileNotifierProvider);
    final profile = profileAsync.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.privacyScreenTitle),
        centerTitle: true,
      ),
      body: profileAsync.when(
        loading: () => const Center(child: LinearProgressIndicator()),
        error: (e, _) => const Center(child: Text('Error al cargar perfil.')),
        data: (_) {
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (profile.isEmpresa) {
            return _EmpresaNote();
          }

          return _PersonalToggles(profile: profile);
        },
      ),
    );
  }
}

// ============================================================
// Cuenta empresa: mensaje informativo
// ============================================================

class _EmpresaNote extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.business_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  AppStrings.settingsPrivacyEmpresaNote,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// Cuenta personal: 5 toggles de privacidad
// ============================================================

class _PersonalToggles extends ConsumerWidget {
  final dynamic profile;

  const _PersonalToggles({required this.profile});

  Future<void> _update(
    BuildContext context,
    WidgetRef ref, {
    required bool showFullName,
    required bool showEmail,
    required bool showPhone,
    required bool showPosts,
    required bool showFullNameInPosts,
    bool invalidatePostProviders = false,
  }) async {
    // Capturar messenger ANTES del await para evitar pérdida de contexto
    // cuando profileNotifierProvider cambie a AsyncValue.loading() durante refresh
    final messenger = ScaffoldMessenger.of(context);

    await ref.read(profileNotifierProvider.notifier).updatePrivacySettings(
          showFullName: showFullName,
          showEmail: showEmail,
          showPhone: showPhone,
          showPosts: showPosts,
          showFullNameInPosts: showFullNameInPosts,
        );

    // Cuando cambia show_full_name_in_posts: persistir localmente y
    // marcar las listas como obsoletas para que refresquen en la próxima navegación
    if (invalidatePostProviders) {
      await PostNamePreference.write(showFullNameInPosts);
      ref.invalidate(jobsNotifierProvider);
      ref.invalidate(academicNotifierProvider);
      ref.invalidate(forumPostsNotifierProvider);
    }

    messenger.showSnackBar(
      const SnackBar(
        content: Text(AppStrings.settingsPrivacySaved),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8, top: 4),
          child: Text(
            'Elige qué información muestras en tu perfil público.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.7),
                ),
          ),
        ),

        Card(
          margin: EdgeInsets.zero,
          child: Column(
            children: [
              // Toggle: mostrar nombre completo
              SwitchListTile(
                value: profile.showFullName as bool,
                onChanged: (value) => _update(
                  context,
                  ref,
                  showFullName: value,
                  showEmail: profile.showEmail as bool,
                  showPhone: profile.showPhone as bool,
                  showPosts: profile.showPosts as bool,
                  showFullNameInPosts: profile.showFullNameInPosts as bool,
                ),
                title: const Text(AppStrings.settingsPrivacyShowFullName),
                subtitle: const Text(
                  'Por defecto solo se muestra tu primer nombre.',
                  style: TextStyle(fontSize: 12),
                ),
                secondary: const Icon(Icons.badge_outlined),
                dense: true,
              ),

              const Divider(height: 1, indent: 16, endIndent: 16),

              // Toggle: mostrar correo
              SwitchListTile(
                value: profile.showEmail as bool,
                onChanged: (value) => _update(
                  context,
                  ref,
                  showFullName: profile.showFullName as bool,
                  showEmail: value,
                  showPhone: profile.showPhone as bool,
                  showPosts: profile.showPosts as bool,
                  showFullNameInPosts: profile.showFullNameInPosts as bool,
                ),
                title: const Text(AppStrings.settingsPrivacyShowEmail),
                secondary: const Icon(Icons.email_outlined),
                dense: true,
              ),

              const Divider(height: 1, indent: 16, endIndent: 16),

              // Toggle: mostrar teléfono
              SwitchListTile(
                value: profile.showPhone as bool,
                onChanged: (value) => _update(
                  context,
                  ref,
                  showFullName: profile.showFullName as bool,
                  showEmail: profile.showEmail as bool,
                  showPhone: value,
                  showPosts: profile.showPosts as bool,
                  showFullNameInPosts: profile.showFullNameInPosts as bool,
                ),
                title: const Text(AppStrings.settingsPrivacyShowPhone),
                secondary: const Icon(Icons.phone_outlined),
                dense: true,
              ),

              const Divider(height: 1, indent: 16, endIndent: 16),

              // Toggle: mostrar publicaciones
              SwitchListTile(
                value: profile.showPosts as bool,
                onChanged: (value) => _update(
                  context,
                  ref,
                  showFullName: profile.showFullName as bool,
                  showEmail: profile.showEmail as bool,
                  showPhone: profile.showPhone as bool,
                  showPosts: value,
                  showFullNameInPosts: profile.showFullNameInPosts as bool,
                ),
                title: const Text(AppStrings.settingsPrivacyShowPosts),
                secondary: const Icon(Icons.article_outlined),
                dense: true,
              ),

              const Divider(height: 1, indent: 16, endIndent: 16),

              // Toggle: mostrar nombre completo en publicaciones
              SwitchListTile(
                value: profile.showFullNameInPosts as bool,
                onChanged: (value) => _update(
                  context,
                  ref,
                  showFullName: profile.showFullName as bool,
                  showEmail: profile.showEmail as bool,
                  showPhone: profile.showPhone as bool,
                  showPosts: profile.showPosts as bool,
                  showFullNameInPosts: value,
                  invalidatePostProviders: true,
                ),
                title: const Text(AppStrings.settingsPrivacyShowFullNameInPosts),
                subtitle: const Text(
                  'Por defecto solo se muestra tu primer nombre.',
                  style: TextStyle(fontSize: 12),
                ),
                secondary: const Icon(Icons.person_outlined),
                dense: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
