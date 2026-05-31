import 'package:flutter/material.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/theme/gh_colors.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/models.dart';
import '../../../data/services/animal_mapper.dart';

/// Species demographics (sex, breeds, age buckets) for per-species dashboard.
class DashboardDemographicsCard extends StatelessWidget {
  const DashboardDemographicsCard({
    super.key,
    required this.species,
    required this.animals,
  });

  final Species species;
  final List<Animal> animals;

  static const _ageBuckets = [
    ('0–6m', 0, 6),
    ('6–12m', 6, 12),
    ('1–2y', 12, 24),
    ('2–5y', 24, 60),
    ('5y+', 60, 9999),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final filtered = animals.where((a) => a.species == species).toList();
    final total = filtered.length;
    final females =
        filtered.where((a) => a.sex.toUpperCase().startsWith('F')).length;
    final males = total - females;

    final breedCounts = <String, int>{};
    for (final a in filtered) {
      final name = a.breed.trim().isNotEmpty ? a.breed : 'Unknown';
      breedCounts[name] = (breedCounts[name] ?? 0) + 1;
    }
    final breeds = breedCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final bucketCounts = List<int>.filled(_ageBuckets.length, 0);
    for (final a in filtered) {
      final fromLabel = AnimalMapper.dashboardAgeBucketIndex(a.ageLabel);
      if (fromLabel != null) {
        bucketCounts[fromLabel]++;
        continue;
      }
      final months = AnimalMapper.ageMonthsForAnimal(a);
      for (var i = 0; i < _ageBuckets.length; i++) {
        final (_, minM, maxM) = _ageBuckets[i];
        if (months >= minM && months < maxM) {
          bucketCounts[i]++;
          break;
        }
      }
    }

    final speciesLabel = localizedSpecies(species, l10n);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GhColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GhColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  '$speciesLabel demographics',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                l10n.loadedCount(total),
                style: const TextStyle(
                  fontSize: 12,
                  color: GhColors.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: SizedBox(
              height: 8,
              child: Row(
                children: [
                  if (females > 0)
                    Expanded(
                      flex: females,
                      child: Container(color: GhColors.primary),
                    ),
                  if (males > 0)
                    Expanded(
                      flex: males,
                      child: Container(color: GhColors.secondary),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Female $females',
                style: const TextStyle(fontSize: 11, color: GhColors.primary),
              ),
              Text(
                'Male $males',
                style: const TextStyle(fontSize: 11, color: GhColors.secondary),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Breeds',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: GhColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final e in breeds.take(4))
                _BreedChip(label: '${e.key} ${e.value}'),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            l10n.ageRange,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: GhColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < _ageBuckets.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _AgeBucket(
                    count: bucketCounts[i],
                    label: _ageBuckets[i].$1,
                    muted: bucketCounts[i] == 0,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _BreedChip extends StatelessWidget {
  const _BreedChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GhColors.pageBackground,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: GhColors.border),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _AgeBucket extends StatelessWidget {
  const _AgeBucket({
    required this.count,
    required this.label,
    required this.muted,
  });

  final int count;
  final String label;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: GhColors.primaryLight.withOpacity(muted ? 0.25 : 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: muted ? GhColors.textSecondary : GhColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              color: muted ? GhColors.textSecondary : GhColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
