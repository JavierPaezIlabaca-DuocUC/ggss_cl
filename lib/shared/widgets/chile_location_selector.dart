// ============================================================
// chile_location_selector.dart
// Selector de región y comuna(s) de Chile para formularios.
//
// Paso 1 — Dropdown de región (obligatorio, 16 regiones).
// Paso 2 — Multi-selección de comunas (obligatorio, al menos una).
//          Las comunas aparecen como chips debajo del selector.
//
// Integrado con Form mediante FormField para que la validación
// nativa de Flutter funcione al llamar _formKey.validate().
// ============================================================

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/chile_locations.dart';

/// Selector de región y comunas de Chile.
///
/// Se integra con un [Form] padre: tanto el dropdown de región
/// como el selector de comunas participan en la validación.
///
/// Cuando el usuario completa la selección, el callback
/// [onLocationChanged] entrega la región y las comunas elegidas.
class ChileLocationSelector extends StatefulWidget {
  /// Región inicialmente seleccionada (puede ser null)
  final String? initialRegion;

  /// Comunas inicialmente seleccionadas
  final List<String> initialCommunes;

  /// Callback invocado al cambiar región o comunas.
  /// [region] es null solo si el usuario limpió la región.
  final void Function(String? region, List<String> communes)
      onLocationChanged;

  const ChileLocationSelector({
    super.key,
    this.initialRegion,
    this.initialCommunes = const [],
    required this.onLocationChanged,
  });

  @override
  State<ChileLocationSelector> createState() => _ChileLocationSelectorState();
}

class _ChileLocationSelectorState extends State<ChileLocationSelector> {
  // Región seleccionada actualmente
  String? _selectedRegion;

  // Clave para acceder al FormField de comunas y llamar didChange()
  final _communesFieldKey = GlobalKey<FormFieldState<List<String>>>();

  @override
  void initState() {
    super.initState();
    _selectedRegion = widget.initialRegion;
  }

  // ----------------------------------------------------------
  // Cambia la región y resetea las comunas
  // ----------------------------------------------------------
  void _onRegionChanged(String? region) {
    setState(() => _selectedRegion = region);
    // Reiniciar comunas al cambiar de región
    _communesFieldKey.currentState?.didChange([]);
    widget.onLocationChanged(region, []);
  }

  // ----------------------------------------------------------
  // Abre el diálogo de selección múltiple de comunas
  // ----------------------------------------------------------
  Future<void> _openCommuneDialog(
    BuildContext context,
    FormFieldState<List<String>> state,
  ) async {
    if (_selectedRegion == null) return;
    final communes = chileLocations[_selectedRegion] ?? [];
    final current = List<String>.from(state.value ?? []);

    final result = await showDialog<List<String>>(
      context: context,
      builder: (_) => _CommunePickerDialog(
        region: _selectedRegion!,
        allCommunes: communes,
        initialSelected: current,
      ),
    );

    if (result != null) {
      state.didChange(result);
      widget.onLocationChanged(_selectedRegion, result);
    }
  }

  // ----------------------------------------------------------
  // Construcción del widget
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --------------------------------------------------
        // Paso 1: Dropdown de región
        // --------------------------------------------------
        DropdownButtonFormField<String>(
          key: ValueKey(_selectedRegion),
          initialValue: _selectedRegion,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Región *',
            prefixIcon: Icon(Icons.map_outlined),
          ),
          items: chileLocations.keys.map((region) {
            return DropdownMenuItem<String>(
              value: region,
              child: Text(
                region,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'La región es obligatoria';
            }
            return null;
          },
          onChanged: _onRegionChanged,
        ),

        // --------------------------------------------------
        // Paso 2: Selector de comunas (solo si hay región)
        // --------------------------------------------------
        if (_selectedRegion != null) ...[
          const SizedBox(height: AppDimensions.spacingMd),

          FormField<List<String>>(
            key: _communesFieldKey,
            initialValue: widget.initialRegion == _selectedRegion
                ? List.from(widget.initialCommunes)
                : [],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Selecciona al menos una comuna';
              }
              return null;
            },
            builder: (state) {
              final selectedCommunes = state.value ?? [];

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Campo tappable que abre el diálogo de selección
                  InkWell(
                    onTap: () => _openCommuneDialog(context, state),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                    child: InputDecorator(
                      decoration: InputDecoration(
                        labelText: 'Comunas *',
                        prefixIcon:
                            const Icon(Icons.location_city_outlined),
                        suffixIcon:
                            const Icon(Icons.arrow_drop_down),
                        errorText:
                            state.hasError ? state.errorText : null,
                      ),
                      child: Text(
                        selectedCommunes.isEmpty
                            ? 'Seleccionar comunas...'
                            : '${selectedCommunes.length} '
                                '${selectedCommunes.length == 1 ? 'comuna seleccionada' : 'comunas seleccionadas'}',
                        style: selectedCommunes.isEmpty
                            ? TextStyle(
                                color: Theme.of(context).hintColor,
                              )
                            : null,
                      ),
                    ),
                  ),

                  // Chips de comunas seleccionadas
                  if (selectedCommunes.isNotEmpty) ...[
                    const SizedBox(height: AppDimensions.spacingSm),
                    Wrap(
                      spacing: AppDimensions.spacingSm,
                      runSpacing: AppDimensions.spacingXs,
                      children: selectedCommunes.map((commune) {
                        return Chip(
                          label: Text(commune),
                          labelStyle:
                              Theme.of(context).textTheme.labelSmall,
                          backgroundColor: AppColors.primaryBlue
                              .withValues(alpha: 0.1),
                          side: BorderSide(
                            color: AppColors.primaryBlue
                                .withValues(alpha: 0.3),
                          ),
                          deleteIcon: const Icon(
                            Icons.close,
                            size: AppDimensions.iconSm,
                          ),
                          onDeleted: () {
                            final updated =
                                List<String>.from(selectedCommunes)
                                  ..remove(commune);
                            state.didChange(updated);
                            widget.onLocationChanged(
                              _selectedRegion,
                              updated,
                            );
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}

// ============================================================
// Diálogo de selección múltiple de comunas
// ============================================================

/// Diálogo con lista de comunas de una región para selección múltiple.
/// Incluye barra de búsqueda para filtrar comunas.
class _CommunePickerDialog extends StatefulWidget {
  final String region;
  final List<String> allCommunes;
  final List<String> initialSelected;

  const _CommunePickerDialog({
    required this.region,
    required this.allCommunes,
    required this.initialSelected,
  });

  @override
  State<_CommunePickerDialog> createState() =>
      _CommunePickerDialogState();
}

class _CommunePickerDialogState extends State<_CommunePickerDialog> {
  late Set<String> _selected;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selected = Set.from(widget.initialSelected);
  }

  // ----------------------------------------------------------
  // Construcción del diálogo
  // ----------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    // Filtrar comunas según la búsqueda
    final filtered = widget.allCommunes
        .where(
          (c) =>
              c.toLowerCase().contains(_searchQuery.toLowerCase()),
        )
        .toList();

    return AlertDialog(
      title: Text(
        'Seleccionar comunas',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Subtítulo con nombre de región
            Text(
              widget.region,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                  ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppDimensions.spacingSm),

            // Buscador de comunas
            TextField(
              decoration: const InputDecoration(
                hintText: 'Buscar comuna...',
                prefixIcon: Icon(Icons.search, size: AppDimensions.iconMd),
                isDense: true,
              ),
              onChanged: (value) =>
                  setState(() => _searchQuery = value),
            ),

            const SizedBox(height: AppDimensions.spacingXs),

            // Lista de comunas con checkboxes
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtered.length,
                itemBuilder: (_, index) {
                  final commune = filtered[index];
                  final isChecked = _selected.contains(commune);
                  return CheckboxListTile(
                    value: isChecked,
                    title: Text(
                      commune,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    dense: true,
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                    onChanged: (checked) {
                      setState(() {
                        if (checked == true) {
                          _selected.add(commune);
                        } else {
                          _selected.remove(commune);
                        }
                      });
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.of(context).pop(_selected.toList()),
          child: Text(
            _selected.isEmpty
                ? 'Confirmar'
                : 'Confirmar (${_selected.length})',
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Función utilitaria: construir string de ubicación
// ============================================================

/// Construye el texto de ubicación para guardar en la base de datos.
/// Formato: "Región Metropolitana de Santiago — Santiago, Providencia"
String buildLocationString(String? region, List<String> communes) {
  if (region == null || region.isEmpty) return '';
  if (communes.isEmpty) return region;
  final communeList = communes.join(', ');
  return '$region — $communeList';
}
