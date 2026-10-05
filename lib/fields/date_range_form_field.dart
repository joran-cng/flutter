import 'package:flutter/material.dart';

import '../theme/spacing.dart';
import '../validation/date_range_value.dart';

class DateRangeFormField extends FormField<DateRangeValue> {
  DateRangeFormField({
    super.key,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.autovalidateMode,
  }) : super(
          builder: (FormFieldState<DateRangeValue> state) {
            final value = state.value;
            final label = value == null
                ? 'Choisir les dates de début et de fin'
                : '${_formatDate(value.start)} → ${_formatDate(value.end)}';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Période'),
                  subtitle: Text(label),
                  trailing: const Icon(Icons.date_range),
                  onTap: () async {
                    final now = DateTime.now();
                    final start = await showDatePicker(
                      context: state.context,
                      initialDate: value?.start ?? now,
                      firstDate: DateTime(now.year - 1),
                      lastDate: DateTime(now.year + 5),
                      helpText: 'Date de début',
                    );
                    if (start == null) {
                      return;
                    }
                    if (!state.mounted) {
                      return;
                    }
                    final end = await showDatePicker(
                      context: state.context,
                      initialDate: value?.end ?? start.add(const Duration(days: 1)),
                      firstDate: start,
                      lastDate: DateTime(now.year + 5),
                      helpText: 'Date de fin',
                    );
                    if (end == null) {
                      return;
                    }
                    state.didChange(DateRangeValue(start: start, end: end));
                  },
                ),
                if (state.hasError)
                  Padding(
                    padding: const EdgeInsets.only(top: Spacing.xs),
                    child: Text(
                      state.errorText!,
                      style: TextStyle(
                        color: Theme.of(state.context).colorScheme.error,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            );
          },
        );

  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }
}
