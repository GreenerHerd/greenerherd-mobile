import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_app_bar.dart';
import '../../shared/widgets/gh_chip.dart';

final _reportsProvider = FutureProvider<List<ReportDefinition>>((ref) async {
  return ref.watch(reportRepositoryProvider).listReports();
});

class ReportsListScreen extends ConsumerWidget {
  const ReportsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final reports = ref.watch(_reportsProvider);

    return Scaffold(
      backgroundColor: GhColors.pageBackground,
      appBar: GhAppBar(title: l10n.reports, subtitle: l10n.reportsSubtitle),
      body: reports.when(
        data: (list) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: GhColors.border),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(l10n.dateRange, style: GhTypography.h03),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: GhColors.primaryLight.withOpacity(0.45),
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(
                            l10n.last90Days,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: GhColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _DateField(label: l10n.fromDate, value: '07 Feb 2026'),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _DateField(label: l10n.toDate, value: '08 May 2026'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(l10n.availableReports, style: GhTypography.h03),
            const SizedBox(height: 8),
            Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: const BorderSide(color: GhColors.border),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < list.length; i++)
                    _ReportRow(
                      report: list[i],
                      isLast: i == list.length - 1,
                      onTap: () => context.push('/reports/${list[i].id}'),
                    ),
                ],
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  const _DateField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: GhColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: GhColors.pageBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: GhColors.border),
          ),
          child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }
}

class _ReportRow extends StatelessWidget {
  const _ReportRow({
    required this.report,
    required this.isLast,
    required this.onTap,
  });

  final ReportDefinition report;
  final bool isLast;
  final VoidCallback onTap;

  IconData _icon(String name) => switch (name) {
        'baby' => Icons.child_care,
        'wallet' => Icons.account_balance_wallet_outlined,
        'check' => Icons.check_circle_outline,
        'list' => Icons.list_alt,
        'syringe' => Icons.vaccines,
        _ => Icons.schedule,
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : const Border(bottom: BorderSide(color: GhColors.border)),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: GhColors.primaryLight.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_icon(report.iconName), size: 18, color: GhColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    report.description,
                    style: const TextStyle(fontSize: 12, color: GhColors.textSecondary),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  report.countLabel,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
                const Icon(Icons.chevron_right, size: 18, color: GhColors.textFaint),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
