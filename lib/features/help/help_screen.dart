import 'package:flutter/material.dart';
import '../../core/theme/gh_colors.dart';
import '../../shared/widgets/gh_app_bar.dart';
import '../../shared/widgets/gh_design_icon.dart';
import '../../shared/widgets/gh_design_icons.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const topics = [
      'Getting started',
      'Adding animals',
      'Nutrition & feed plans',
      'Breeding & calving',
      'Tasks & reminders',
      'Finance & reports',
      'Inventory',
      'Account & billing',
    ];
    return Scaffold(
      appBar: const GhAppBar(title: 'Help'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            color: GhColors.primaryLight.withValues(alpha: 0.4),
            child: ListTile(
              leading: const Icon(Icons.support_agent, color: GhColors.primary),
              title: const Text('Need help?', style: TextStyle(fontWeight: FontWeight.w700)),
              subtitle: const Text('Chat with our team'),
              trailing: OutlinedButton(onPressed: () {}, child: const Text('Chat')),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Video lessons', style: TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          ...topics.map(
            (t) => ListTile(
              leading: const GhDesignListIcon(
                assetPath: GhDesignIcons.videoLessons,
              ),
              title: Text(t),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {},
            ),
          ),
          const Divider(),
          const ListTile(
            title: Text('support@greenerherd.com'),
            subtitle: Text('Version 2.0.0'),
          ),
        ],
      ),
    );
  }
}
