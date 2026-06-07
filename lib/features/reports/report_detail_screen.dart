
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/services/report_generator_service.dart';
import 'report_export.dart' as report_export;
import '../../shared/widgets/gh_app_bar.dart';

final _reportGeneratorProvider = Provider<ReportGeneratorService>((ref) {
  return ReportGeneratorService(
    animals: ref.watch(animalRepositoryProvider),
    reports: ref.watch(reportRepositoryProvider),
  );
});

final _generatedReportProvider =
    FutureProvider.family<GeneratedReport, String>((ref, reportId) async {
  return ref.watch(_reportGeneratorProvider).generate(reportId);
});

class ReportDetailScreen extends ConsumerWidget {
  const ReportDetailScreen({super.key, required this.reportId});

  final String reportId;

  Future<void> _shareCsv(BuildContext context, GeneratedReport report) =>
      report_export.shareReportCsv(context, report);

  Future<void> _sharePdf(BuildContext context, GeneratedReport report) =>
      report_export.shareReportPdf(context, report);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reportAsync = ref.watch(_generatedReportProvider(reportId));

    return Scaffold(
      backgroundColor: GhColors.pageBackground,
      appBar: GhAppBar(
        title: reportAsync.maybeWhen(
          data: (r) => r.title,
          orElse: () => l10n.reports,
        ),
        subtitle: l10n.reportPreview,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: reportAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (report) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: GhColors.primaryLight.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.description, color: GhColors.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(report.title, style: GhTypography.h03),
                            Text(
                              '${report.rowCount} ${l10n.recordsIncluded.toLowerCase()}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: GhColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCell(
                        label: l10n.recordsIncluded,
                        value: '${report.rowCount}',
                        sub: l10n.inSelectedRange,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCell(
                        label: l10n.window,
                        value: l10n.last90Days,
                        sub: l10n.last90DaysRange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              IntrinsicHeight(
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCell(
                        label: l10n.speciesCovered,
                        value: l10n.speciesCoveredValue,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _SummaryCell(
                        label: l10n.generated,
                        value: l10n.generatedToday,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              _BulletCard(
                title: l10n.headline,
                items: [
                  '${report.rowCount} records summarised',
                  'Trends across 30 / 60 / 90 days',
                  'Outliers highlighted',
                ],
              ),
              const SizedBox(height: 12),
              _BulletCard(
                title: l10n.perGroup,
                items: const [
                  'Breakdown by group · species · purpose',
                  'Compared to farm-wide average',
                ],
              ),
              const SizedBox(height: 12),
              _BulletCard(
                title: l10n.auditableDetail,
                items: const [
                  'Source record IDs',
                  'Recorded-by attribution per row',
                ],
              ),
              const SizedBox(height: 12),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(l10n.exportReport, style: GhTypography.h03),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _shareCsv(context, report),
                              icon: const Icon(Icons.table_chart_outlined),
                              label: const Text('CSV'),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: () => _sharePdf(context, report),
                              icon: const Icon(Icons.picture_as_pdf_outlined),
                              label: Text(l10n.downloadPdf),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.signatureLineNote,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: GhColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SummaryCell extends StatelessWidget {
  const _SummaryCell({
    required this.label,
    required this.value,
    this.sub,
  });

  final String label;
  final String value;
  final String? sub;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label.toUpperCase(),
              style: GhTypography.labelXs.copyWith(color: GhColors.textFaint),
            ),
            const SizedBox(height: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
            if (sub != null) ...[
              const SizedBox(height: 4),
              Text(sub!, style: const TextStyle(fontSize: 11, color: GhColors.textFaint)),
            ],
          ],
        ),
      ),
    );
  }
}

class _BulletCard extends StatelessWidget {
  const _BulletCard({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: GhTypography.h03),
            const SizedBox(height: 10),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 6),
                      decoration: const BoxDecoration(
                        color: GhColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(child: Text(item, style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
