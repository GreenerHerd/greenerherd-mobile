import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/providers.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_app_bar.dart';

final _groupsListProvider = FutureProvider<List<AnimalGroup>>((ref) async {
  return ref.watch(groupRepositoryProvider).listGroups();
});

class GroupsListScreen extends ConsumerWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groups = ref.watch(_groupsListProvider);
    return Scaffold(
      appBar: const GhAppBar(title: 'Groups'),
      body: groups.when(
        data: (list) => ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          itemBuilder: (_, i) {
            final g = list[i];
            return Card(
              child: ListTile(
                title: Text(g.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text('${g.headCount} head · ${g.species.name}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/groups/${g.id}'),
              ),
            );
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
      ),
    );
  }
}
