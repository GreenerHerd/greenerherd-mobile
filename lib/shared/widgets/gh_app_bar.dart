import 'package:flutter/material.dart';
import '../../core/theme/gh_typography.dart';

class GhAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GhAppBar({
    super.key,
    required this.title,
    this.subtitle,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      leading: leading,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: GhTypography.h03),
          if (subtitle != null)
            Text(subtitle!, style: GhTypography.muted.copyWith(fontSize: 12)),
        ],
      ),
      actions: actions,
    );
  }
}
