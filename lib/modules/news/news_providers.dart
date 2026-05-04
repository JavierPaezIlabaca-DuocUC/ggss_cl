// ============================================================
// news_providers.dart
// Proveedores Riverpod del módulo de noticias.
//
// Contiene:
//   - newsRepositoryProvider: proveedor del repositorio
//   - NewsNotifier: AsyncNotifier con fetch y refresh
//   - newsNotifierProvider: proveedor del notifier
// ============================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/news_repository.dart';
import '../../models/news_item_model.dart';

// ----------------------------------------------------------
// Proveedor del repositorio
// ----------------------------------------------------------

/// Proveedor del repositorio de noticias
final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository();
});

// ----------------------------------------------------------
// AsyncNotifier: gestiona la lista de noticias
// ----------------------------------------------------------

/// Notifier que mantiene y actualiza la lista de noticias
class NewsNotifier extends AsyncNotifier<List<NewsItemModel>> {
  // Carga inicial al montar el proveedor
  @override
  Future<List<NewsItemModel>> build() {
    return ref.read(newsRepositoryProvider).getNews();
  }

  // ----------------------------------------------------------
  // Recarga las noticias desde la API
  // ----------------------------------------------------------

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(
      () => ref.read(newsRepositoryProvider).getNews(),
    );
  }
}

/// Proveedor principal de la lista de noticias
final newsNotifierProvider =
    AsyncNotifierProvider<NewsNotifier, List<NewsItemModel>>(
  NewsNotifier.new,
);
