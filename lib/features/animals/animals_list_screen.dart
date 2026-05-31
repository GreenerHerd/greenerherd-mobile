import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../shared/widgets/animal_list_tile.dart';
import '../../shared/widgets/gh_app_bar.dart';
import '../../shared/widgets/gh_chip.dart';
import '../../shared/widgets/species_icon.dart';
import '../shell/app_shell.dart';
import 'animal_providers.dart';
import 'widgets/herd_groups_strip.dart';

class AnimalsListScreen extends ConsumerStatefulWidget {
  const AnimalsListScreen({super.key});

  @override
  ConsumerState<AnimalsListScreen> createState() => _AnimalsListScreenState();
}

class _AnimalsListScreenState extends ConsumerState<AnimalsListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final animalsAsync = ref.watch(animalsListProvider);
    final groupsAsync = ref.watch(groupsListProvider);
    final speciesFilter = ref.watch(selectedSpeciesFilterProvider);
    final groupFilter = ref.watch(selectedGroupFilterProvider);
    final tagFilter = ref.watch(selectedAnimalTagFilterProvider);
    final dueSoon = ref.watch(dueSoonFilterProvider);

    return Scaffold(
      backgroundColor: GhColors.pageBackground,
      appBar: GhAppBar(
        title: l10n.animals,
        subtitle: animalsAsync.maybeWhen(
          data: (all) {
            final shown = _filterClient(
              all,
              speciesFilter,
              tagFilter,
              groupFilter,
              dueSoon: dueSoon,
            );
            return '${shown.length} of ${all.length}';
          },
          orElse: () => null,
        ),
        actions: [
          TextButton(
            onPressed: () => GhBottomSheetChooser.showAdd(context, ref),
            child: Text(l10n.addNew),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          refreshHerdDataProviders(ref);
          await Future.wait([
            ref.read(animalsListProvider.future),
            ref.read(groupsListProvider.future),
          ]);
        },
        child: animalsAsync.when(
          data: (allAnimals) => groupsAsync.when(
            data: (groupList) {
              final filtered = _filterClient(
                allAnimals,
                speciesFilter,
                tagFilter,
                groupFilter,
                dueSoon: dueSoon,
                query: _searchCtrl.text,
              );
              final speciesCounts = _speciesCounts(allAnimals);
              return ListView(
                padding: const EdgeInsets.only(bottom: 24),
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Search tag, name, breed…',
                        filled: true,
                        fillColor: GhColors.surface,
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 20,
                          color: GhColors.textFaint,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: GhColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(color: GhColors.border),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        GhChip(
                          label: '${l10n.allSpecies} ${speciesCounts[null]}',
                          selected: speciesFilter == null,
                          onTap: () => ref
                              .read(selectedSpeciesFilterProvider.notifier)
                              .state = null,
                        ),
                        GhChip(
                          label: '${l10n.cattle} ${speciesCounts[Species.cattle]}',
                          selected: speciesFilter == Species.cattle,
                          leading: SpeciesIcon.chipLeading(
                            Species.cattle,
                            selected: speciesFilter == Species.cattle,
                          ),
                          onTap: () => ref
                              .read(selectedSpeciesFilterProvider.notifier)
                              .state = Species.cattle,
                        ),
                        GhChip(
                          label: '${l10n.goats} ${speciesCounts[Species.goat]}',
                          selected: speciesFilter == Species.goat,
                          leading: SpeciesIcon.chipLeading(
                            Species.goat,
                            selected: speciesFilter == Species.goat,
                          ),
                          onTap: () => ref
                              .read(selectedSpeciesFilterProvider.notifier)
                              .state = Species.goat,
                        ),
                        GhChip(
                          label: '${l10n.sheep} ${speciesCounts[Species.sheep]}',
                          selected: speciesFilter == Species.sheep,
                          leading: SpeciesIcon.chipLeading(
                            Species.sheep,
                            selected: speciesFilter == Species.sheep,
                          ),
                          onTap: () => ref
                              .read(selectedSpeciesFilterProvider.notifier)
                              .state = Species.sheep,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: _tagChips(ref, tagFilter, dueSoon),
                    ),
                  ),
                  HerdGroupsStrip(groups: groupList, animals: allAnimals),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Row(
                      children: [
                        Text(
                          groupFilter != null
                              ? groupList
                                      .where((g) => g.id == groupFilter)
                                      .map((g) => g.name)
                                      .firstOrNull ??
                                  'Group'
                              : 'All animals',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${filtered.length} shown',
                          style: const TextStyle(
                            fontSize: 12,
                            color: GhColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: Center(
                        child: Text(
                          'No animals match.',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: GhColors.textSecondary,
                          ),
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        children: filtered
                            .map(
                              (a) => AnimalListTile(
                                animal: a,
                                onTap: () => context.push('/animals/${a.id}'),
                                onLactatingTagTap: a.tags.contains(AnimalTagType.lactating)
                                    ? () => context.push('/animals/${a.id}/record-milk')
                                    : null,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                ],
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
        ),
      ),
    );
  }

  List<Widget> _tagChips(
    WidgetRef ref,
    AnimalTagType? tagFilter,
    bool dueSoon,
  ) {
    return [
      GhChip(
        label: 'Any status',
        selected: tagFilter == null && !dueSoon,
        onTap: () {
          ref.read(selectedAnimalTagFilterProvider.notifier).state = null;
          ref.read(dueSoonFilterProvider.notifier).state = false;
        },
      ),
      GhChip(
        label: 'Due soon',
        selected: dueSoon,
        onTap: () {
          ref.read(dueSoonFilterProvider.notifier).state = !dueSoon;
          ref.read(selectedAnimalTagFilterProvider.notifier).state = null;
        },
      ),
      GhChip(
        label: 'Pregnant',
        selected: tagFilter == AnimalTagType.pregnant,
        onTap: () {
          ref.read(selectedAnimalTagFilterProvider.notifier).state =
              AnimalTagType.pregnant;
          ref.read(dueSoonFilterProvider.notifier).state = false;
        },
      ),
      GhChip(
        label: 'Lactating',
        selected: tagFilter == AnimalTagType.lactating,
        onTap: () {
          ref.read(selectedAnimalTagFilterProvider.notifier).state =
              AnimalTagType.lactating;
          ref.read(dueSoonFilterProvider.notifier).state = false;
        },
      ),
      GhChip(
        label: 'Ready to breed',
        selected: tagFilter == AnimalTagType.readyToBreed,
        onTap: () {
          ref.read(selectedAnimalTagFilterProvider.notifier).state =
              AnimalTagType.readyToBreed;
          ref.read(dueSoonFilterProvider.notifier).state = false;
        },
      ),
      GhChip(
        label: 'Sick',
        selected: tagFilter == AnimalTagType.sick,
        onTap: () {
          ref.read(selectedAnimalTagFilterProvider.notifier).state =
              AnimalTagType.sick;
          ref.read(dueSoonFilterProvider.notifier).state = false;
        },
      ),
      GhChip(
        label: 'Cull',
        selected: tagFilter == AnimalTagType.cull,
        onTap: () {
          ref.read(selectedAnimalTagFilterProvider.notifier).state =
              AnimalTagType.cull;
          ref.read(dueSoonFilterProvider.notifier).state = false;
        },
      ),
      GhChip(
        label: 'Weaning',
        selected: tagFilter == AnimalTagType.weaning,
        onTap: () {
          ref.read(selectedAnimalTagFilterProvider.notifier).state =
              AnimalTagType.weaning;
          ref.read(dueSoonFilterProvider.notifier).state = false;
        },
      ),
    ];
  }

  Map<Species?, int> _speciesCounts(List<Animal> animals) {
    final counts = <Species?, int>{null: animals.length};
    for (final s in Species.values) {
      counts[s] = animals.where((a) => a.species == s).length;
    }
    return counts;
  }

  List<Animal> _filterClient(
    List<Animal> all,
    Species? species,
    AnimalTagType? tag,
    String? groupId, {
    bool dueSoon = false,
    String query = '',
  }) {
    final q = query.trim().toLowerCase();
    return all.where((a) {
      if (species != null && a.species != species) return false;
      if (groupId != null && a.groupId != groupId) return false;
      if (dueSoon) {
        if (a.species != Species.cattle ||
            !a.tags.contains(AnimalTagType.pregnant)) {
          return false;
        }
      } else if (tag != null && !a.tags.contains(tag)) {
        return false;
      }
      if (q.isNotEmpty) {
        final hay = '${a.tag} ${a.name} ${a.breed}'.toLowerCase();
        if (!hay.contains(q)) return false;
      }
      return true;
    }).toList();
  }
}
