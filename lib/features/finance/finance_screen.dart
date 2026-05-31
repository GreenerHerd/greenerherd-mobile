import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/format/gh_number_format.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/providers/session_providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_app_bar.dart';
import '../../shared/widgets/gh_design_icon.dart';
import '../../shared/widgets/gh_design_icons.dart';
import '../../shared/widgets/species_icon.dart';
import 'add_finance_entry_sheet.dart';
import 'market_prices_provider.dart';

final financeSummaryProvider = FutureProvider<FinanceSummary>((ref) async {
  return ref.watch(financeRepositoryProvider).getSummary();
});

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (!ref.watch(canAccessFinanceProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/home');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final finance = ref.watch(financeSummaryProvider);
    final prices = ref.watch(marketPricesProvider);

    return Scaffold(
      backgroundColor: GhColors.pageBackground,
      appBar: GhAppBar(
        title: l10n.finance,
        actions: [
          IconButton(
            tooltip: l10n.milkSale,
            onPressed: () => context.push('/finance/record-milk-sale'),
            icon: const GhDesignIcon(assetPath: GhDesignIcons.bottle, size: 24),
          ),
          TextButton(
            onPressed: () => showAddFinanceEntrySheet(context, ref),
            child: Text(l10n.addNew),
          ),
        ],
      ),
      body: finance.when(
        data: (f) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _RollingChartCard(monthly: f.monthly),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.45,
              children: [
                _FinanceStatTile(
                  label: 'INCOME (3MO)',
                  value: GhNumberFormat.formatAmount(f.income3mo),
                  valueColor: GhColors.primary,
                ),
                _FinanceStatTile(
                  label: 'EXPENSE (3MO)',
                  value: GhNumberFormat.formatAmount(f.expense3mo),
                ),
                _FinanceStatTile(
                  label: 'NET',
                  value: GhNumberFormat.formatAmount(f.net3mo),
                  valueColor: GhColors.primary,
                ),
                _FinanceStatTile(
                  label: 'LIVESTOCK VALUE',
                  value: GhNumberFormat.formatAmount(f.livestockValue),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _RecentEntriesCard(entries: f.recent),
            const SizedBox(height: 16),
            prices.when(
              data: (p) => Column(
                children: [
                  _MarketPriceCard(
                    title: 'Milk price · per litre',
                    designIcon: GhDesignIcons.bottle,
                    prices: p.milkPerLitre,
                    trends: p.milkTrend,
                    decimals: 2,
                    onEdit: () => _editPrices(context, ref, p, focusMilk: true),
                  ),
                  const SizedBox(height: 12),
                  _MarketPriceCard(
                    title: 'Meat price · per kg',
                    designIcon: GhDesignIcons.sale,
                    prices: p.meatPerKg,
                    trends: p.meatTrend,
                    decimals: 0,
                    onEdit: () => _editPrices(context, ref, p, focusMilk: false),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
            const SizedBox(height: 80),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }

  Future<void> _editPrices(
    BuildContext context,
    WidgetRef ref,
    MarketPrices current, {
    required bool focusMilk,
  }) async {
    final ctrls = {
      for (final s in Species.values)
        s: TextEditingController(
          text: (focusMilk ? current.milkPerLitre[s] : current.meatPerKg[s])
              ?.toString(),
        ),
    };
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(focusMilk ? 'Edit milk prices' : 'Edit meat prices'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final s in Species.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: TextField(
                    controller: ctrls[s],
                    decoration: InputDecoration(
                      labelText: s.name,
                      prefixText: 'SAR ',
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (ok == true) {
      final updated = focusMilk
          ? MarketPrices(
              milkPerLitre: {
                for (final s in Species.values)
                  s: GhNumberFormat.parseAmount(ctrls[s]!.text) ??
                      current.milkPerLitre[s]!,
              },
              meatPerKg: current.meatPerKg,
              milkTrend: current.milkTrend,
              meatTrend: current.meatTrend,
            )
          : MarketPrices(
              milkPerLitre: current.milkPerLitre,
              meatPerKg: {
                for (final s in Species.values)
                  s: GhNumberFormat.parseAmount(ctrls[s]!.text) ??
                      current.meatPerKg[s]!,
              },
              milkTrend: current.milkTrend,
              meatTrend: current.meatTrend,
            );
      await ref.read(marketPricesProvider.notifier).updatePrices(updated);
    }
    for (final c in ctrls.values) {
      c.dispose();
    }
  }
}

class _RollingChartCard extends StatelessWidget {
  const _RollingChartCard({required this.monthly});

  final List<FinanceMonth> monthly;

  @override
  Widget build(BuildContext context) {
    final maxY = monthly
        .map((m) => m.income > m.expense ? m.income : m.expense)
        .fold<double>(0, (a, b) => a > b ? a : b);
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
          const Text(
            '3-month rolling',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.15,
                barGroups: [
                  for (var i = 0; i < monthly.length; i++)
                    BarChartGroupData(
                      x: i,
                      barRods: [
                        BarChartRodData(
                          toY: monthly[i].income,
                          color: GhColors.primary,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                        BarChartRodData(
                          toY: monthly[i].expense,
                          color: GhColors.secondaryLight,
                          width: 14,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _LegendDot(color: GhColors.primary, label: 'Income'),
              const SizedBox(width: 16),
              _LegendDot(color: GhColors.secondaryLight, label: 'Expense'),
            ],
          ),
        ],
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 11, color: GhColors.textSecondary)),
      ],
    );
  }
}

class _FinanceStatTile extends StatelessWidget {
  const _FinanceStatTile({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: GhColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: GhColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: GhColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: valueColor ?? GhColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentEntriesCard extends StatelessWidget {
  const _RecentEntriesCard({required this.entries});

  final List<FinanceEntry> entries;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: GhColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GhColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'Recent entries',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
          for (var i = 0; i < entries.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 64),
            _RecentEntryRow(entry: entries[i]),
          ],
        ],
      ),
    );
  }
}

class _RecentEntryRow extends StatelessWidget {
  const _RecentEntryRow({required this.entry});

  final FinanceEntry entry;

  @override
  Widget build(BuildContext context) {
    final income = entry.type == FinanceEntryType.income;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: income ? GhColors.primaryLight : GhColors.pageBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              income ? Icons.account_balance_wallet_outlined : Icons.arrow_forward,
              size: 18,
              color: income ? GhColors.primary : GhColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                Text(
                  '${entry.description} · ${entry.dateLabel}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: GhColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            GhNumberFormat.formatSignedAmount(
              entry.amount,
              income: income,
            ),
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: income ? GhColors.primary : GhColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MarketPriceCard extends StatelessWidget {
  const _MarketPriceCard({
    required this.title,
    required this.designIcon,
    required this.prices,
    required this.trends,
    required this.decimals,
    required this.onEdit,
  });

  final String title;
  final String designIcon;
  final Map<Species, double> prices;
  final Map<Species, double> trends;
  final int decimals;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GhColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: GhColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              GhDesignIcon(assetPath: designIcon, size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          for (final s in Species.values) ...[
            if (s != Species.values.first) const SizedBox(height: 10),
            _PriceRow(
              species: s,
              price: GhNumberFormat.formatAmount(prices[s]!, decimals: decimals),
              trend: trends[s]!,
            ),
          ],
        ],
      ),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({
    required this.species,
    required this.price,
    required this.trend,
  });

  final Species species;
  final String price;
  final double trend;

  @override
  Widget build(BuildContext context) {
    final down = trend < 0;
    return Row(
      children: [
        SpeciesIcon.avatar(species, size: 32),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            species.name[0].toUpperCase() + species.name.substring(1),
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        Text(price, style: const TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: down ? GhColors.errorLight : GhColors.successLight,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Text(
            GhNumberFormat.formatTrend(trend),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: down ? GhColors.error : GhColors.success,
            ),
          ),
        ),
      ],
    );
  }
}
