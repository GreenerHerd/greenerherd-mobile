import 'package:flutter/material.dart';
import '../../core/theme/gh_typography.dart';
import 'gh_card.dart';

class GhStat extends StatelessWidget {
  const GhStat({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.onTap,
    this.compact = false,
    this.dense = false,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;
  final bool compact;
  final bool dense;

  bool get _small => compact || dense;

  @override
  Widget build(BuildContext context) {
    return GhCard(
      onTap: onTap,
      padding: dense
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 8)
          : compact
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 10)
              : const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: GhTypography.muted.copyWith(
              fontSize: dense ? 10 : (_small ? 11 : 12),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: _small ? 4 : 8),
          Text(
            value,
            style: GhTypography.stat.copyWith(
              fontSize: dense ? 18 : (_small ? 20 : 24),
              height: _small ? 1.1 : 32 / 24,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}
