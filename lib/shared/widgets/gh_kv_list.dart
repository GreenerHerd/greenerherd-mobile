import 'package:flutter/material.dart';

import '../../core/theme/gh_colors.dart';
import '../../core/theme/gh_typography.dart';

class GhKvEntry {
  const GhKvEntry({
    required this.label,
    required this.value,
    this.subtitle,
    this.highlight = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final String? subtitle;
  final bool highlight;
  final bool isLast;
}

class GhKvListCard extends StatelessWidget {
  const GhKvListCard({
    super.key,
    this.title,
    required this.rows,
    this.padding = EdgeInsets.zero,
  });

  final String? title;
  final List<GhKvEntry> rows;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: GhColors.border),
      ),
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (title != null) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
                child: Text(title!, style: GhTypography.h03),
              ),
              const Divider(height: 1, color: GhColors.border),
            ],
            for (final row in rows) _KvRowWidget(entry: row),
          ],
        ),
      ),
    );
  }
}

class _KvRowWidget extends StatelessWidget {
  const _KvRowWidget({required this.entry});

  final GhKvEntry entry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: entry.isLast
            ? null
            : const Border(bottom: BorderSide(color: GhColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Text(
              entry.label,
              style: const TextStyle(fontSize: 13, color: GhColors.textSecondary),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  entry.value,
                  textAlign: TextAlign.end,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: entry.highlight ? GhColors.primary : GhColors.textPrimary,
                  ),
                ),
                if (entry.subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    entry.subtitle!,
                    textAlign: TextAlign.end,
                    style: const TextStyle(fontSize: 11, color: GhColors.textFaint),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
