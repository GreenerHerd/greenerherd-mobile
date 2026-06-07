import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/lactation_models.dart';
import '../../data/models/milking_session.dart';
import '../../data/models/models.dart';
import '../../data/services/milk_record_service.dart';
import '../../shared/widgets/gh_app_bar.dart';
import 'animal_providers.dart';
import 'lactation_providers.dart';

class RecordMilkScreen extends ConsumerStatefulWidget {
  const RecordMilkScreen({super.key, required this.animalId});

  final String animalId;

  @override
  ConsumerState<RecordMilkScreen> createState() => _RecordMilkScreenState();
}

class _RecordMilkScreenState extends ConsumerState<RecordMilkScreen> {
  final _litres = TextEditingController();
  var _session = MilkingSession.morning;
  late DateTime _selectedDate;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
  }

  @override
  void dispose() {
    _litres.dispose();
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
      setState(() => _selectedDate = DateTime(picked.year, picked.month, picked.day));
    }
  }

  Future<void> _save(Animal animal) async {
    final l10n = context.l10n;
    final litres = double.tryParse(_litres.text.trim());
    if (litres == null || litres < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.validMilkVolume)),
      );
      return;
    }
    final lifecycle = ref.read(lifecycleServiceProvider);
    if (lifecycle.milkBlockedByWithdrawal(animal)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.milkBlockedWithdrawal)),
      );
      return;
    }
    setState(() => _saving = true);
    try {
      final lactation = ref.read(lactationRepositoryProvider);
      await lactation.recordMilk(
        animalId: animal.id,
        litres: litres,
        onDate: _selectedDate,
        session: _session,
      );
      var updated = animal;
      if (MilkRecordService.isSameDay(_selectedDate, DateTime.now())) {
        final history = await lactation.milkHistory(animal.id);
        final total =
            MilkRecordService.totalLitresForDay(history, _selectedDate) ??
                litres;
        updated = lifecycle.recordMilk(animal, total);
        await ref.read(animalRepositoryProvider).updateAnimal(updated);
      }
      ref
        ..invalidate(animalProvider(widget.animalId))
        ..invalidate(animalsListProvider)
        ..invalidate(milkHistoryProvider(widget.animalId))
        ..invalidate(lactationCycleProvider(widget.animalId));
      if (mounted) {
        context.pop(true);
        final dateLabel = DateFormat.yMMMd().format(_selectedDate);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.recordedMilkSessionFor(
                litres.toStringAsFixed(1),
                animal.tag,
                _session.label(l10n),
                dateLabel,
              ),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _litresLabel(AppLocalizations l10n) => switch (_session) {
        MilkingSession.morning => l10n.milkLitresMorning,
        MilkingSession.evening => l10n.milkLitresEvening,
        MilkingSession.daily => l10n.milkLitresDaily,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final animalAsync = ref.watch(animalProvider(widget.animalId));
    final historyAsync = ref.watch(milkHistoryProvider(widget.animalId));
    final dateLabel = DateFormat.yMMMd().format(_selectedDate);
    final isToday = MilkRecordService.isSameDay(_selectedDate, DateTime.now());

    return animalAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(body: Center(child: Text('$e'))),
      data: (animal) {
        if (animal == null) {
          return Scaffold(body: Center(child: Text(l10n.animalNotFound)));
        }
        return Scaffold(
          appBar: GhAppBar(
            title: l10n.recordMilk,
            subtitle: '#${animal.tag}',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              SegmentedButton<MilkingSession>(
                segments: [
                  ButtonSegment(
                    value: MilkingSession.morning,
                    label: Text(l10n.milkSessionMorning),
                    icon: const Icon(Icons.wb_sunny_outlined, size: 16),
                  ),
                  ButtonSegment(
                    value: MilkingSession.evening,
                    label: Text(l10n.milkSessionEvening),
                    icon: const Icon(Icons.nights_stay_outlined, size: 16),
                  ),
                  ButtonSegment(
                    value: MilkingSession.daily,
                    label: Text(l10n.milkSessionDaily),
                    icon: const Icon(Icons.calendar_today, size: 16),
                  ),
                ],
                selected: {_session},
                onSelectionChanged: (s) =>
                    setState(() => _session = s.first),
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.milkRecordDate),
                subtitle: Text(dateLabel),
                trailing: OutlinedButton.icon(
                  onPressed: _pickDate,
                  icon: const Icon(Icons.calendar_month, size: 18),
                  label: Text(l10n.changeDate),
                ),
              ),
              if (isToday && animal.milkTodayLitres != null) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.previousTodayMilk(
                    animal.milkTodayLitres!.toStringAsFixed(1),
                  ),
                  style: const TextStyle(color: GhColors.textSecondary),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _litres,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: _litresLabel(l10n),
                ),
              ),
              const SizedBox(height: 20),
              historyAsync.when(
                data: (history) => _RecentMilkHistory(
                  history: history,
                  selectedDate: _selectedDate,
                  l10n: l10n,
                ),
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : () => _save(animal),
                child: _saving
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.save),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RecentMilkHistory extends StatelessWidget {
  const _RecentMilkHistory({
    required this.history,
    required this.selectedDate,
    required this.l10n,
  });

  final List<MilkYieldRecord> history;
  final DateTime selectedDate;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();
    final recent = history.reversed.take(8).toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.recentMilkRecords,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: GhColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ...recent.map((r) {
          final session = MilkingSessionWire.fromWire(r.milkingSession);
          final sessionLabel = session?.label(l10n) ?? r.milkingSession ?? '—';
          final dateLabel = DateFormat.yMMMd().format(r.date);
          final highlight = MilkRecordService.isSameDay(r.date, selectedDate);
          return Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              '$dateLabel · $sessionLabel · ${r.litres.toStringAsFixed(1)} L',
              style: TextStyle(
                fontSize: 13,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.normal,
                color: highlight ? GhColors.primary : GhColors.textSecondary,
              ),
            ),
          );
        }),
      ],
    );
  }
}



