import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n/l10n_extensions.dart';
import '../../../core/providers/providers.dart';
import '../../../core/theme/gh_colors.dart';
import '../../../core/theme/gh_typography.dart';
import '../../../data/models/enums.dart';
import '../../../data/models/inventory_models.dart';
import '../../../data/models/models.dart';
import '../../../features/groups/group_mock_extras.dart';
import '../../../features/nutrition/nutrition_providers.dart';
import '../../../shared/widgets/nutrition_rating_card.dart';
import '../add_group_wizard.dart';
import '../animal_form_helpers.dart';

enum GroupWizardConfirmPhase { overview, addMeal, done }

/// Post–step-3 confirmation: summary, nutrition, optional meal, then exit.
class GroupWizardConfirmationStep extends ConsumerStatefulWidget {
  const GroupWizardConfirmationStep({
    super.key,
    required this.group,
    required this.species,
    required this.purpose,
    required this.breedName,
    required this.sex,
    required this.ageRangeLabel,
    required this.members,
    required this.phase,
    required this.onPhaseChanged,
    required this.onSkipMeal,
    required this.onMealSaved,
    required this.onAddAnotherGroup,
    required this.onClose,
  });

  final AnimalGroup group;
  final Species species;
  final GroupPurpose purpose;
  final String breedName;
  final String sex;
  final String ageRangeLabel;
  final List<GroupMemberDraft> members;
  final GroupWizardConfirmPhase phase;
  final ValueChanged<GroupWizardConfirmPhase> onPhaseChanged;
  final VoidCallback onSkipMeal;
  final Future<void> Function(String mealId, double kg) onMealSaved;
  final VoidCallback onAddAnotherGroup;
  final VoidCallback onClose;

  @override
  ConsumerState<GroupWizardConfirmationStep> createState() =>
      _GroupWizardConfirmationStepState();
}

class _GroupWizardConfirmationStepState
    extends ConsumerState<GroupWizardConfirmationStep> {
  final _mealAmountCtrl = TextEditingController();
  List<MealPlan> _meals = [];
  String? _selectedMealId;
  var _loadingMeals = true;
  var _savingMeal = false;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    final meals = await ref.read(inventoryRepositoryProvider).listMeals();
    if (!mounted) return;
    setState(() {
      _meals = meals;
      _selectedMealId = meals.isNotEmpty ? meals.first.id : null;
      _loadingMeals = false;
    });
  }

  @override
  void dispose() {
    _mealAmountCtrl.dispose();
    super.dispose();
  }

  Future<void> _submitMeal() async {
    final mealId = _selectedMealId;
    if (mealId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a meal plan')),
      );
      return;
    }
    final kg = double.tryParse(_mealAmountCtrl.text.trim());
    if (kg == null || kg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter amount in kg')),
      );
      return;
    }
    setState(() => _savingMeal = true);
    try {
      await widget.onMealSaved(mealId, kg);
      if (mounted) {
        widget.onPhaseChanged(GroupWizardConfirmPhase.done);
      }
    } finally {
      if (mounted) setState(() => _savingMeal = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      children: [
        Text(
          l10n.groupCreatedMessage,
          style: const TextStyle(
            fontSize: 14,
            color: GhColors.textSecondary,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        _SummaryCard(
          group: widget.group,
          species: widget.species,
          purpose: widget.purpose,
          breedName: widget.breedName,
          sex: widget.sex,
          ageRangeLabel: widget.ageRangeLabel,
          members: widget.members,
        ),
        const SizedBox(height: 16),
        ref.watch(nutritionGapProvider(widget.group.id)).when(
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => const SizedBox.shrink(),
              data: (gap) => NutritionRatingCard(gap: gap),
            ),
        const SizedBox(height: 24),
        if (widget.phase == GroupWizardConfirmPhase.overview) ...[
          FilledButton(
            onPressed: () =>
                widget.onPhaseChanged(GroupWizardConfirmPhase.addMeal),
            child: Text(l10n.addAMeal),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: () {
              widget.onSkipMeal();
              widget.onPhaseChanged(GroupWizardConfirmPhase.done);
            },
            child: Text(l10n.skipForNow),
          ),
        ] else if (widget.phase == GroupWizardConfirmPhase.addMeal) ...[
          Text(l10n.addAMeal, style: GhTypography.h03),
          const SizedBox(height: 12),
          if (_loadingMeals)
            const Center(child: CircularProgressIndicator())
          else if (_meals.isEmpty)
            Text(
              l10n.mealPlans,
              style: const TextStyle(color: GhColors.textSecondary),
            )
          else ...[
            DropdownButtonFormField<String>(
              initialValue: _selectedMealId,
              isExpanded: true,
              decoration: InputDecoration(
                labelText: l10n.mealPlans,
                isDense: true,
              ),
              items: _meals
                  .map(
                    (meal) => DropdownMenuItem(
                      value: meal.id,
                      child: Text(
                        meal.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => setState(() => _selectedMealId = v),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _mealAmountCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: l10n.mealAmountKg,
                suffixText: 'kg',
                isDense: true,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _savingMeal ? null : _submitMeal,
              child: _savingMeal
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.saveMeal),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  widget.onPhaseChanged(GroupWizardConfirmPhase.overview),
              child: const Text('Back'),
            ),
          ],
        ] else ...[
          FilledButton(
            onPressed: widget.onAddAnotherGroup,
            child: Text(l10n.addAnotherGroup),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: widget.onClose,
            child: Text(l10n.finishGroup),
          ),
        ],
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.group,
    required this.species,
    required this.purpose,
    required this.breedName,
    required this.sex,
    required this.ageRangeLabel,
    required this.members,
  });

  final AnimalGroup group;
  final Species species;
  final GroupPurpose purpose;
  final String breedName;
  final String sex;
  final String ageRangeLabel;
  final List<GroupMemberDraft> members;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final pregnant = members.where((m) => m.pregnant).length;
    final lactating = members.where((m) => m.lactating).length;
    final sick = members.where((m) => m.sick).length;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: GhColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(group.name, style: GhTypography.h02),
            const SizedBox(height: 8),
            _SummaryRow(
              label: l10n.species,
              value: localizedSpecies(species, l10n),
            ),
            _SummaryRow(
              label: 'Purpose',
              value: GroupMockExtras.purposeLabel(purpose),
            ),
            _SummaryRow(label: l10n.headCount, value: '${group.headCount}'),
            _SummaryRow(label: l10n.breed, value: breedName),
            _SummaryRow(label: l10n.sex, value: sex == 'Male' ? 'M' : 'F'),
            _SummaryRow(label: l10n.ageRange, value: ageRangeLabel),
            if (pregnant > 0 || lactating > 0 || sick > 0) ...[
              const SizedBox(height: 8),
              Text(
                [
                  if (pregnant > 0) '$pregnant pregnant',
                  if (lactating > 0) '$lactating lactating',
                  if (sick > 0) '$sick sick',
                ].join(' · '),
                style: const TextStyle(
                  fontSize: 13,
                  color: GhColors.textSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: GhColors.textFaint,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
