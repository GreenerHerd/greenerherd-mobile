import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/animal_avatar.dart';
import '../../shared/widgets/gh_app_bar.dart';
import '../../shared/widgets/gh_design_icons.dart';
import 'animal_form_helpers.dart';
import 'animal_lifecycle_ui.dart';
import 'move_group_sheet.dart';
import 'animal_providers.dart';
import '../tasks/tasks_screen.dart';
import 'animal_breeding_tab.dart';
import 'animal_health_tab.dart';
import 'animal_profile_edit_form.dart';
import 'animal_tasks_tab.dart';
import 'animal_weight_tab.dart';
import 'breeding_milk_tabs.dart';

class AnimalProfileScreen extends ConsumerStatefulWidget {
  const AnimalProfileScreen({super.key, required this.animalId});

  final String animalId;

  @override
  ConsumerState<AnimalProfileScreen> createState() => _AnimalProfileScreenState();
}

class _AnimalProfileScreenState extends ConsumerState<AnimalProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;
  Animal? _animal;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 7, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAnimal();
      _applyInitialTab();
    });
  }

  Future<void> _loadAnimal() async {
    final a =
        await ref.read(animalRepositoryProvider).getAnimal(widget.animalId);
    if (mounted) setState(() => _animal = a);
  }

  void _applyInitialTab() {
    final GoRouterState? state;
    try {
      state = GoRouterState.of(context);
    } catch (_) {
      return;
    }
    final tab = state.uri.queryParameters['tab'];
    if (tab == null) return;
    final index = int.tryParse(tab);
    if (index != null && index >= 0 && index < _tabs.length) {
      _tabs.animateTo(index);
    }
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final animal = _animal;
    if (animal == null) return;
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1200,
      imageQuality: 85,
    );
    if (picked == null) return;
    final updated = animal.copyWith(photoPath: picked.path);
    await ref.read(animalRepositoryProvider).updateAnimal(updated);
    ref.invalidate(animalProvider(widget.animalId));
    await _loadAnimal();
  }

  @override
  Widget build(BuildContext context) {
    final animal = _animal;
    if (animal == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final l10n = AppLocalizations.of(context);
    final statusLine = animal.status == AnimalStatus.deceased
        ? [
            l10n.deceased,
            if (animal.cullReasonLabel != null &&
                animal.cullReasonLabel!.isNotEmpty)
              animal.cullReasonLabel!,
          ].join(' · ')
        : [animal.breed, animal.ageLabel].join(' · ');

    return Scaffold(
      backgroundColor: GhColors.pageBackground,
      appBar: GhAppBar(
        title: '#${animal.tag}',
        subtitle: animal.name.isEmpty ? null : animal.name,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          if (_editing)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: l10n.cancel,
              onPressed: () => setState(() => _editing = false),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit_outlined),
              tooltip: l10n.edit,
              onPressed: () {
                setState(() => _editing = true);
                _tabs.animateTo(0);
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    AnimalAvatar(animal: animal, size: 88),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  animal.name.isEmpty ? '#${animal.tag}' : animal.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  statusLine,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: GhColors.textSecondary,
                  ),
                ),
                if ((animal.withdrawalDays ?? 0) > 0) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: GhColors.warningLight,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    child: Text(
                      'Withdrawal · ${animal.withdrawalDays} d',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: GhColors.warning,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          _QuickActions(animal: animal, onUpdated: _loadAnimal),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            labelColor: GhColors.primary,
            indicatorColor: GhColors.primary,
            tabs: [
              Tab(text: l10n.tabOverview),
              Tab(text: l10n.tabWeight),
              Tab(text: l10n.tabBreeding),
              Tab(text: l10n.tabMilking),
              Tab(text: l10n.tabHealth),
              Tab(text: l10n.tabTasks),
              Tab(text: l10n.tabMedia),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _OverviewTab(
                  animal: animal,
                  editing: _editing,
                  onEditSaved: () {
                    _loadAnimal();
                    setState(() => _editing = false);
                  },
                  onEditCancel: () => setState(() => _editing = false),
                  onUpdated: _loadAnimal,
                ),
                AnimalWeightTab(animal: animal),
                AnimalBreedingTab(animal: animal, onUpdated: _loadAnimal),
                AnimalMilkingTab(animal: animal, onUpdated: _loadAnimal),
                AnimalHealthTab(animal: animal, onCured: _loadAnimal),
                AnimalTasksTab(animal: animal),
                _MediaTab(animal: animal, onPickPhoto: _pickPhoto),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

class _QuickActions extends ConsumerWidget {
  const _QuickActions({
    required this.animal,
    required this.onUpdated,
  });

  final Animal animal;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lifecycle = ref.watch(lifecycleServiceProvider);
    final repo = ref.read(animalRepositoryProvider);
    return SizedBox(
      height: 104,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          if (lifecycle.canRecordMilk(animal))
            _Action(
              designIcon: GhDesignIcons.bottle,
              label: 'Record milk',
              onTap: () => context
                  .push('/animals/${animal.id}/record-milk')
                  .then((_) => onUpdated()),
            ),
          _Action(
            designIcon: GhDesignIcons.medication,
            label: 'Treatment',
            onTap: () => showTreatmentSheet(
              context,
              animalId: animal.id,
              isSick: animal.isSick,
              illnessNote: animal.illnessNote,
              initialTreatment: animal.treatmentDetails,
              onRecordTreatment: (details) async {
                final updated = lifecycle.recordTreatment(
                  animal,
                  illnessNote: details.illnessNote,
                  treatment: details.treatment,
                );
                await repo.updateAnimal(updated);
                if (!context.mounted) return;
                FocusManager.instance.primaryFocus?.unfocus();
                onUpdated();
                refreshAnimalAfterMutation(
                  ref,
                  animalId: animal.id,
                  groupId: animal.groupId.isNotEmpty ? animal.groupId : null,
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(context.l10n.treatmentRecorded)),
                  );
                }
              },
              onMarkCured: () async {
                final updated = lifecycle.markCured(animal);
                await repo.updateAnimal(updated);
                if (!context.mounted) return;
                FocusManager.instance.primaryFocus?.unfocus();
                onUpdated();
                refreshAnimalAfterMutation(
                  ref,
                  animalId: animal.id,
                  groupId: animal.groupId.isNotEmpty ? animal.groupId : null,
                );
              },
            ),
          ),
          _Action(
            icon: Icons.swap_horiz,
            label: 'Move group',
            onTap: () => showMoveGroupSheet(
              context,
              ref,
              animal: animal,
              onMoved: onUpdated,
            ),
          ),
          if (animal.tags.contains(AnimalTagType.pregnant))
            _Action(
              designIcon: GhDesignIcons.welfare,
              label: 'Pregnancy',
              onTap: () => showPregnancyOutcomePicker(context, animal.id),
            ),
          _Action(
            designIcon: GhDesignIcons.cullTag,
            label: 'Cull / sell',
            onTap: () => showCullActionSheet(
              context,
              alreadyFlagged: animal.cullFlagged,
              onFlag: (selection) async {
                final updated =
                    lifecycle.flagForCull(animal, selection: selection);
                await repo.updateAnimal(updated);
                if (!context.mounted) return;
                onUpdated();
                refreshAnimalAfterMutation(
                  ref,
                  animalId: animal.id,
                  groupId:
                      animal.groupId.isNotEmpty ? animal.groupId : null,
                );
              },
              onClear: () async {
                final updated = lifecycle.clearCullFlag(animal);
                await repo.updateAnimal(updated);
                onUpdated();
              },
              onSell: () => context.push(
                    '/inventory/sell?animalId=${Uri.encodeComponent(animal.id)}',
                  ),
            ),
          ),
          _Action(
            icon: Icons.task_alt,
            label: 'Add task',
            onTap: () => showNewTaskSheet(
              context,
              ref,
              animalId: animal.id,
              groupId: animal.groupId,
              animalTag: animal.tag,
              animalName: animal.name,
            ),
          ),
        ],
      ),
    );
  }
}

class _Action extends StatelessWidget {
  const _Action({
    this.icon,
    this.designIcon,
    required this.label,
    this.onTap,
  }) : assert(icon != null || designIcon != null);

  final IconData? icon;
  final String? designIcon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 64,
          height: 88,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: GhColors.primaryLight.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: designIcon != null
                    ? Padding(
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(designIcon!, fit: BoxFit.contain),
                      )
                    : Icon(icon, color: GhColors.primary, size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({
    required this.animal,
    required this.editing,
    required this.onEditSaved,
    required this.onEditCancel,
    required this.onUpdated,
  });

  final Animal animal;
  final bool editing;
  final VoidCallback onEditSaved;
  final VoidCallback onEditCancel;
  final VoidCallback onUpdated;

  String _formatDob(DateTime dob) =>
      '${dob.year}-${dob.month.toString().padLeft(2, '0')}-${dob.day.toString().padLeft(2, '0')}';

  String _ageFromDob(DateTime dob) {
    final now = DateTime.now();
    final months = (now.year - dob.year) * 12 + (now.month - dob.month);
    if (months < 1) return '< 1 month';
    if (months < 12) return '$months months';
    final years = months ~/ 12;
    final rem = months % 12;
    return rem > 0 ? '$years yr $rem m' : '$years yr';
  }

  bool get _isHeifer =>
      animal.isHeifer == true &&
      !animal.tags.contains(AnimalTagType.pregnant);

  String _statusSummary() {
    final parts = <String>[];
    if (animal.tags.contains(AnimalTagType.pregnant)) parts.add('Pregnant');
    if (animal.tags.contains(AnimalTagType.lactating)) parts.add('Lactating');
    if (animal.tags.contains(AnimalTagType.readyToBreed)) parts.add('Ready to breed');
    if (animal.tags.contains(AnimalTagType.weaning)) parts.add('Weaning');
    if (animal.tags.contains(AnimalTagType.sick)) parts.add('Sick');
    if (animal.tags.contains(AnimalTagType.cull)) parts.add('Cull');
    if (animal.tags.contains(AnimalTagType.fattening)) parts.add('Fattening');
    return parts.isEmpty ? 'Active' : parts.join(' · ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(groupsListProvider);
    final groupName = groups.whenOrNull(
      data: (list) {
        try {
          return list.firstWhere((g) => g.id == animal.groupId).name;
        } catch (_) {
          return null;
        }
      },
    );

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (animal.hasIncompleteData)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: GhColors.warningLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: GhColors.warning.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: GhColors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Missing: ${animal.missingFields.join(', ')}',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: GhColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          decoration: BoxDecoration(
            color: GhColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: GhColors.border),
          ),
          child: AnimalPurposeEditor(animal: animal, onUpdated: onUpdated),
        ),
        const SizedBox(height: 12),
        if (editing)
          AnimalProfileEditForm(
            animal: animal,
            onSaved: onEditSaved,
            onCancel: onEditCancel,
          )
        else
          _KvCard(
            rows: [
              _KvRow('Ear tag', '#${animal.tag}'),
              _KvRow('Name', animal.name.isEmpty ? '—' : animal.name),
              _KvRow(
                'Species',
                animal.species.name[0].toUpperCase() +
                    animal.species.name.substring(1),
              ),
              _KvRow('Breed', animal.breed.isEmpty ? '—' : animal.breed),
              _KvRow(
                'Sex',
                animal.sex == 'F'
                    ? 'Female'
                    : animal.sex == 'M'
                        ? 'Male'
                        : animal.sex,
              ),
              if (_isHeifer) const _KvRow('Type', 'Heifer'),
              if (animal.dob != null) ...[
                _KvRow('Date of birth', _formatDob(animal.dob!)),
                _KvRow('Age', _ageFromDob(animal.dob!)),
              ] else
                _KvRow('Age range', animal.ageLabel),
              const _KvRow('Origin', 'Born on farm'),
              _KvRow('Status', _statusSummary()),
              if (animal.tags.contains(AnimalTagType.pregnant) &&
                  animal.gestMonths != null)
                _KvRow('Gestation', '${animal.gestMonths} months'),
              _KvRow(
                'Weight',
                '${animal.weightKg.toInt()} kg',
                hint: animal.weightIndicative ? 'indicative' : 'recorded',
              ),
              if (animal.bcs != null)
                _KvRow('BCS', '${animal.bcs!.toStringAsFixed(1)} / 5'),
              if (animal.isTwin == true) const _KvRow('Twin', 'Yes'),
              _KvRow(
                'Group',
                groupName ?? animal.groupId,
                highlight: true,
              ),
              if (animal.sire != null)
                _KvRow('Sire', '${animal.sire!} · ${animal.breed}'),
              if (animal.dam != null)
                _KvRow('Dam', '${animal.dam!} · ${animal.breed}'),
              if (animal.milkTodayLitres != null)
                _KvRow(
                  'Milk today',
                  '${animal.milkTodayLitres!.toStringAsFixed(1)} L',
                ),
              if (animal.withdrawalDays != null && animal.withdrawalDays! > 0)
                _KvRow('Withdrawal', '${animal.withdrawalDays} days remaining'),
            ],
          ),
      ],
    );
  }
}

class _KvCard extends StatelessWidget {
  const _KvCard({required this.rows});

  final List<_KvRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: GhColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GhColors.border),
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 20),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _KvRow extends StatelessWidget {
  const _KvRow(this.label, this.value, {this.hint, this.highlight = false});

  final String label;
  final String value;
  final String? hint;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: GhColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: highlight ? GhColors.primary : GhColors.textPrimary,
                  ),
                ),
                if (hint != null)
                  Text(
                    hint!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: GhColors.textFaint,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MediaTab extends StatelessWidget {
  const _MediaTab({required this.animal, required this.onPickPhoto});

  final Animal animal;
  final VoidCallback onPickPhoto;

  @override
  Widget build(BuildContext context) {
    final hasPhoto =
        animal.photoPath != null && animal.photoPath!.isNotEmpty;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (hasPhoto)
          Center(
            child: AnimalAvatar(animal: animal, size: 200),
          )
        else
          const Center(
            child: Text(
              'No photos yet',
              style: TextStyle(color: GhColors.textSecondary),
            ),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onPickPhoto,
          icon: const Icon(Icons.add_a_photo),
          label: const Text('Add photo'),
        ),
      ],
    );
  }
}
