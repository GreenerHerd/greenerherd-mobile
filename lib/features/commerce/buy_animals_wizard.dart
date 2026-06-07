import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/l10n/gen/app_localizations.dart';
import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/data_refresh.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/breed_reference.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/animal_mapper.dart';
import '../animals/add_group_sheet.dart';
import '../animals/add_group_wizard.dart';
import '../animals/animal_form_helpers.dart';
import '../animals/widgets/group_member_compact_row.dart';

const _ageRangeLabels = [
  '0-3m',
  '4-6m',
  '7-11m',
  '1-2yr',
  '2-3yr',
  '3-5yr',
  '5+yr',
];

/// 3-step purchase flow aligned with group onboarding (details → herd → animals).
Future<bool?> showBuyAnimalsWizard(BuildContext context, WidgetRef ref) async {
  final container = ProviderScope.containerOf(context);
  return Navigator.of(context).push<bool>(
    MaterialPageRoute(
      builder: (_) => UncontrolledProviderScope(
        container: container,
        child: const BuyAnimalsWizardScreen(),
      ),
    ),
  );
}

class BuyAnimalsWizardScreen extends ConsumerStatefulWidget {
  const BuyAnimalsWizardScreen({super.key});

  @override
  ConsumerState<BuyAnimalsWizardScreen> createState() =>
      _BuyAnimalsWizardScreenState();
}

class _BuyAnimalsWizardScreenState extends ConsumerState<BuyAnimalsWizardScreen> {
  static const _totalSteps = 3;

  var _step = 0;
  var _busy = false;

  final _supplierCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _countCtrl = TextEditingController(text: '10');

  DateTime _purchaseDate = DateTime.now();
  var _species = Species.cattle;
  var _sex = 'Female';
  var _ageRangeLabel = '1-2yr';

  List<BreedReference> _breeds = [];
  BreedReference? _selectedBreed;
  var _defaultAnimalPurpose = SpeciesPurpose.both;
  List<GroupMemberDraft> _members = [];

  @override
  void initState() {
    super.initState();
    _loadBreeds(_species);
  }

  Future<void> _loadBreeds(Species species) async {
    final breeds = [
      ...await ref.read(breedsForSpeciesProvider(species).future),
    ];
    breeds.sort(
        (a, b) => a.nameEn.toLowerCase().compareTo(b.nameEn.toLowerCase()));
    if (!mounted) return;
    setState(() {
      _breeds = breeds;
      _selectedBreed = breeds.isEmpty
          ? null
          : breeds.firstWhere(
              (b) => b.nameEn == 'Holstein',
              orElse: () => breeds.first,
            );
    });
  }

  @override
  void dispose() {
    _supplierCtrl.dispose();
    _priceCtrl.dispose();
    _weightCtrl.dispose();
    _countCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle(l10n)),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _busy ? null : () => Navigator.pop(context, false),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.wizardStepOf(_step + 1, _totalSteps),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: GhColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(value: (_step + 1) / _totalSteps),
              ],
            ),
          ),
          Expanded(child: _buildStep()),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_step > 0)
                  TextButton(
                    onPressed: _busy ? null : () => setState(() => _step -= 1),
                    child: const Text('Back'),
                  ),
                const Spacer(),
                FilledButton(
                  onPressed: _busy ? null : _onPrimary,
                  child: _busy
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_primaryLabel(l10n)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stepTitle(AppLocalizations l10n) {
    return switch (_step) {
      0 => l10n.purchaseWizardDetails,
      1 => l10n.purchaseWizardLivestock,
      _ => l10n.purchaseWizardAnimals,
    };
  }

  String _primaryLabel(AppLocalizations l10n) {
    if (_step < _totalSteps - 1) return l10n.continueButton;
    return l10n.finishPurchase;
  }

  Widget _buildStep() {
    return switch (_step) {
      0 => _buildPurchaseDetails(),
      1 => _buildLivestockProfile(),
      _ => _buildAnimalList(),
    };
  }

  Widget _buildPurchaseDetails() {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.purchaseDate),
            subtitle: Text(
              '${_purchaseDate.day}/${_purchaseDate.month}/${_purchaseDate.year}',
            ),
            trailing: const Icon(Icons.calendar_today_outlined),
            onTap: _pickPurchaseDate,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _supplierCtrl,
            decoration: InputDecoration(
              labelText: l10n.supplierSource,
              hintText: l10n.supplierHint,
            ),
            textCapitalization: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _priceCtrl,
            decoration: InputDecoration(labelText: l10n.purchasePrice),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _weightCtrl,
            decoration: InputDecoration(labelText: l10n.totalWeightKgOptional),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
        ],
      ),
    );
  }

  Widget _buildLivestockProfile() {
    final l10n = context.l10n;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DropdownButtonFormField<Species>(
            initialValue: _species,
            decoration: InputDecoration(labelText: l10n.species),
            items: Species.values
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(localizedSpecies(s, l10n)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() => _species = v);
                _loadBreeds(v);
              }
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _countCtrl,
            decoration: InputDecoration(labelText: l10n.numberOfAnimalsPurchased),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 12),
          if (_breeds.isEmpty)
            TextField(
              enabled: false,
              decoration: InputDecoration(
                labelText: l10n.breedForSpecies(localizedSpecies(_species, l10n)),
                hintText: 'Loading…',
              ),
            )
          else
            DropdownButtonFormField<BreedReference>(
              initialValue: _selectedBreed,
              decoration: InputDecoration(
                labelText: l10n.breedForSpecies(localizedSpecies(_species, l10n)),
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              ),
              items: _breeds
                  .map((b) => DropdownMenuItem(
                        value: b,
                        child: Text(b.nameEn),
                      ))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedBreed = v);
              },
            ),
          const SizedBox(height: 12),
          AnimalPurposeField(
            value: _defaultAnimalPurpose,
            l10n: l10n,
            onChanged: (p) => setState(() {
              _defaultAnimalPurpose = p;
              for (final m in _members) {
                m.productionPurpose = p;
              }
            }),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _sex,
            decoration: const InputDecoration(labelText: 'Sex'),
            items: const [
              DropdownMenuItem(value: 'Female', child: Text('Female')),
              DropdownMenuItem(value: 'Male', child: Text('Male')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => _sex = v);
            },
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _ageRangeLabel,
            decoration: InputDecoration(labelText: l10n.ageRange),
            items: _ageRangeLabels
                .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                .toList(),
            onChanged: (v) {
              if (v != null) setState(() => _ageRangeLabel = v);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimalList() {
    final l10n = context.l10n;
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 16),
      itemCount: _members.length,
      itemBuilder: (_, i) {
        final m = _members[i];
        return GroupMemberCompactRow(
          draft: m,
          species: _species,
          defaultSex: _sex,
          defaultBreed: m.breed,
          l10n: l10n,
          breeds: _breeds,
        );
      },
    );
  }

  Future<void> _pickPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _purchaseDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _purchaseDate = picked);
  }

  Future<void> _onPrimary() async {
    final l10n = context.l10n;

    if (_step == 0) {
      final supplier = _supplierCtrl.text.trim();
      final price = double.tryParse(_priceCtrl.text.trim());
      if (supplier.isEmpty || price == null || price <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.enterSupplierAndPrice)),
        );
        return;
      }
      setState(() => _step = 1);
      return;
    }

    if (_step == 1) {
      final count = int.tryParse(_countCtrl.text.trim());
      if (count == null || count < 1 || count > 500) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Enter a valid number of animals (1–500)')),
        );
        return;
      }
      _prepareMemberDrafts(count);
      setState(() => _step = 2);
      return;
    }

    await _finish();
  }

  void _prepareMemberDrafts(int count) {
    final supplier = _supplierCtrl.text
        .trim()
        .replaceAll(RegExp(r'[^A-Za-z0-9]'), '')
        .toUpperCase();
    final tagPrefix =
        supplier.length >= 3 ? supplier.substring(0, 3) : 'PUR';
    final breed = _selectedBreed?.nameEn ?? 'Holstein';
    final defaultAgeMonths = AnimalMapper.ageMidpointMonths(_ageRangeLabel);
    _members = List.generate(
      count,
      (i) => GroupMemberDraft(
        id: const Uuid().v4(),
        index: i,
        tag: '$tagPrefix-${(i + 1).toString().padLeft(3, '0')}',
        sex: _sex,
        breed: breed,
        ageMonths: defaultAgeMonths,
        productionPurpose: _defaultAnimalPurpose,
      ),
    );
  }

  Future<void> _finish() async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      final validation = ref.read(animalInputValidationProvider);
      final existingTags =
          (await ref.read(animalRepositoryProvider).listAnimals())
              .map((a) => a.tag)
              .toList();

      for (final m in _members) {
        final tagIssues = validation.validateTag(
          m.tag,
          existingTags: [
            ...existingTags,
            ..._members.where((x) => x.id != m.id).map((x) => x.tag),
          ],
        );
        if (tagIssues.isNotEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Animal ${m.index + 1}: ${tagIssues.first.message}',
                ),
              ),
            );
          }
          return;
        }
        if (m.weightKg != null) {
          final wIssues = validation.validateWeightKg(
            m.weightKg!,
            species: _species,
          );
          if (wIssues.isNotEmpty) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Animal ${m.index + 1}: ${wIssues.first.message}',
                  ),
                ),
              );
            }
            return;
          }
        }
      }

      final animalRepo = ref.read(animalRepositoryProvider);
      final animalIds = <String>[];
      final totalWeight = double.tryParse(_weightCtrl.text.trim());
      final breed = _selectedBreed?.nameEn ?? 'Holstein';

      for (final draft in _members) {
        final dob = draft.dob ??
            (draft.ageMonths != null
                ? DateTime.now().subtract(Duration(days: draft.ageMonths! * 30))
                : AnimalMapper.dobFromAgeLabel(_ageRangeLabel));
        final animal = Animal(
          id: draft.id,
          tag: draft.tag.trim(),
          name: '',
          species: _species,
          sex: draft.sex,
          breed: draft.breed.isEmpty ? breed : draft.breed,
          weightKg: draft.weightKg ?? 0,
          ageLabel: draft.ageMonths != null
              ? '${draft.ageMonths}m'
              : _ageRangeLabel,
          dob: dob,
          groupId: '',
          tags: draft.buildTags(_species),
          gestMonths: draft.pregnant ? draft.gestMonths : null,
          isTwin: draft.isTwin,
          weightIndicative: draft.weightKg == null,
          productionPurpose: draft.productionPurpose,
        );
        final created =
            await animalRepo.createAnimal(animal, purchased: true);
        animalIds.add(created.id);
      }

      final total = double.tryParse(_priceCtrl.text.trim()) ?? 0;
      final supplier = _supplierCtrl.text.trim();
      await ref.read(commerceRepositoryProvider).recordPurchase(
            PurchaseRecord(
              id: const Uuid().v4(),
              purchaseDate: _purchaseDate,
              totalAmount: total,
              animalIds: animalIds,
              supplierName: supplier,
              totalWeightKg: totalWeight,
              species: _species,
              sex: _sex,
              breed: breed,
              ageRangeLabel: _ageRangeLabel,
            ),
          );
      await ref.read(financeLedgerProvider).recordLivestockPurchase(
            totalAmount: total,
            animalCount: _members.length,
            note: l10n.summaryOriginPurchasedFrom(supplier),
          );
      refreshHerdDataProviders(ref);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.purchaseRecorded)),
        );
        Navigator.pop(context, true);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }
}
