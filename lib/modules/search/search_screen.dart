// ============================================================
// search_screen.dart
// Pantalla de búsqueda unificada de GGSS.cl.
//
// Al abrirse, el campo de texto recibe foco automáticamente.
// Con 3+ caracteres ejecuta una búsqueda con debounce de 500 ms
// en: job_offers, academic_offers, forum_posts y noticias locales.
// Los resultados se muestran agrupados por sección con encabezados.
// OS10 está excluido de la búsqueda.
// ============================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../models/search_result_model.dart';
import '../../shared/widgets/loading_indicator.dart';
import '../academic/widgets/academic_card.dart';
import '../forum/widgets/forum_post_card.dart';
import '../jobs/widgets/job_card.dart';
import '../news/widgets/news_card.dart';
import 'advanced_search_screen.dart';
import 'search_providers.dart';

/// Pantalla de búsqueda unificada (se muestra sobre el shell)
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  // ----------------------------------------------------------
  // Controladores y foco
  // ----------------------------------------------------------

  late final TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();

    // Auto-enfocar el campo al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Navegación a búsqueda avanzada
  // ----------------------------------------------------------

  Future<void> _openAdvancedSearch() async {
    // Cerrar teclado antes de navegar
    _focusNode.unfocus();

    final currentFilters = ref.read(searchNotifierProvider).filters;
    final newFilters = await Navigator.of(context).push<SearchFilters>(
      MaterialPageRoute(
        builder: (_) =>
            AdvancedSearchScreen(currentFilters: currentFilters),
      ),
    );

    // Aplicar los filtros recibidos si el usuario los confirmó
    if (newFilters != null && mounted) {
      await ref
          .read(searchNotifierProvider.notifier)
          .applyFilters(newFilters);
    }
  }

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(searchNotifierProvider);

    return Scaffold(
      // ----------------------------------------------------------
      // AppBar: campo de búsqueda + botón de filtros
      // ----------------------------------------------------------
      appBar: AppBar(
        titleSpacing: 0,
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: AppStrings.searchHint,
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            filled: false,
            // Icono de lupa
            prefixIcon: const Icon(Icons.search),
            // Botón para limpiar el campo
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _controller.clear();
                      ref
                          .read(searchNotifierProvider.notifier)
                          .onQueryChanged('');
                    },
                  )
                : null,
          ),
          onChanged: (value) {
            // Activar rebuild del suffixIcon
            setState(() {});
            ref.read(searchNotifierProvider.notifier).onQueryChanged(value);
          },
        ),
        // Botón de búsqueda avanzada
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            tooltip: AppStrings.searchAdvanced,
            onPressed: _openAdvancedSearch,
          ),
        ],
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // --------------------------------------------------
          // Enlace a búsqueda avanzada (textual, bajo el appbar)
          // --------------------------------------------------
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.filter_list, size: 16),
              label: const Text(AppStrings.searchAdvanced),
              style: TextButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: _openAdvancedSearch,
            ),
          ),

          const Divider(height: 1),

          // --------------------------------------------------
          // Área de resultados
          // --------------------------------------------------
          Expanded(child: _buildBody(state)),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // Construye el contenido del body según el estado
  // ----------------------------------------------------------

  Widget _buildBody(SearchState state) {
    // Estado idle: sin query suficiente
    if (state.isIdle) {
      return _IdleState();
    }

    // Cargando
    if (state.isLoading) {
      return const LoadingIndicator();
    }

    // Error
    if (state.errorMessage != null) {
      return _ErrorState(
        message: state.errorMessage!,
        onRetry: () => ref
            .read(searchNotifierProvider.notifier)
            .onQueryChanged(state.query),
      );
    }

    // Sin resultados
    if (state.noResults) {
      return _NoResultsState(query: state.query);
    }

    // Resultados encontrados
    if (state.hasResults) {
      return _ResultsList(results: state.results!);
    }

    // Estado por defecto (spinner mientras debounce espera)
    return const LoadingIndicator();
  }
}

// ============================================================
// Estado idle: invitar a escribir
// ============================================================

class _IdleState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search,
            size: 64,
            color: Theme.of(context)
                .colorScheme
                .primary
                .withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            AppStrings.searchMinChars,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.color
                      ?.withValues(alpha: 0.7),
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Sin resultados
// ============================================================

class _NoResultsState extends StatelessWidget {
  final String query;

  const _NoResultsState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Theme.of(context)
                  .colorScheme
                  .primary
                  .withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No se encontraron resultados para\n"$query"',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Estado de error con reintento
// ============================================================

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onRetry,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// Lista de resultados agrupados por sección
// ============================================================

class _ResultsList extends StatelessWidget {
  final SearchResults results;

  const _ResultsList({required this.results});

  @override
  Widget build(BuildContext context) {
    // Construir la lista plana con encabezados de sección intercalados
    final items = <Widget>[];

    // Ofertas laborales
    if (results.jobs.isNotEmpty) {
      items.add(_SectionHeader(label: AppStrings.titleJobs));
      for (final job in results.jobs) {
        items.add(JobCard(job: job));
      }
    }

    // Ofertas académicas
    if (results.academic.isNotEmpty) {
      items.add(_SectionHeader(label: AppStrings.titleAcademic));
      for (final offer in results.academic) {
        items.add(AcademicCard(offer: offer));
      }
    }

    // Foro
    if (results.forum.isNotEmpty) {
      items.add(_SectionHeader(label: AppStrings.titleForum));
      for (final post in results.forum) {
        items.add(ForumPostCard(post: post));
      }
    }

    // Noticias
    if (results.news.isNotEmpty) {
      items.add(_SectionHeader(label: AppStrings.titleNews));
      for (final news in results.news) {
        items.add(NewsCard(news: news));
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 24),
      itemCount: items.length,
      itemBuilder: (_, index) => items[index],
    );
  }
}

// ============================================================
// Encabezado de sección dentro de los resultados
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
      ),
    );
  }
}
