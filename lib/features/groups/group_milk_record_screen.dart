import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../data/models/milking_session.dart';
import '../../data/models/models.dart';
import '../../data/services/milk_record_service.dart';
import '../../shared/widgets/animal_avatar.dart';
import '../../shared/widgets/gh_app_bar.dart';
import '../../shared/widgets/gh_design_icon.dart';
import '../../shared/widgets/gh_design_icons.dart';
import 'group_milk_record.dart';

class GroupMilkRecordScreen extends ConsumerStatefulWidget {
  const GroupMilkRecordScreen({
    super.key,
    required this.groupId,
  });

  final String groupId;

  @override
  ConsumerState<GroupMilkRecordScreen> createState() =>
      _GroupMilkRecordScreenState();
}

class _GroupMilkRecordScreenState extends ConsumerState<GroupMilkRecordScreen> {
  MilkingSession _session = MilkingSession.morning;
  late DateTime _selectedDate;
  AnimalGroup? _group;
  List<Animal> _lactating = [];
  final Map<String, TextEditingController> _controllers = {};
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _load();
  }

  Future<void> _load() async {
    final groups = await ref.read(groupRepositoryProvider).listGroups();
    final group = groups.where((g) => g.id == widget.groupId).firstOrNull;
    if (group == null) {
      if (mounted) setState(() => _loading = false);
      return;
    }
    final animals =
        await ref.read(animalRepositoryProvider).listAnimals();
    final groupAnimals =
        animals.where((a) => a.groupId == widget.groupId).toList();
    final lactating = lactatingAnimalsInGroup(groupAnimals);

    for (final a in lactating) {
      _controllers[a.id] = TextEditingController();
    }

    if (mounted) {
      setState(() {
        _group = group;
        _lactating = lactating;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: now.subtract(const Duration(days: 365 * 5)),
      lastDate: now,
    );
    if (picked != null) {
      setState(
        () => _selectedDate = DateTime(picked.year, picked.month, picked.day),
      );
    }
  }

  double get _totalLitres {
    var total = 0.0;
    for (final a in _lactating) {
      total += double.tryParse(_controllers[a.id]?.text ?? '') ?? 0;
    }
    return total;
  }

  String _sessionLabel(BuildContext context) =>
      _session.label(context.l10n);

  Future<void> _save() async {
    final total = _totalLitres;
    if (total <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter at least one milk volume')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final lifecycle = ref.read(lifecycleServiceProvider);
      final animalRepo = ref.read(animalRepositoryProvider);
      final lactation = ref.read(lactationRepositoryProvider);

      for (final animal in _lactating) {
        final litres =
            double.tryParse(_controllers[animal.id]?.text ?? '') ?? 0;
        if (litres <= 0) continue;
        if (lifecycle.milkBlockedByWithdrawal(animal)) continue;
        await lactation.recordMilk(
          animalId: animal.id,
          litres: litres,
          onDate: _selectedDate,
          session: _session,
        );
        if (MilkRecordService.isSameDay(_selectedDate, DateTime.now())) {
          final history = await lactation.milkHistory(animal.id);
          final dayTotal =
              MilkRecordService.totalLitresForDay(history, _selectedDate) ??
                  litres;
          final updated = lifecycle.recordMilk(animal, dayTotal);
          await animalRepo.updateAnimal(updated);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Recorded ${total.toStringAsFixed(1)} L (${_sessionLabel(context)}) across ${_lactating.length} animals',
            ),
          ),
        );
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _applyToAll(String value) {
    for (final c in _controllers.values) {
      c.text = value;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
          body: Center(child: CircularProgressIndicator()));
    }
    if (_group == null) {
      return const Scaffold(
        appBar: GhAppBar(title: 'Record milk'),
        body: Center(child: Text('Group not found')),
      );
    }

    final total = _totalLitres;

    return Scaffold(
      appBar: GhAppBar(
        title: 'Record milk',
        subtitle: _group!.name,
      ),
      body: Column(
        children: [
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: GhColors.pageBackground,
            child: Column(
              children: [
                SegmentedButton<MilkingSession>(
                  segments: [
                    ButtonSegment(
                      value: MilkingSession.morning,
                      label: Text(context.l10n.milkSessionMorning),
                      icon: const Icon(Icons.wb_sunny_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: MilkingSession.evening,
                      label: Text(context.l10n.milkSessionEvening),
                      icon: const Icon(Icons.nights_stay_outlined, size: 16),
                    ),
                    ButtonSegment(
                      value: MilkingSession.daily,
                      label: Text(context.l10n.milkSessionDaily),
                      icon: const Icon(Icons.calendar_today, size: 16),
                    ),
                  ],
                  selected: {_session},
                  onSelectionChanged: (s) =>
                      setState(() => _session = s.first),
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_month, size: 18),
                    label: Text(context.l10n.milkRecordDate),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${_lactating.length} milking animals',
                      style: const TextStyle(
                        fontSize: 13,
                        color: GhColors.textSecondary,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const GhDesignIcon(
                          assetPath: GhDesignIcons.bottle,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${total.toStringAsFixed(1)} L total',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: GhColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Spacer(),
                TextButton.icon(
                  onPressed: () {
                    final ctrl = TextEditingController();
                    showDialog<String>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Apply to all'),
                        content: TextField(
                          controller: ctrl,
                          keyboardType: const TextInputType
                              .numberWithOptions(decimal: true),
                          decoration: const InputDecoration(
                            labelText: 'Litres per animal',
                          ),
                          autofocus: true,
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () =>
                                Navigator.pop(ctx, ctrl.text),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                    ).then((val) {
                      ctrl.dispose();
                      if (val != null && val.isNotEmpty) {
                        _applyToAll(val);
                      }
                    });
                  },
                  icon: const Icon(Icons.content_copy, size: 16),
                  label: const Text('Apply to all'),
                ),
              ],
            ),
          ),
          Expanded(
            child: _lactating.isEmpty
                ? const Center(
                    child: Text(
                      'No lactating animals in this group',
                      style: TextStyle(color: GhColors.textSecondary),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _lactating.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (_, i) {
                      final animal = _lactating[i];
                      return _MilkAnimalRow(
                        animal: animal,
                        controller: _controllers[animal.id]!,
                        onChanged: () => setState(() {}),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: GhColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          'Save ${total.toStringAsFixed(1)} L (${_sessionLabel(context)})'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MilkAnimalRow extends StatelessWidget {
  const _MilkAnimalRow({
    required this.animal,
    required this.controller,
    required this.onChanged,
  });

  final Animal animal;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final blocked = animal.withdrawalDays != null && animal.withdrawalDays! > 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: blocked
            ? GhColors.warningLight.withValues(alpha: 0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GhColors.border),
      ),
      child: Row(
        children: [
          AnimalAvatar(animal: animal, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${animal.tag}${animal.name.isNotEmpty ? ' · ${animal.name}' : ''}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (animal.milkTodayLitres != null &&
                    animal.milkTodayLitres! > 0)
                  Text(
                    'Today so far: ${animal.milkTodayLitres!.toStringAsFixed(1)} L',
                    style: const TextStyle(
                      fontSize: 12,
                      color: GhColors.textSecondary,
                    ),
                  ),
                if (blocked)
                  const Text(
                    'On withdrawal — milk discarded',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: GhColors.warning,
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 80,
            child: TextField(
              controller: controller,
              enabled: !blocked,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              textAlign: TextAlign.center,
              onChanged: (_) => onChanged(),
              decoration: const InputDecoration(
                hintText: '0.0',
                suffixText: 'L',
                isDense: true,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
