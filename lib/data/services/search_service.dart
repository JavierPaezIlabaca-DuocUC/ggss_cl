// ============================================================
// search_service.dart
// Servicio de búsqueda unificada de GGSS.cl.
//
// Búsqueda en Supabase:
//   - job_offers:      title, company, location, description  (ilike)
//   - academic_offers: title, institution, description         (ilike)
//   - forum_posts:     title, content                          (ilike)
//
// Búsqueda local (datos estáticos):
//   - kStaticNews:     title, snippet  (contiene, insensible a mayúsculas)
//
// Las tres consultas a Supabase se lanzan en paralelo con Future.wait.
// ============================================================

import '../../data/sources/news_static_data.dart';
import '../../data/supabase/supabase_client.dart';
import '../../models/academic_offer_model.dart';
import '../../models/forum_post_model.dart';
import '../../models/job_model.dart';
import '../../models/news_item_model.dart';
import '../../models/search_result_model.dart';

/// Número máximo de resultados por sección
const int _kResultsPerSection = 20;

/// Servicio de búsqueda unificada
class SearchService {
  final _client = SupabaseClientProvider.client;

  // ----------------------------------------------------------
  // Búsqueda principal: lanza las 4 búsquedas en paralelo
  // ----------------------------------------------------------

  /// Busca [query] en todas las secciones habilitadas por [filters].
  /// Retorna los resultados agrupados en un [SearchResults].
  Future<SearchResults> search({
    required String query,
    required SearchFilters filters,
  }) async {
    final range = filters.dateRange;

    // Lanzar en paralelo solo las secciones habilitadas
    final futures = await Future.wait([
      filters.searchJobs
          ? searchJobs(
              query,
              dateFrom: range.from,
              dateTo: range.to,
              locationFilter: filters.locationFilter,
              locationCommunes: filters.locationCommunes,
            )
          : Future.value(<JobModel>[]),
      filters.searchAcademic
          ? searchAcademic(
              query,
              dateFrom: range.from,
              dateTo: range.to,
              locationFilter: filters.locationFilter,
              locationCommunes: filters.locationCommunes,
            )
          : Future.value(<AcademicOfferModel>[]),
      filters.searchForum
          ? searchForum(query, dateFrom: range.from, dateTo: range.to)
          : Future.value(<ForumPostModel>[]),
    ]);

    // Las noticias se filtran localmente (no son async)
    final newsResults =
        filters.searchNews ? searchNews(query, filters: filters) : <NewsItemModel>[];

    return SearchResults(
      jobs: futures[0] as List<JobModel>,
      academic: futures[1] as List<AcademicOfferModel>,
      forum: futures[2] as List<ForumPostModel>,
      news: newsResults,
    );
  }

  // ----------------------------------------------------------
  // Búsqueda en Ofertas Laborales
  // ----------------------------------------------------------

  /// Busca [query] en la tabla job_offers por título, empresa,
  /// ubicación y descripción. Admite filtro de fechas y ubicación opcionales.
  Future<List<JobModel>> searchJobs(
    String query, {
    DateTime? dateFrom,
    DateTime? dateTo,
    String? locationFilter,
    List<String> locationCommunes = const [],
  }) async {
    final q = '%$query%';

    // Filtro OR insensible a mayúsculas en múltiples columnas
    var builder = _client
        .from('job_offers')
        .select()
        .or('title.ilike.$q,company.ilike.$q,'
            'location.ilike.$q,description.ilike.$q');

    // Filtro de ubicación: por comunas específicas (OR) o por región
    if (locationCommunes.isNotEmpty) {
      final communeOr = locationCommunes
          .map((c) => 'location.ilike.%$c%')
          .join(',');
      builder = builder.or(communeOr);
    } else if (locationFilter != null && locationFilter.isNotEmpty) {
      builder = builder.ilike('location', '%$locationFilter%');
    }

    // Filtro de fecha: desde
    if (dateFrom != null) {
      builder = builder.gte('created_at', dateFrom.toIso8601String());
    }
    // Filtro de fecha: hasta
    if (dateTo != null) {
      builder = builder.lte('created_at', dateTo.toIso8601String());
    }

    final response = await builder
        .order('created_at', ascending: false)
        .limit(_kResultsPerSection);

    return List<Map<String, dynamic>>.from(response as List)
        .map(JobModel.fromMap)
        .toList();
  }

  // ----------------------------------------------------------
  // Búsqueda en Ofertas Académicas
  // ----------------------------------------------------------

  /// Busca [query] en la tabla academic_offers por título,
  /// institución y descripción. Admite filtro de fechas y ubicación opcionales.
  Future<List<AcademicOfferModel>> searchAcademic(
    String query, {
    DateTime? dateFrom,
    DateTime? dateTo,
    String? locationFilter,
    List<String> locationCommunes = const [],
  }) async {
    final q = '%$query%';

    var builder = _client
        .from('academic_offers')
        .select()
        .or('title.ilike.$q,institution.ilike.$q,description.ilike.$q');

    // Filtro de ubicación: por comunas específicas (OR) o por región
    if (locationCommunes.isNotEmpty) {
      final communeOr = locationCommunes
          .map((c) => 'location.ilike.%$c%')
          .join(',');
      builder = builder.or(communeOr);
    } else if (locationFilter != null && locationFilter.isNotEmpty) {
      builder = builder.ilike('location', '%$locationFilter%');
    }

    if (dateFrom != null) {
      builder = builder.gte('created_at', dateFrom.toIso8601String());
    }
    if (dateTo != null) {
      builder = builder.lte('created_at', dateTo.toIso8601String());
    }

    final response = await builder
        .order('created_at', ascending: false)
        .limit(_kResultsPerSection);

    return List<Map<String, dynamic>>.from(response as List)
        .map(AcademicOfferModel.fromMap)
        .toList();
  }

  // ----------------------------------------------------------
  // Búsqueda en el Foro
  // ----------------------------------------------------------

  /// Busca [query] en la tabla forum_posts por título y contenido.
  /// Admite filtro de fechas opcional.
  Future<List<ForumPostModel>> searchForum(
    String query, {
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final q = '%$query%';

    var builder = _client
        .from('forum_posts')
        .select()
        .or('title.ilike.$q,content.ilike.$q');

    if (dateFrom != null) {
      builder = builder.gte('created_at', dateFrom.toIso8601String());
    }
    if (dateTo != null) {
      builder = builder.lte('created_at', dateTo.toIso8601String());
    }

    final response = await builder
        .order('created_at', ascending: false)
        .limit(_kResultsPerSection);

    return List<Map<String, dynamic>>.from(response as List)
        .map(ForumPostModel.fromMap)
        .toList();
  }

  // ----------------------------------------------------------
  // Búsqueda en Noticias (datos estáticos locales)
  // ----------------------------------------------------------

  /// Filtra la lista estática de noticias por [query] en título y extracto.
  /// Si [filters] incluye un rango de fechas, también filtra por publishedDate.
  List<NewsItemModel> searchNews(
    String query, {
    SearchFilters? filters,
  }) {
    final lowerQuery = query.toLowerCase();
    final range = filters?.dateRange;

    return kStaticNews.where((news) {
      // Coincidencia de texto en título o extracto
      final matchesText =
          news.title.toLowerCase().contains(lowerQuery) ||
          news.snippet.toLowerCase().contains(lowerQuery);

      if (!matchesText) return false;

      // Filtro de fecha (si el período no es "todo el tiempo")
      if (range?.from != null && news.publishedDate != null) {
        if (news.publishedDate!.isBefore(range!.from!)) return false;
      }
      if (range?.to != null && news.publishedDate != null) {
        if (news.publishedDate!.isAfter(range!.to!)) return false;
      }

      return true;
    }).take(_kResultsPerSection).toList();
  }
}
