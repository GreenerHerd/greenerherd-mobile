import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/gh_colors.dart';
import '../../../data/models/enums.dart';
import '../../../shared/widgets/species_icon.dart';

/// Livestock value summary (all-species dashboard only).
class LivestockValueCard extends StatelessWidget {
  const LivestockValueCard({
    super.key,
    required this.totalSar,
    required this.bySpecies,
  });

  final double totalSar;
  final Map<Species, double> bySpecies;

  static String _compactSar(double v) {
    if (v >= 1000) {
      return '${(v / 1000).round()}k';
    }
    return v.round().toString();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(
      locale: 'en',
      symbol: 'SAR ',
      decimalDigits: 0,
    );

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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Text(
                  'Livestock value',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: GhColors.textPrimary,
                  ),
                ),
              ),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: GhColors.primaryLight,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: SpeciesIcon.glyph(Species.cattle, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            currency.format(totalSar),
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: GhColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Estimated · weight × meat price + 3-mo milk',
            style: TextStyle(fontSize: 12, color: GhColors.textSecondary),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final species in Species.values) ...[
                if (species != Species.values.first) const SizedBox(width: 8),
                Expanded(
                  child: _SpeciesValueChip(
                    species: species,
                    value: _compactSar(bySpecies[species] ?? 0),
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

class _SpeciesValueChip extends StatelessWidget {
  const _SpeciesValueChip({required this.species, required this.value});

  final Species species;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: GhColors.primaryLight.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SpeciesIcon.glyph(species, size: 18),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: GhColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
