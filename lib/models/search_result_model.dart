// ============================================================
// search_result_model.dart
// Modelos de datos para el módulo de búsqueda unificada.
//
// Contiene:
//   - TimeFilter: enum de períodos de tiempo para filtrar
//   - SearchFilters: configuración de filtros activos
//   - SearchResults: contenedor de resultados agrupados por sección
// ============================================================

import '../models/academic_offer_model.dart';
import '../models/forum_post_model.dart';
import '../models/job_model.dart';
import '../models/news_item_model.dart';

// ============================================================
// Período de tiempo para filtrar contenido de Supabase
// ============================================================

/// Opciones de filtro por período de tiempo
enum TimeFilter {
  /// Sin restricción de fecha (mostrar todo)
  all,

  /// Solo resultados de hoy
  today,

  /// Resultados de los últimos 7 días
  week,

  /// Resultados de los últimos 30 días
  month,

  /// Resultados del último año
  year,

  /// Rango personalizado definido por el usuario
  custom,
}

// ============================================================
// Filtros de búsqueda avanzada
// ============================================================

/// Configuración de los filtros activos en la búsqueda avanzada
class SearchFilters {
  /// Incluir resultados de Ofertas Laborales
  final bool searchJobs;

  /// Incluir resultados de Ofertas Académicas
  final bool searchAcademic;

  /// Incluir resultados del Foro
  final bool searchForum;

  /// Incluir resultados de Noticias
  final bool searchNews;

  /// Período de tiempo aplicado al contenido de Supabase
  final TimeFilter timeFilter;

  /// Fecha de inicio del rango personalizado (solo para TimeFilter.custom)
  final DateTime? customDateFrom;

  /// Fecha de fin del rango personalizado (solo para TimeFilter.custom)
  final DateTime? customDateTo;

  /// Filtro de ubicación: nombre de región (ilike en columna location)
  final String? locationFilter;

  /// Comunas seleccionadas para filtro granular (opcional).
  /// Si está vacío y hay región, filtra solo por región.
  /// Si tiene valores, filtra por cualquiera de las comunas (OR).
  final List<String> locationCommunes;

  const SearchFilters({
    this.searchJobs = true,
    this.searchAcademic = true,
    this.searchForum = true,
    this.searchNews = true,
    this.timeFilter = TimeFilter.all,
    this.customDateFrom,
    this.customDateTo,
    this.locationFilter,
    this.locationCommunes = const [],
  });

  /// Filtros con todas las secciones habilitadas y sin restricción de fecha
  static const SearchFilters defaultFilters = SearchFilters();

  /// Retorna el rango de fechas según el filtro de tiempo activo.
  /// Null significa sin restricción de fecha.
  ({DateTime? from, DateTime? to}) get dateRange {
    final now = DateTime.now();
    switch (timeFilter) {
      case TimeFilter.all:
        return (from: null, to: null);
      case TimeFilter.today:
        return (
          from: DateTime(now.year, now.month, now.day),
          to: now,
        );
      case TimeFilter.week:
        return (from: now.subtract(const Duration(days: 7)), to: now);
      case TimeFilter.month:
        return (from: now.subtract(const Duration(days: 30)), to: now);
      case TimeFilter.year:
        return (from: now.subtract(const Duration(days: 365)), to: now);
      case TimeFilter.custom:
        return (from: customDateFrom, to: customDateTo);
    }
  }

  SearchFilters copyWith({
    bool? searchJobs,
    bool? searchAcademic,
    bool? searchForum,
    bool? searchNews,
    TimeFilter? timeFilter,
    DateTime? customDateFrom,
    DateTime? customDateTo,
    String? locationFilter,
    List<String>? locationCommunes,
    bool clearLocationFilter = false,
  }) {
    return SearchFilters(
      searchJobs: searchJobs ?? this.searchJobs,
      searchAcademic: searchAcademic ?? this.searchAcademic,
      searchForum: searchForum ?? this.searchForum,
      searchNews: searchNews ?? this.searchNews,
      timeFilter: timeFilter ?? this.timeFilter,
      customDateFrom: customDateFrom ?? this.customDateFrom,
      customDateTo: customDateTo ?? this.customDateTo,
      locationFilter:
          clearLocationFilter ? null : (locationFilter ?? this.locationFilter),
      locationCommunes: clearLocationFilter
          ? const []
          : (locationCommunes ?? this.locationCommunes),
    );
  }
}

// ============================================================
// Contenedor de resultados agrupados por sección
// ============================================================

/// Resultados de búsqueda agrupados por módulo
class SearchResults {
  final List<JobModel> jobs;
  final List<AcademicOfferModel> academic;
  final List<ForumPostModel> forum;
  final List<NewsItemModel> news;

  const SearchResults({
    this.jobs = const [],
    this.academic = const [],
    this.forum = const [],
    this.news = const [],
  });

  static const SearchResults empty = SearchResults();

  /// Retorna true si ninguna sección tiene resultados
  bool get isEmpty =>
      jobs.isEmpty && academic.isEmpty && forum.isEmpty && news.isEmpty;

  /// Total de resultados en todas las secciones
  int get totalCount =>
      jobs.length + academic.length + forum.length + news.length;
}
