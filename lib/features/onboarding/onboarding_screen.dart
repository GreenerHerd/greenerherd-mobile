import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/app_config.dart';
import '../../core/l10n/gen/app_localizations.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import 'onboarding_animal_flows.dart';
import '../animals/add_group_wizard.dart';
import '../../shared/widgets/gh_logo.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  static const _stepCount = 4;
  int _step = 0;
  final _farmName = TextEditingController(text: 'Al-Falah Farm');
  String _currency = 'SAR';
  final Set<Species> _selectedSpecies = {};
  final Map<Species, SpeciesPurpose> _speciesPurpose = {};
  bool _busy = false;

  @override
  void dispose() {
    _farmName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final linked = ref.watch(authRepositoryProvider).linkedProvider;
    return Scaffold(
      appBar: AppBar(title: Text(_title(l10n))),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(value: (_step + 1) / _stepCount),
            const SizedBox(height: 24),
            if (linked != null) ...[
              _LinkedAccountChip(provider: linked),
              const SizedBox(height: 16),
            ],
            Expanded(child: _body(l10n)),
            if (_step < 3)
              FilledButton(
                onPressed: _busy ? null : () => _advance(context),
                child: _busy
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(l10n.continueButton),
              )
            else ...[
              FilledButton(
                onPressed: _busy
                    ? null
                    : () => _finish(context, mode: _AddMode.individual),
                child: Text(l10n.enterAnimalsIndividually),
              ),
              TextButton(
                onPressed: _busy
                    ? null
                    : () => _finish(context, mode: _AddMode.group),
                child: Text(l10n.enterAsGroup),
              ),
              TextButton(
                onPressed:
                    _busy ? null : () => _finish(context, skipAnimals: true),
                child: Text(l10n.skipForNow),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _title(AppLocalizations l10n) => switch (_step) {
        0 => l10n.onboardingFarmTitle,
        1 => l10n.onboardingSpeciesTitle,
        2 => l10n.primaryPurpose,
        _ => l10n.onboardingAnimalsTitle,
      };

  Widget _body(AppLocalizations l10n) {
    if (_step == 0) return _buildFarmStep(l10n);
    if (_step == 1) return _buildSpeciesStep(l10n);
    if (_step == 2) return _buildPurposeStep(l10n);
    return Text(l10n.chooseHowToAddAnimals);
  }

  Widget _buildFarmStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(child: GhLogo(size: 72, showRing: false)),
        const SizedBox(height: 20),
        TextField(
          controller: _farmName,
          decoration: InputDecoration(labelText: l10n.farmName),
        ),
        const SizedBox(height: 12),
        DropdownMenu<String>(
          initialSelection: _currency,
          label: Text(l10n.currency),
          dropdownMenuEntries: const [
            DropdownMenuEntry(value: 'SAR', label: 'SAR'),
            DropdownMenuEntry(value: 'AED', label: 'AED'),
          ],
          onSelected: (v) {
            if (v != null) setState(() => _currency = v);
          },
        ),
      ],
    );
  }

  Widget _buildSpeciesStep(AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(l10n.selectSpeciesOnFarm),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          children: [
            _SpeciesChip(
              label: l10n.cattle,
              selected: _selectedSpecies.contains(Species.cattle),
              onSelected: () => _toggleSpecies(Species.cattle),
            ),
            _SpeciesChip(
              label: l10n.goats,
              selected: _selectedSpecies.contains(Species.goat),
              onSelected: () => _toggleSpecies(Species.goat),
            ),
            _SpeciesChip(
              label: l10n.sheep,
              selected: _selectedSpecies.contains(Species.sheep),
              onSelected: () => _toggleSpecies(Species.sheep),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPurposeStep(AppLocalizations l10n) {
    final speciesList = _selectedSpecies.toList();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.setThePurposeForEachSpecies,
            style: const TextStyle(fontSize: 14, color: GhColors.textSecondary),
          ),
          const SizedBox(height: 16),
          for (final species in speciesList) ...[
            Text(
              l10n.purposeForSpecies(localizedSpecies(species, l10n)),
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
            const SizedBox(height: 8),
            SegmentedButton<SpeciesPurpose>(
              segments: [
                ButtonSegment(
                  value: SpeciesPurpose.milk,
                  label: Text(l10n.purposeMilk),
                ),
                ButtonSegment(
                  value: SpeciesPurpose.meat,
                  label: Text(l10n.purposeMeat),
                ),
                ButtonSegment(
                  value: SpeciesPurpose.both,
                  label: Text(l10n.purposeMilkMeat),
                ),
              ],
              selected: {_speciesPurpose[species] ?? SpeciesPurpose.both},
              onSelectionChanged: (s) {
                setState(() => _speciesPurpose[species] = s.first);
              },
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }

  void _toggleSpecies(Species species) {
    setState(() {
      if (_selectedSpecies.contains(species)) {
        _selectedSpecies.remove(species);
        _speciesPurpose.remove(species);
      } else {
        _selectedSpecies.add(species);
        _speciesPurpose.putIfAbsent(species, () => SpeciesPurpose.both);
      }
    });
  }

  Future<void> _advance(BuildContext context) async {
    if (_step == 1 && _selectedSpecies.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.selectAtLeastOneSpecies)),
      );
      return;
    }
    setState(() => _busy = true);
    try {
      final onboarding = ref.read(onboardingRepositoryProvider);
      if (_step == 0) {
        if (AppConfig.useFarmsApi) {
          await onboarding.createFarmProfile(
            name: _farmName.text.trim().isEmpty
                ? context.l10n.myFarm
                : _farmName.text.trim(),
            currency: _currency,
          );
          refreshAllAppData(ref);
        }
      } else if (_step == 2) {
        for (final species in _selectedSpecies) {
          await onboarding.addSpecies(
            species: species,
            purpose: _speciesPurpose[species] ?? SpeciesPurpose.both,
          );
        }
      }
      if (mounted) setState(() => _step++);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _finish(
    BuildContext context, {
    bool skipAnimals = false,
    _AddMode? mode,
  }) async {
    if (mode != null && _selectedSpecies.isEmpty) return;
    setState(() => _busy = true);
    try {
      if (mode == _AddMode.individual) {
        await runOnboardingAddAnimal(
          context,
          ref,
          species: _selectedSpecies.first,
        );
      } else if (mode == _AddMode.group) {
        await showAddGroupWizard(
          context,
          ref,
          initialSpecies: _selectedSpecies.first,
        );
      }
      final onboarding = ref.read(onboardingRepositoryProvider);
      await onboarding.completeOnboarding(skipAnimals: skipAnimals);
      await ref.read(authRepositoryProvider).setOnboardingComplete(true);
      refreshAllAppData(ref);
      if (context.mounted) context.go('/home');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}

enum _AddMode { individual, group }

class _SpeciesChip extends StatelessWidget {
  const _SpeciesChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}

class _LinkedAccountChip extends StatelessWidget {
  const _LinkedAccountChip({required this.provider});

  final AuthProvider provider;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (icon, label) = switch (provider) {
      AuthProvider.google => (Icons.g_mobiledata, l10n.providerGoogle),
      AuthProvider.apple => (Icons.apple, l10n.providerApple),
      AuthProvider.facebook => (Icons.facebook, l10n.providerFacebook),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: GhColors.primaryLight.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: GhColors.primary),
          const SizedBox(width: 8),
          Text(
            l10n.linkedToAccount(label),
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: GhColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
