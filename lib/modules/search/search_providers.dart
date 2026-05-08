// ============================================================
// search_providers.dart
// Proveedores Riverpod del módulo de búsqueda unificada.
//
// Contiene:
//   - SearchState: estado inmutable de la búsqueda
//   - SearchNotifier: StateNotifier con debounce de 500 ms
//   - searchNotifierProvider: proveedor principal del módulo
// ============================================================

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/services/search_service.dart';
import '../../models/search_result_model.dart';

// ----------------------------------------------------------
// Estado inmutable de la búsqueda
// ----------------------------------------------------------

/// Estado completo de la pantalla de búsqueda
class SearchState {
  /// Texto actual en el campo de búsqueda
  final String query;

  /// true mientras se espera la respuesta de Supabase/datos locales
  final bool isLoading;

  /// Resultados agrupados (null = aún no se ha buscado)
  final SearchResults? results;

  /// Mensaje de error en español (null si no hay error)
  final String? errorMessage;

  /// Filtros activos de la búsqueda avanzada
  final SearchFilters filters;

  const SearchState({
    this.query = '',
    this.isLoading = false,
    this.results,
    this.errorMessage,
    this.filters = SearchFilters.defaultFilters,
  });

  /// True si el usuario todavía no ha ingresado suficientes caracteres
  bool get isIdle => query.trim().length < 3 && !isLoading;

  /// True si se buscó y hay al menos un resultado
  bool get hasResults => results != null && !results!.isEmpty;

  /// True si se buscó pero no hay resultados
  bool get noResults =>
      results != null && results!.isEmpty && !isLoading;

  SearchState copyWith({
    String? query,
    bool? isLoading,
    SearchResults? results,
    String? errorMessage,
    SearchFilters? filters,
    bool clearResults = false,
    bool clearError = false,
  }) {
    return SearchState(
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      results: clearResults ? null : (results ?? this.results),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      filters: filters ?? this.filters,
    );
  }
}

// ----------------------------------------------------------
// StateNotifier con debounce de 500 ms
// ----------------------------------------------------------

/// Notifier que gestiona el estado de búsqueda con un debounce
/// de 500 ms para evitar llamadas excesivas a Supabase.
class SearchNotifier extends StateNotifier<SearchState> {
  final SearchService _service;

  /// Timer del debounce: se cancela y reinicia en cada pulsación
  Timer? _debounce;

  SearchNotifier(this._service) : super(const SearchState());

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  // ----------------------------------------------------------
  // Cambio de texto en el campo de búsqueda
  // ----------------------------------------------------------

  /// Llamado en cada pulsación del teclado.
  /// Cancela el timer anterior y programa una nueva búsqueda en 500 ms.
  void onQueryChanged(String query) {
    _debounce?.cancel();

    // Con menos de 3 caracteres, limpiar resultados y no buscar
    if (query.trim().length < 3) {
      state = SearchState(query: query, filters: state.filters);
      return;
    }

    // Mostrar indicador de carga mientras el debounce espera
    state = state.copyWith(
      query: query,
      isLoading: true,
      clearResults: true,
      clearError: true,
    );

    // Programar la búsqueda real tras 500 ms de inactividad
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query.trim());
    });
  }

  // ----------------------------------------------------------
  // Aplicar filtros desde AdvancedSearchScreen
  // ----------------------------------------------------------

  /// Aplica los [filters] recibidos desde la pantalla de búsqueda avanzada
  /// y vuelve a buscar con el query actual si es suficientemente largo.
  Future<void> applyFilters(SearchFilters filters) async {
    state = state.copyWith(filters: filters);
    if (state.query.trim().length >= 3) {
      await _performSearch(state.query.trim());
    }
  }

  // ----------------------------------------------------------
  // Reiniciar estado (p. ej. al cerrar la pantalla de búsqueda)
  // ----------------------------------------------------------

  /// Vuelve al estado inicial: campo vacío, sin resultados ni filtros.
  void reset() {
    _debounce?.cancel();
    state = const SearchState();
  }

  // ----------------------------------------------------------
  // Búsqueda efectiva contra Supabase y datos estáticos
  // ----------------------------------------------------------

  Future<void> _performSearch(String query) async {
    // Guardar el query en curso para detectar búsquedas obsoletas
    final currentQuery = query;

    try {
      final results = await _service.search(
        query: query,
        filters: state.filters,
      );

      // Descartar el resultado si el query cambió mientras esperábamos
      if (!mounted || state.query.trim() != currentQuery) return;

      state = state.copyWith(
        isLoading: false,
        results: results,
        clearError: true,
      );
    } catch (e) {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Ocurrió un error al buscar. Intenta nuevamente.',
        clearResults: true,
      );
    }
  }
}

// ----------------------------------------------------------
// Proveedor principal
// ----------------------------------------------------------

/// Proveedor del notifier de búsqueda.
/// autoDispose limpia el estado cuando se cierra la pantalla.
final searchNotifierProvider =
    StateNotifierProvider.autoDispose<SearchNotifier, SearchState>((ref) {
  return SearchNotifier(SearchService());
});
