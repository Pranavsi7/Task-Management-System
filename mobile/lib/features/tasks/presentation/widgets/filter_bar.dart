import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class FilterBar extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const FilterBar({super.key, required this.selected, required this.onChanged});

  static const _filters = [
    {'label': 'All', 'value': null},
    {'label': 'Pending', 'value': 'PENDING'},
    {'label': 'In Progress', 'value': 'IN_PROGRESS'},
    {'label': 'Completed', 'value': 'COMPLETED'},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final f = _filters[i];
          final isActive = selected == f['value'];
          return GestureDetector(
            onTap: () => onChanged(f['value']),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primary : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: isActive ? AppTheme.primary : AppTheme.border),
              ),
              child: Text(
                f['label'] as String,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive ? Colors.white : AppTheme.textSecondary,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
