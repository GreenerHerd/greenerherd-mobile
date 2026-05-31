import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_app_bar.dart';
import 'animal_providers.dart';

class RecordMiscarriageScreen extends ConsumerStatefulWidget {
  const RecordMiscarriageScreen({super.key, required this.animalId});

  final String animalId;

  @override
  ConsumerState<RecordMiscarriageScreen> createState() =>
      _RecordMiscarriageScreenState();
}

class _RecordMiscarriageScreenState extends ConsumerState<RecordMiscarriageScreen> {
  bool _saving = false;

  Future<void> _save(Animal animal) async {
    setState(() => _saving = true);
    try {
      final lifecycle = ref.read(lifecycleServiceProvider);
      final updated =
          lifecycle.recordCalvingOutcome(animal, CalvingOutcome.miscarriage);
      await ref.read(animalRepositoryProvider).updateAnimal(updated);
      ref
        ..invalidate(animalProvider(widget.animalId))
        ..invalidate(animalsListProvider);
      if (mounted) {
        final l10n = context.l10n;
        context.go('/animals/${animal.id}?tab=4');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.miscarriageRecordedFor(animal.tag))),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final animalAsync = ref.watch(animalProvider(widget.animalId));

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
            title: l10n.recordMiscarriage,
            subtitle: '#${animal.tag}',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: GhColors.warningLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: GhColors.warning),
                  ),
                  child: Text(
                    l10n.miscarriageConfirmBody,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: _saving ? null : () => _save(animal),
                  style: FilledButton.styleFrom(
                    backgroundColor: GhColors.warning,
                  ),
                  child: _saving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.confirmMiscarriage),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: _saving ? null : () => context.pop(),
                  child: Text(l10n.cancel),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
