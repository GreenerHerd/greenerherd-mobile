import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/theme/gh_colors.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../shared/io/local_image_io.dart';
import '../../shared/widgets/gh_app_bar.dart';
import 'animal_providers.dart';
import 'widgets/medicine_picker_sheet.dart';

/// Result returned when a treatment is saved.
class TreatmentDetails {
  const TreatmentDetails({
    required this.illnessNote,
    required this.treatment,
  });

  final String illnessNote;
  final AnimalTreatmentDetails treatment;
}

class RecordTreatmentScreen extends ConsumerStatefulWidget {
  const RecordTreatmentScreen({
    super.key,
    required this.animalId,
    this.initialIllnessNote,
    this.initialTreatment,
  });

  final String animalId;
  final String? initialIllnessNote;
  final AnimalTreatmentDetails? initialTreatment;

  @override
  ConsumerState<RecordTreatmentScreen> createState() =>
      _RecordTreatmentScreenState();
}

class _RecordTreatmentScreenState extends ConsumerState<RecordTreatmentScreen> {
  final _illness = TextEditingController();
  final _dosage = TextEditingController();
  final _administeredBy = TextEditingController();
  final _milkWithdrawal = TextEditingController();
  final _meatWithdrawal = TextEditingController();
  final _notes = TextEditingController();
  final _batch = TextEditingController();

  TreatmentFrequency _frequency = TreatmentFrequency.once;
  DateTime _administeredDate = DateTime.now();
  DateTime? _expiryDate;
  String? _photoPath;
  SelectedMedicine? _medicine;
  @override
  void initState() {
    super.initState();
    _illness.text = widget.initialIllnessNote ?? '';
    final t = widget.initialTreatment;
    if (t != null) {
      _dosage.text = t.dosage;
      _administeredBy.text = t.administeredBy;
      _milkWithdrawal.text =
          t.milkWithdrawalDays != null ? '${t.milkWithdrawalDays}' : '';
      _meatWithdrawal.text =
          t.meatWithdrawalDays != null ? '${t.meatWithdrawalDays}' : '';
      _notes.text = t.notes ?? '';
      _batch.text = t.batchNumber ?? '';
      _frequency = t.frequency;
      _administeredDate = t.administeredDate;
      _expiryDate = t.expiryDate;
      _photoPath = t.photoPath;
      _medicine = SelectedMedicine(
        name: t.medicineName,
        sourceLabel: t.sourceLabel ?? '',
        inventoryId: t.medicineInventoryId,
        catalogProductNumber: t.catalogProductNumber,
        suggestedDosage: t.dosage,
        milkWithdrawalDays: t.milkWithdrawalDays,
        meatWithdrawalDays: t.meatWithdrawalDays,
        inInventory: t.medicineInventoryId != null,
      );
    }
  }

  @override
  void dispose() {
    _illness.dispose();
    _dosage.dispose();
    _administeredBy.dispose();
    _milkWithdrawal.dispose();
    _meatWithdrawal.dispose();
    _notes.dispose();
    _batch.dispose();
    super.dispose();
  }

  String _formatDate(DateTime d) => DateFormat.yMd().format(d);

  String _frequencyLabel(TreatmentFrequency f, dynamic l10n) =>
      switch (f) {
        TreatmentFrequency.once => l10n.treatmentFrequencyOnce,
        TreatmentFrequency.daily => l10n.treatmentFrequencyDaily,
        TreatmentFrequency.weekly => l10n.treatmentFrequencyWeekly,
        TreatmentFrequency.monthly => l10n.treatmentFrequencyMonthly,
      };

  void _applyMedicine(SelectedMedicine med) {
    setState(() {
      _medicine = med;
      if (_dosage.text.trim().isEmpty &&
          med.suggestedDosage != null &&
          med.suggestedDosage!.isNotEmpty) {
        _dosage.text = med.suggestedDosage!;
      }
      if (med.milkWithdrawalDays != null && med.milkWithdrawalDays! > 0) {
        _milkWithdrawal.text = '${med.milkWithdrawalDays}';
      }
      if (med.meatWithdrawalDays != null && med.meatWithdrawalDays! > 0) {
        _meatWithdrawal.text = '${med.meatWithdrawalDays}';
      }
    });
  }

  Future<void> _pickMedicine(Species species) async {
    final picked = await showMedicinePickerSheet(context, species: species);
    if (picked != null) _applyMedicine(picked);
  }

  Future<void> _pickAdministeredDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _administeredDate,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _administeredDate = picked);
    }
  }

  Future<void> _pickExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expiryDate ?? DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  Future<void> _pickPhoto() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;
    final picked = await ImagePicker().pickImage(
      source: source,
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked != null) setState(() => _photoPath = picked.path);
  }

  void _save(Animal animal) {
    final l10n = context.l10n;
    final illness = _illness.text.trim();
    if (illness.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.illnessSymptomsLabel)),
      );
      return;
    }
    final med = _medicine;
    if (med == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.medicineRequired)),
      );
      return;
    }
    final dosage = _dosage.text.trim();
    if (dosage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.dosageRequired)),
      );
      return;
    }
    final by = _administeredBy.text.trim();
    if (by.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.administeredByRequired)),
      );
      return;
    }

    final day = DateTime(
      _administeredDate.year,
      _administeredDate.month,
      _administeredDate.day,
    );

    final treatment = AnimalTreatmentDetails(
      medicineName: med.name,
      medicineInventoryId: med.inventoryId,
      catalogProductNumber: med.catalogProductNumber,
      dosage: dosage,
      frequency: _frequency,
      administeredBy: by,
      administeredDate: day,
      milkWithdrawalDays: int.tryParse(_milkWithdrawal.text.trim()),
      meatWithdrawalDays: int.tryParse(_meatWithdrawal.text.trim()),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
      batchNumber: _batch.text.trim().isEmpty ? null : _batch.text.trim(),
      expiryDate: _expiryDate,
      photoPath: _photoPath,
      sourceLabel: med.sourceLabel,
    );

    context.pop(
      TreatmentDetails(
        illnessNote: illness,
        treatment: treatment,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final animalAsync = ref.watch(animalProvider(widget.animalId));

    return Scaffold(
      appBar: GhAppBar(title: l10n.recordTreatment),
      body: animalAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('$e')),
        data: (animal) {
          if (animal == null) {
            return const Center(child: Text('Animal not found'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                l10n.treatmentStepIllness,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _illness,
                decoration: InputDecoration(
                  labelText: l10n.illnessSymptomsLabel,
                  hintText: 'Symptoms, diagnosis, observations…',
                ),
                maxLines: 3,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 20),
              Text(
                l10n.treatmentStepMedicine,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => _pickMedicine(animal.species),
                icon: const Icon(Icons.medication_outlined),
                label: Text(
                  _medicine?.name ?? l10n.selectMedicineFirst,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (_medicine != null && !_medicine!.inInventory) ...[
                const SizedBox(height: 8),
                Material(
                  color: GhColors.warningLight,
                  borderRadius: BorderRadius.circular(8),
                  child: ListTile(
                    dense: true,
                    title: Text(
                      l10n.notInInventoryBanner,
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: TextButton(
                      onPressed: () async {
                        final added = await context
                            .push<bool>('/inventory/add-medicine');
                        if (added == true && mounted) {
                          await _pickMedicine(animal.species);
                        }
                      },
                      child: Text(l10n.addToInventory),
                    ),
                  ),
                ),
              ],
              if (_medicine != null) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.withdrawalPrefilledHint,
                  style: const TextStyle(
                    fontSize: 12,
                    color: GhColors.textSecondary,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              TextField(
                controller: _dosage,
                decoration: InputDecoration(
                  labelText: l10n.dosage,
                  hintText: 'e.g. 5 ml IM',
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TreatmentFrequency>(
                initialValue: _frequency,
                decoration: InputDecoration(
                  labelText: l10n.treatmentFrequencyLabel,
                ),
                items: [
                  for (final f in TreatmentFrequency.values)
                    DropdownMenuItem(
                      value: f,
                      child: Text(_frequencyLabel(f, l10n)),
                    ),
                ],
                onChanged: (v) {
                  if (v != null) setState(() => _frequency = v);
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _administeredBy,
                decoration: InputDecoration(
                  labelText: l10n.administeredByLabel,
                  hintText: l10n.administeredByHint,
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickAdministeredDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: l10n.administeredDateLabel,
                  ),
                  child: Row(
                    children: [
                      Expanded(child: Text(_formatDate(_administeredDate))),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _milkWithdrawal,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.milkWithdrawalDaysLabel,
                  hintText: l10n.milkWithdrawalHint,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _meatWithdrawal,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.meatWithdrawalDaysLabel,
                  hintText: l10n.meatWithdrawalHint,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notes,
                decoration: InputDecoration(labelText: l10n.treatmentNotesLabel),
                maxLines: 2,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _batch,
                decoration: InputDecoration(
                  labelText: l10n.batchNumberLabel,
                  hintText: l10n.batchNumberHint,
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: _pickExpiryDate,
                borderRadius: BorderRadius.circular(8),
                child: InputDecorator(
                  decoration: InputDecoration(labelText: l10n.expiryDateLabel),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _expiryDate == null
                              ? '—'
                              : _formatDate(_expiryDate!),
                        ),
                      ),
                      if (_expiryDate != null)
                        IconButton(
                          icon: const Icon(Icons.clear, size: 20),
                          onPressed: () => setState(() => _expiryDate = null),
                        ),
                      const Icon(Icons.chevron_right, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.addTreatmentPhoto,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              if (_photoPath == null)
                OutlinedButton.icon(
                  onPressed: _pickPhoto,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(l10n.addTreatmentPhotoHint),
                )
              else
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: buildLocalFileImage(
                        path: _photoPath!,
                        width: double.infinity,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton.filled(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          foregroundColor: Colors.white,
                        ),
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => setState(() => _photoPath = null),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => _save(animal),
                child: Text(l10n.save),
              ),
            ],
          );
        },
      ),
    );
  }
}
