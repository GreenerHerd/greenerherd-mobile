import 'package:flutter/material.dart';

import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import 'animal_avatar.dart';
import 'gh_status_tag.dart';

class AnimalListTile extends StatelessWidget {
  const AnimalListTile({
    super.key,
    required this.animal,
    this.onTap,
    this.onPregnantTagTap,
    this.onLactatingTagTap,
  });

  final Animal animal;
  final VoidCallback? onTap;
  final VoidCallback? onPregnantTagTap;
  final VoidCallback? onLactatingTagTap;

  @override
  Widget build(BuildContext context) {
    final nameLine = animal.name.trim().isNotEmpty && animal.name != '—'
        ? '${animal.name} · #${animal.tag}'
        : '#${animal.tag}';

    return Material(
      color: GhColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: GhColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimalAvatar(animal: animal, size: 48),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nameLine,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: GhColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${animal.breed} · ${animal.weightKg.toInt()} kg · ${animal.ageLabel}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: GhColors.textSecondary,
                      ),
                    ),
                    if (animal.tags.isNotEmpty || animal.hasIncompleteData) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          ...animal.tags.take(3).map((t) {
                            return GhStatusTag(
                              tag: t,
                              onTap: t == AnimalTagType.pregnant
                                  ? onPregnantTagTap
                                  : t == AnimalTagType.lactating
                                      ? onLactatingTagTap
                                      : null,
                            );
                          }),
                          if (animal.hasIncompleteData)
                            _IncompleteDataBadge(
                              missing: animal.missingFields,
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (animal.milkTodayLitres != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${animal.milkTodayLitres!.toStringAsFixed(1)} L',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: GhColors.primary,
                      ),
                    ),
                    const Text(
                      'today',
                      style: TextStyle(
                        fontSize: 11,
                        color: GhColors.textSecondary,
                      ),
                    ),
                  ],
                )
              else
                const Icon(
                  Icons.chevron_right,
                  color: GhColors.textFaint,
                  size: 20,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IncompleteDataBadge extends StatelessWidget {
  const _IncompleteDataBadge({required this.missing});
  final List<String> missing;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: 'Missing: ${missing.join(', ')}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: GhColors.warningLight,
          borderRadius: BorderRadius.circular(99),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.info_outline, size: 11, color: GhColors.warning),
            SizedBox(width: 3),
            Text(
              'Incomplete',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: GhColors.warning,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
