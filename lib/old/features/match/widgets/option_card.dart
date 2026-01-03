import 'package:flutter/material.dart';
import 'package:xyz/core/theme/app_colors.dart';

class OptionCard extends StatelessWidget {
  const OptionCard({
    super.key,
    required this.label,
    required this.selected,
    required this.onChanged,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => onChanged(!selected),
      child: Ink(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.accent.withValues(alpha: .6)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              _SoftCheckbox(
                value: selected,
                onChanged: (v) => onChanged(v ?? false),
              ),
              const SizedBox(width: 14),
              Expanded(child: Text(label, style: t.titleMedium)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftCheckbox extends StatelessWidget {
  const _SoftCheckbox({required this.value, this.onChanged});
  final bool value;
  final ValueChanged<bool?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 26,
      height: 26,
      child: Checkbox(
        value: value,
        onChanged: onChanged,
        side: const BorderSide(color: AppColors.accent, width: 2),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        checkColor: AppColors.surface,
        activeColor: AppColors.accent,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
