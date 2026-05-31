import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/mock/profile_mock_data.dart';
import '../../data/models/breeding_methods.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/gestation_dates.dart';
import '../../data/services/reproduction_status_rules.dart';
import '../../shared/widgets/gh_kv_list.dart';
import 'animal_lifecycle_ui.dart';
import 'breeding_status_section.dart';
import 'record_ai_sheet.dart';

class AnimalBreedingTab extends ConsumerWidget {
  const AnimalBreedingTab({
    super.key,
    required this.animal,
    required this.onUpdated,
  });

  final Animal animal;
  final VoidCallback onUpdated;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isFemale = ReproductionStatusRules.isFemaleSex(animal.sex);

    if (!ReproductionStatusRules.showsBreedingStatusTab(animal)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.breedingFemalesOnly,
            textAlign: TextAlign.center,
            style: const TextStyle(color: GhColors.textSecondary),
          ),
        ),
      );
    }

    final isPregnant =
        isFemale && animal.tags.contains(AnimalTagType.pregnant);
    final summary = isFemale ? ProfileMockData.breedingSummary(animal.id) : null;
    final aiRecords = isFemale
        ? ProfileMockData.aiRecords(animal.id)
        : const <MockAiRecord>[];
    final miscarriages = isFemale
        ? ProfileMockData.miscarriages(animal.id)
        : const <MockMiscarriageRecord>[];
    final history = isFemale
        ? ProfileMockData.breedingHistoryKv(animal.id)
        : const <GhKvEntry>[];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        BreedingStatusSection(animal: animal, onUpdated: onUpdated),
        if (isFemale && isPregnant) ...[
          const SizedBox(height: 12),
          _PregnancyProgressCard(animal: animal),
        ],
        if (isFemale && (summary != null || animal.breedingMethod != null)) ...[
          const SizedBox(height: 12),
          GhKvListCard(
            rows: [
              if (animal.breedingMethod != null)
                GhKvEntry(
                  label: l10n.fertilityMethodLabel,
                  value: BreedingMethodCatalog.label(animal.breedingMethod!, l10n),
                ),
              if (summary?.method != null)
                GhKvEntry(label: l10n.methodLabel, value: summary!.method!),
              if (summary?.sire != null)
                GhKvEntry(
                  label: l10n.sireLabel,
                  value: summary!.sire!,
                  highlight: true,
                ),
              if (summary?.provider != null)
                GhKvEntry(label: l10n.providerLabel, value: summary!.provider!),
              if (summary?.attemptLabel != null)
                GhKvEntry(
                  label: l10n.attemptNumberLabel,
                  value: summary!.attemptLabel!,
                  subtitle: summary.attemptSubtitle,
                  isLast: true,
                ),
            ],
          ),
        ],
        if (isFemale) ...[
          const SizedBox(height: 12),
          _AiRecordsSection(
            records: aiRecords,
            onAdd: () => showRecordAiSheet(context, ref),
          ),
          const SizedBox(height: 12),
          _MiscarriagesSection(
            records: miscarriages,
            onRecord: () {
              if (isPregnant) {
                showPregnancyOutcomePicker(context, animal.id);
              } else {
                context.push('/animals/${animal.id}/record-miscarriage');
              }
            },
          ),
        ],
        if (isFemale && history.isNotEmpty) ...[
          const SizedBox(height: 12),
          GhKvListCard(title: l10n.breedingHistory, rows: history),
        ],
        if (isFemale && isPregnant) ...[
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => showPregnancyOutcomePicker(context, animal.id),
            icon: const Icon(Icons.child_care),
            label: Text(l10n.recordPregnancyOutcome),
          ),
        ],
      ],
    );
  }
}

class _PregnancyProgressCard extends StatelessWidget {
  const _PregnancyProgressCard({required this.animal});

  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final gestMonths = animal.gestMonths ?? 0;
    final maxMonths = switch (animal.species) {
      Species.cattle => 9,
      Species.goat || Species.sheep => 5,
    };
    final progress = maxMonths > 0
        ? (gestMonths / maxMonths).clamp(0.0, 1.0)
        : 0.0;
    final dueDate = GestationDates.effectiveDueDate(animal, DateTime.now());
    final prolificacy = GestationDates.effectiveProlificacy(animal);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.pregnant, style: GhTypography.h03),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 8,
                backgroundColor: GhColors.border,
                color: GhColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            if (gestMonths > 0)
              Text(
                l10n.gestationMonthsValue(gestMonths),
                style: const TextStyle(
                  fontSize: 12,
                  color: GhColors.textSecondary,
                ),
              ),
            if (dueDate != null) ...[
              const SizedBox(height: 4),
              Text(
                '${l10n.dueDateLabel}: ${GestationDates.formatDate(dueDate)}',
                style: const TextStyle(
                  fontSize: 12,
                  color: GhColors.textSecondary,
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              '${l10n.prolificacyLabel}: $prolificacy',
              style: const TextStyle(
                fontSize: 12,
                color: GhColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiRecordsSection extends StatelessWidget {
  const _AiRecordsSection({required this.records, required this.onAdd});

  final List<MockAiRecord> records;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.artificialInseminations, style: GhTypography.h03),
                  const SizedBox(height: 4),
                  Text(
                    l10n.recordsOnFile(records.length),
                    style: const TextStyle(
                      fontSize: 12,
                      color: GhColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onAdd, child: Text(l10n.addAi)),
          ],
        ),
        const SizedBox(height: 8),
        if (records.isEmpty)
          _EmptyBreedingCard(
            icon: Icons.vaccines_outlined,
            title: l10n.noAiRecordsYet,
            body: l10n.noAiRecordsHint,
            buttonLabel: l10n.recordAi,
            onPressed: onAdd,
          )
        else
          ...records.map(
            (r) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _AiRecordCard(record: r),
            ),
          ),
      ],
    );
  }
}

class _MiscarriagesSection extends StatelessWidget {
  const _MiscarriagesSection({required this.records, required this.onRecord});

  final List<MockMiscarriageRecord> records;
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.miscarriagesSection, style: GhTypography.h03),
                  const SizedBox(height: 4),
                  Text(
                    records.isEmpty
                        ? l10n.noLossesRecorded
                        : l10n.recordsOnFile(records.length),
                    style: const TextStyle(
                      fontSize: 12,
                      color: GhColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(onPressed: onRecord, child: Text(l10n.recordMiscarriage)),
          ],
        ),
        const SizedBox(height: 8),
        if (records.isEmpty)
          _EmptyBreedingCard(
            icon: Icons.schedule,
            title: l10n.noMiscarriagesYet,
            body: l10n.noMiscarriagesHint,
            buttonLabel: l10n.recordMiscarriage,
            onPressed: onRecord,
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final m in records) ...[
                    Text(
                      m.dateLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(
                      '${m.gestationDayLabel} · ${m.causeLabel}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: GhColors.textSecondary,
                      ),
                    ),
                    if (m.followUp != null)
                      Text(m.followUp!, style: const TextStyle(fontSize: 12)),
                    if (m != records.last) const Divider(height: 20),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _EmptyBreedingCard extends StatelessWidget {
  const _EmptyBreedingCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String body;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: GhColors.primaryLight.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: GhColors.primary),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              body,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: GhColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(onPressed: onPressed, child: Text(buttonLabel)),
          ],
        ),
      ),
    );
  }
}

class _AiRecordCard extends StatelessWidget {
  const _AiRecordCard({required this.record});

  final MockAiRecord record;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final statusColor =
        record.statusPositive ? GhColors.success : GhColors.warning;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: GhColors.primaryLight.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.vaccines,
                    size: 18,
                    color: GhColors.primary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.aiAttemptTitle(record.attemptNumber),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  record.dateLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    color: GhColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(99),
              ),
              child: Text(
                record.statusLabel,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: statusColor,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _DetailGrid(
              items: [
                (l10n.sireLabel, record.sire),
                (l10n.technicianLabel, record.technician),
                (l10n.semenBatchLabel, record.semenBatch),
                (l10n.resultDateLabel, record.resultDateLabel),
              ],
            ),
            if (record.statusNote != null) ...[
              const SizedBox(height: 8),
              Text(
                record.statusNote!,
                style: const TextStyle(
                  fontSize: 12,
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

class _DetailGrid extends StatelessWidget {
  const _DetailGrid({required this.items});

  final List<(String, String)> items;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: items
          .map(
            (e) => SizedBox(
              width: 140,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    e.$1,
                    style: GhTypography.labelXs.copyWith(
                      color: GhColors.textFaint,
                    ),
                  ),
                  Text(
                    e.$2,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
