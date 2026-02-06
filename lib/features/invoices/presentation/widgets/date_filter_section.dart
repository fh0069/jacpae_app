import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Date filter section with "Desde" and "Hasta" date pickers
///
/// Constraints:
/// - Desde minimum: January 1st of the previous year
/// - Hasta maximum: Today
/// - Desde <= Hasta
class DateFilterSection extends StatelessWidget {
  final DateTime fromDate;
  final DateTime toDate;
  final ValueChanged<DateTime> onFromDateChanged;
  final ValueChanged<DateTime> onToDateChanged;
  final VoidCallback? onApplyFilter;

  const DateFilterSection({
    super.key,
    required this.fromDate,
    required this.toDate,
    required this.onFromDateChanged,
    required this.onToDateChanged,
    this.onApplyFilter,
  });

  /// Minimum allowed date: January 1st of previous year
  DateTime get _minDate {
    final now = DateTime.now();
    return DateTime(now.year - 1, 1, 1);
  }

  /// Maximum allowed date: Today
  DateTime get _maxDate => DateTime.now();

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: fromDate,
      firstDate: _minDate,
      lastDate: toDate, // Can't be after "hasta"
      helpText: 'Seleccionar fecha desde',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      locale: const Locale('es', 'ES'), // Español, semana empieza en lunes
    );

    if (picked != null && picked != fromDate) {
      onFromDateChanged(picked);
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: toDate,
      firstDate: fromDate, // Can't be before "desde"
      lastDate: _maxDate,
      helpText: 'Seleccionar fecha hasta',
      cancelText: 'Cancelar',
      confirmText: 'Aceptar',
      locale: const Locale('es', 'ES'), // Español, semana empieza en lunes
    );

    if (picked != null && picked != toDate) {
      onToDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppConstants.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spacingM),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filtrar por fecha',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: AppConstants.spacingM),
            Row(
              children: [
                // Desde
                Expanded(
                  child: _DatePickerField(
                    label: 'Desde',
                    value: _formatDate(fromDate),
                    onTap: () => _selectFromDate(context),
                  ),
                ),
                const SizedBox(width: AppConstants.spacingM),
                // Hasta
                Expanded(
                  child: _DatePickerField(
                    label: 'Hasta',
                    value: _formatDate(toDate),
                    onTap: () => _selectToDate(context),
                  ),
                ),
              ],
            ),
            if (onApplyFilter != null) ...[
              const SizedBox(height: AppConstants.spacingM),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onApplyFilter,
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Aplicar filtro'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusM),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spacingM,
          vertical: AppConstants.spacingS,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.textSecondary.withAlpha(100)),
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.calendar_today,
              size: 18,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
