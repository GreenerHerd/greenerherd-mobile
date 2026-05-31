import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/gh_app_bar.dart';
import '../../shared/widgets/gh_design_icon.dart';
import '../../shared/widgets/gh_design_icons.dart';
import 'animal_providers.dart';

class RecordBirthScreen extends ConsumerStatefulWidget {
  const RecordBirthScreen({super.key, required this.animalId});

  final String animalId;

  @override
  ConsumerState<RecordBirthScreen> createState() => _RecordBirthScreenState();
}

class _RecordBirthScreenState extends ConsumerState<RecordBirthScreen> {
  CalvingOutcome _outcome = CalvingOutcome.bornLive;
  bool _saving = false;

  Future<void> _save(Animal animal) async {
    setState(() => _saving = true);
    try {
      final lifecycle = ref.read(lifecycleServiceProvider);
      final updated = lifecycle.recordCalvingOutcome(animal, _outcome);
      await ref.read(animalRepositoryProvider).updateAnimal(updated);
      ref
        ..invalidate(animalProvider(widget.animalId));
      refreshHerdDataProviders(ref);
      if (mounted) {
        final l10n = context.l10n;
        final tab = _outcome == CalvingOutcome.bornLive ? 3 : 4;
        context.go('/animals/${animal.id}?tab=$tab');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _outcome == CalvingOutcome.bornLive
                  ? l10n.birthRecordedFor(animal.tag)
                  : l10n.stillbirthRecordedFor(animal.tag),
            ),
          ),
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
            title: l10n.recordBirth,
            subtitle: '#${animal.tag}',
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.pop(),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.howDidPregnancyEnd,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              const SizedBox(height: 12),
              RadioListTile<CalvingOutcome>(
                title: Row(
                  children: [
                    const GhDesignIcon(
                      assetPath: GhDesignIcons.calfFeeding,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.bornAlive),
                          Text(
                            l10n.bornAliveSubtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                value: CalvingOutcome.bornLive,
                groupValue: _outcome,
                activeColor: GhColors.primary,
                onChanged: _saving
                    ? null
                    : (v) => setState(() => _outcome = v!),
              ),
              RadioListTile<CalvingOutcome>(
                title: Row(
                  children: [
                    const GhAnimalDeathIcon(size: 24),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.stillborn),
                          Text(
                            l10n.stillbornSubtitle,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                value: CalvingOutcome.stillborn,
                groupValue: _outcome,
                activeColor: GhColors.primary,
                onChanged: _saving
                    ? null
                    : (v) => setState(() => _outcome = v!),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : () => _save(animal),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.saveBirthRecord),
              ),
            ],
          ),
        );
      },
    );
  }
}
