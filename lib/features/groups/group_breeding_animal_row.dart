import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/reproduction_status_rules.dart';
import '../../shared/widgets/animal_avatar.dart';
import '../../shared/widgets/gh_design_icon.dart';
import '../../shared/widgets/gh_design_icons.dart';
import '../../shared/widgets/gh_status_tag.dart';
import '../animals/widgets/member_status_dialogs.dart';
import 'group_detail_widgets.dart';
import 'group_providers.dart';

/// Breeding tab row: animal identity + pregnancy toggle (same icon UX as group onboarding).
class GroupBreedingAnimalRow extends ConsumerStatefulWidget {
  const GroupBreedingAnimalRow({
    super.key,
    required this.animal,
    required this.species,
    required this.groupId,
  });

  final Animal animal;
  final Species species;
  final String groupId;

  @override
  ConsumerState<GroupBreedingAnimalRow> createState() =>
      _GroupBreedingAnimalRowState();
}

class _GroupBreedingAnimalRowState extends ConsumerState<GroupBreedingAnimalRow> {
  bool _saving = false;

  Animal get _animal => widget.animal;

  bool get _isPregnant => _animal.tags.contains(AnimalTagType.pregnant);

  int? get _ageMonths => ReproductionStatusRules.ageMonthsFromAnimal(_animal);

  bool get _canBePregnant => ReproductionStatusRules.canBePregnant(
        species: widget.species,
        sex: _animal.sex,
        ageMonths: _ageMonths,
      );

  Future<void> _togglePregnancy() async {
    if (_saving || (!_canBePregnant && !_isPregnant)) return;

    if (_isPregnant) {
      await _persist(_clearPregnancy(_animal));
      return;
    }

    final result = await showDialog<PregnancyDialogResult>(
      context: context,
      builder: (ctx) => PregnancyDetailsDialog(
        species: widget.species,
        initialGestMonths: _animal.gestMonths,
        initialDueDate: _animal.dueDate,
        initialProlificacy: _animal.prolificacy,
        initialTwin: _animal.isTwin ?? false,
        initialBreedingMethod: _animal.breedingMethod,
      ),
    );
    if (!mounted || result == null) return;
    await _persist(_applyPregnancy(_animal, result));
  }

  void _refreshGroupAnimals() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.invalidate(groupAnimalsProvider(widget.groupId));
    });
  }

  Future<void> _persist(Animal updated) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await ref.read(animalRepositoryProvider).updateAnimal(updated);
      if (!mounted) return;
      FocusManager.instance.primaryFocus?.unfocus();
      _refreshGroupAnimals();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.breedingStatusUpdated)),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static Animal _applyPregnancy(Animal animal, PregnancyDialogResult result) {
    final seen = <AnimalTagType>{};
    final tags = <AnimalTagType>[
      for (final t in animal.tags.where((t) => t != AnimalTagType.readyToBreed))
        if (seen.add(t)) t,
      if (seen.add(AnimalTagType.pregnant)) AnimalTagType.pregnant,
    ];
    return animal.copyWith(
      tags: tags,
      gestMonths: result.gestMonths,
      dueDate: result.dueDate,
      prolificacy: result.prolificacy,
      isTwin: result.isTwin,
      breedingMethod: result.breedingMethod,
    );
  }

  static Animal _clearPregnancy(Animal animal) {
    final tags =
        animal.tags.where((t) => t != AnimalTagType.pregnant).toList();
    return animal.copyWith(
      tags: tags,
      isTwin: false,
      clearGestMonths: true,
      clearDueDate: true,
      clearProlificacy: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final subtitle = [
      _animal.breed,
      if (_animal.weightKg > 0) '${_animal.weightKg.toInt()} kg',
      if (_animal.ageLabel.trim().isNotEmpty && _animal.ageLabel != '—')
        _animal.ageLabel,
      if (_isPregnant && _animal.gestMonths != null)
        '${_animal.gestMonths}m pregnant',
    ].join(' · ');

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: groupSectionCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            InkWell(
              onTap: () => context.push('/animals/${_animal.id}'),
              borderRadius: BorderRadius.circular(12),
              child: Row(
                children: [
                  AnimalAvatar(animal: _animal, size: 48),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: MediaQuery.sizeOf(context).width * 0.42,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_animal.name} #${_animal.tag}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subtitle.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: const TextStyle(
                              fontSize: 13,
                              color: GhColors.textSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            if (_isPregnant)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: const GhStatusTag(tag: AnimalTagType.pregnant),
              ),
            if (_saving)
              const SizedBox(
                width: 40,
                height: 40,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              )
            else
              GhDesignStatusButton(
                assetPath: GhDesignIcons.welfare,
                active: _isPregnant,
                enabled: _canBePregnant || _isPregnant,
                tooltip: ReproductionStatusRules.disabledPregnancyTooltip(
                  species: widget.species,
                  sex: _animal.sex,
                  ageMonths: _ageMonths,
                ),
                onTap: _togglePregnancy,
                size: 40,
              ),
          ],
        ),
      ),
    );
  }
}
