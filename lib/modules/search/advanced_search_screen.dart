// ============================================================
// advanced_search_screen.dart
// Pantalla de búsqueda avanzada con filtros de sección y período.
//
// El usuario puede:
//   - Activar/desactivar secciones a buscar (Jobs, Academic, Forum, News)
//   - Seleccionar un período de tiempo (Hoy, Semana, Mes, Año, Personalizado)
//   - Elegir fechas personalizadas con date pickers
//
// Al confirmar, hace Navigator.pop(filters) con el SearchFilters resultante.
// SearchScreen espera este valor y aplica los filtros.
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../core/constants/chile_locations.dart';
import '../../models/search_result_model.dart';

/// Pantalla de búsqueda avanzada con filtros de sección y período
class AdvancedSearchScreen extends StatefulWidget {
  /// Filtros actualmente aplicados en SearchScreen
  final SearchFilters currentFilters;

  const AdvancedSearchScreen({super.key, required this.currentFilters});

  @override
  State<AdvancedSearchScreen> createState() => _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends State<AdvancedSearchScreen> {
  // ----------------------------------------------------------
  // Estado local del formulario de filtros
  // ----------------------------------------------------------

  late bool _searchJobs;
  late bool _searchAcademic;
  late bool _searchForum;
  late bool _searchNews;
  late TimeFilter _timeFilter;
  late DateTime? _customFrom;
  late DateTime? _customTo;

  // Filtro de ubicación: región seleccionada (opcional)
  String? _locationRegion;

  // ----------------------------------------------------------
  // Etiquetas de los períodos de tiempo
  // ----------------------------------------------------------

  static const Map<TimeFilter, String> _timeFilterLabels = {
    TimeFilter.all: AppStrings.searchFilterAllTime,
    TimeFilter.today: AppStrings.searchFilterToday,
    TimeFilter.week: AppStrings.searchFilterThisWeek,
    TimeFilter.month: AppStrings.searchFilterThisMonth,
    TimeFilter.year: AppStrings.searchFilterThisYear,
    TimeFilter.custom: AppStrings.searchFilterCustomRange,
  };

  // ----------------------------------------------------------
  // Inicialización con los filtros actuales
  // ----------------------------------------------------------

  @override
  void initState() {
    super.initState();
    final f = widget.currentFilters;
    _searchJobs = f.searchJobs;
    _searchAcademic = f.searchAcademic;
    _searchForum = f.searchForum;
    _searchNews = f.searchNews;
    _timeFilter = f.timeFilter;
    _customFrom = f.customDateFrom;
    _customTo = f.customDateTo;
    _locationRegion = f.locationFilter;
  }

  // ----------------------------------------------------------
  // Selección de fechas personalizadas
  // ----------------------------------------------------------

  Future<void> _pickDateFrom() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _customTo ?? DateTime.now(),
      helpText: AppStrings.searchFilterDateFrom,
    );
    if (picked != null) setState(() => _customFrom = picked);
  }

  Future<void> _pickDateTo() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _customTo ?? DateTime.now(),
      firstDate: _customFrom ?? DateTime(2020),
      lastDate: DateTime.now(),
      helpText: AppStrings.searchFilterDateTo,
    );
    if (picked != null) setState(() => _customTo = picked);
  }

  // ----------------------------------------------------------
  // Confirmar y retornar filtros
  // ----------------------------------------------------------

  void _applyFilters() {
    final filters = SearchFilters(
      searchJobs: _searchJobs,
      searchAcademic: _searchAcademic,
      searchForum: _searchForum,
      searchNews: _searchNews,
      timeFilter: _timeFilter,
      customDateFrom: _timeFilter == TimeFilter.custom ? _customFrom : null,
      customDateTo: _timeFilter == TimeFilter.custom ? _customTo : null,
      locationFilter:
          _locationRegion != null && _locationRegion!.isNotEmpty
              ? _locationRegion
              : null,
    );
    Navigator.of(context).pop(filters);
  }

  // ----------------------------------------------------------
  // Formato de fecha en español (ej: "12 abr. 2026")
  // ----------------------------------------------------------

  String _formatDate(DateTime date) {
    const meses = [
      'ene.', 'feb.', 'mar.', 'abr.', 'may.', 'jun.',
      'jul.', 'ago.', 'sep.', 'oct.', 'nov.', 'dic.',
    ];
    return '${date.day} ${meses[date.month - 1]} ${date.year}';
  }

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.searchAdvanced),
        centerTitle: true,
      ),

      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // --------------------------------------------------
          // Sección: secciones a buscar
          // --------------------------------------------------
          _SectionHeader(label: AppStrings.searchFilterSections),

          const SizedBox(height: 8),

          // Checkboxes de secciones
          _CheckboxTile(
            label: AppStrings.titleJobs,
            icon: Icons.work_outline,
            value: _searchJobs,
            onChanged: (v) => setState(() => _searchJobs = v!),
          ),
          _CheckboxTile(
            label: AppStrings.titleAcademic,
            icon: Icons.school_outlined,
            value: _searchAcademic,
            onChanged: (v) => setState(() => _searchAcademic = v!),
          ),
          _CheckboxTile(
            label: AppStrings.titleForum,
            icon: Icons.chat_bubble_outline,
            value: _searchForum,
            onChanged: (v) => setState(() => _searchForum = v!),
          ),
          _CheckboxTile(
            label: AppStrings.titleNews,
            icon: Icons.newspaper_outlined,
            value: _searchNews,
            onChanged: (v) => setState(() => _searchNews = v!),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),

          // --------------------------------------------------
          // Sección: filtro de ubicación (opcional)
          // --------------------------------------------------
          _SectionHeader(label: 'Filtrar por ubicación (opcional)'),

          const SizedBox(height: 8),

          // Dropdown de región (opcional, se puede limpiar)
          // Key basada en el valor para forzar recreación al limpiar
          DropdownButtonFormField<String>(
            key: ValueKey(_locationRegion ?? '__none__'),
            initialValue: _locationRegion,
            isExpanded: true,
            decoration: InputDecoration(
              hintText: 'Todas las regiones',
              prefixIcon: const Icon(Icons.map_outlined),
              suffixIcon: _locationRegion != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      tooltip: 'Limpiar región',
                      onPressed: () => setState(() => _locationRegion = null),
                    )
                  : null,
              isDense: true,
            ),
            items: [
              ...chileLocations.keys.map(
                (region) => DropdownMenuItem<String>(
                  value: region,
                  child: Text(
                    region,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
              ),
            ],
            onChanged: (region) => setState(() => _locationRegion = region),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 8),

          // --------------------------------------------------
          // Sección: filtro de período de tiempo
          // --------------------------------------------------
          _SectionHeader(label: AppStrings.searchFilterPeriod),

          const SizedBox(height: 8),

          // Opciones de período como chips seleccionables
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: TimeFilter.values.map((filter) {
              final isSelected = _timeFilter == filter;
              return ChoiceChip(
                label: Text(_timeFilterLabels[filter]!),
                selected: isSelected,
                onSelected: (_) => setState(() {
                  _timeFilter = filter;
                  // Limpiar fechas si se cambia de "personalizado"
                  if (filter != TimeFilter.custom) {
                    _customFrom = null;
                    _customTo = null;
                  }
                }),
              );
            }).toList(),
          ),

          // --------------------------------------------------
          // Date pickers para rango personalizado
          // --------------------------------------------------
          if (_timeFilter == TimeFilter.custom) ...[
            const SizedBox(height: 16),

            // Fecha desde
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(
                      _customFrom != null
                          ? '${AppStrings.searchFilterDateFrom}: ${_formatDate(_customFrom!)}'
                          : AppStrings.searchFilterDateFrom,
                    ),
                    onPressed: _pickDateFrom,
                  ),
                ),
                const SizedBox(width: 8),

                // Fecha hasta
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.calendar_today_outlined, size: 18),
                    label: Text(
                      _customTo != null
                          ? '${AppStrings.searchFilterDateTo}: ${_formatDate(_customTo!)}'
                          : AppStrings.searchFilterDateTo,
                    ),
                    onPressed: _pickDateTo,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 32),

          // --------------------------------------------------
          // Botón: aplicar filtros
          // --------------------------------------------------
          ElevatedButton(
            onPressed: _applyFilters,
            child: const Text(AppStrings.searchApplyFilters),
          ),

          const SizedBox(height: 8),

          // Restablecer filtros por defecto
          TextButton(
            onPressed: () {
              setState(() {
                _searchJobs = true;
                _searchAcademic = true;
                _searchForum = true;
                _searchNews = true;
                _timeFilter = TimeFilter.all;
                _customFrom = null;
                _customTo = null;
                _locationRegion = null;
              });
            },
            child: Text(
              'Restablecer filtros',
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// Encabezado de sección
// ============================================================

class _SectionHeader extends StatelessWidget {
  final String label;

  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
    );
  }
}

// ============================================================
// Fila de checkbox con ícono y etiqueta
// ============================================================

class _CheckboxTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool value;
  final ValueChanged<bool?> onChanged;

  const _CheckboxTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      secondary: Icon(icon),
      title: Text(label),
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      contentPadding: EdgeInsets.zero,
    );
  }
}
