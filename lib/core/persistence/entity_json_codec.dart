import 'dart:convert';

import '../../data/models/breeding_methods.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';

/// JSON serialization for Drift offline cache (Phase 5).
abstract final class EntityJsonCodec {
  static String encodeAnimal(Animal animal) =>
      jsonEncode(_animalToMap(animal));

  static Animal decodeAnimal(String json) =>
      _animalFromMap(jsonDecode(json) as Map<String, dynamic>);

  static String encodeGroup(AnimalGroup group) =>
      jsonEncode(_groupToMap(group));

  static AnimalGroup decodeGroup(String json) =>
      _groupFromMap(jsonDecode(json) as Map<String, dynamic>);

  static String encodeTask(TaskItem task) => jsonEncode(_taskToMap(task));

  static TaskItem decodeTask(String json) =>
      _taskFromMap(jsonDecode(json) as Map<String, dynamic>);

  static String encodeFarm(Farm farm) => jsonEncode(_farmToMap(farm));

  static Farm decodeFarm(String json) =>
      _farmFromMap(jsonDecode(json) as Map<String, dynamic>);

  static Map<String, dynamic> _animalToMap(Animal a) => {
        'id': a.id,
        'tag': a.tag,
        'name': a.name,
        'species': a.species.name,
        'sex': a.sex,
        'breed': a.breed,
        'weight_kg': a.weightKg,
        'age_label': a.ageLabel,
        'dob': a.dob?.toIso8601String(),
        'group_id': a.groupId,
        'tags': a.tags.map((t) => t.name).toList(),
        'milk_today_litres': a.milkTodayLitres,
        'withdrawal_days': a.withdrawalDays,
        'status': a.status.name,
        'weight_indicative': a.weightIndicative,
        'production_purpose': a.productionPurpose.name,
        'death_reason': a.deathReason,
        'cull_type': a.cullType,
        'cull_reason': a.cullReason,
        if (a.breedingMethod != null)
          'breeding_method': BreedingMethodCatalog.wire(a.breedingMethod!),
        if (a.gestMonths != null) 'gest_months': a.gestMonths,
        if (a.isTwin == true) 'is_twin': true,
        if (a.dueDate != null) 'due_date': a.dueDate!.toIso8601String(),
        if (a.prolificacy != null) 'prolificacy': a.prolificacy,
        if (a.isHeifer == true) 'is_heifer': true,
        if (a.illnessNote != null) 'illness_note': a.illnessNote,
        if (a.treatmentNote != null) 'treatment_note': a.treatmentNote,
      };

  static Animal _animalFromMap(Map<String, dynamic> m) {
    final tags = <AnimalTagType>[];
    for (final t in m['tags'] as List? ?? []) {
      final parsed = AnimalTagType.values.cast<AnimalTagType?>().firstWhere(
            (e) => e?.name == t.toString(),
            orElse: () => null,
          );
      if (parsed != null) tags.add(parsed);
    }
    return Animal(
      id: m['id'] as String,
      tag: m['tag'] as String? ?? '',
      name: m['name'] as String? ?? '',
      species: Species.values.byName(m['species'] as String? ?? 'cattle'),
      sex: m['sex'] as String? ?? 'Female',
      breed: m['breed'] as String? ?? '',
      weightKg: (m['weight_kg'] as num?)?.toDouble() ?? 0,
      ageLabel: m['age_label'] as String? ?? '—',
      dob: m['dob'] == null ? null : DateTime.tryParse(m['dob'] as String),
      groupId: m['group_id'] as String? ?? '',
      tags: tags,
      milkTodayLitres: (m['milk_today_litres'] as num?)?.toDouble(),
      withdrawalDays: m['withdrawal_days'] as int?,
      status: AnimalStatus.values.byName(m['status'] as String? ?? 'active'),
      weightIndicative: m['weight_indicative'] == true,
      productionPurpose: _speciesPurposeFromWire(
        m['production_purpose'] as String?,
      ),
      deathReason: m['death_reason'] as String?,
      cullType: m['cull_type'] as String?,
      cullReason: m['cull_reason'] as String?,
      breedingMethod: BreedingMethodCatalog.fromWire(
        m['breeding_method'] as String?,
      ),
      gestMonths: m['gest_months'] as int?,
      isTwin: m['is_twin'] == true ? true : null,
      dueDate: m['due_date'] == null
          ? null
          : DateTime.tryParse(m['due_date'] as String),
      prolificacy: m['prolificacy'] as int?,
      isHeifer: m['is_heifer'] == true ? true : null,
      illnessNote: m['illness_note'] as String?,
      treatmentNote: m['treatment_note'] as String?,
    );
  }

  static SpeciesPurpose _speciesPurposeFromWire(String? wire) {
    return switch (wire?.toLowerCase()) {
      'milk' => SpeciesPurpose.milk,
      'meat' => SpeciesPurpose.meat,
      _ => SpeciesPurpose.both,
    };
  }

  static Map<String, dynamic> _groupToMap(AnimalGroup g) => {
        'id': g.id,
        'name': g.name,
        'species': g.species.name,
        'purpose': g.purpose.name,
        'head_count': g.headCount,
        'manager_id': g.managerId,
        'description': g.description,
      };

  static AnimalGroup _groupFromMap(Map<String, dynamic> m) => AnimalGroup(
        id: m['id'] as String,
        name: m['name'] as String,
        species: Species.values.byName(m['species'] as String? ?? 'cattle'),
        purpose: GroupPurpose.values.byName(m['purpose'] as String? ?? 'maintenance'),
        headCount: m['head_count'] as int? ?? 0,
        managerId: m['manager_id'] as String?,
        description: m['description'] as String?,
      );

  static Map<String, dynamic> _taskToMap(TaskItem t) => {
        'id': t.id,
        'title': t.title,
        'subtitle': t.subtitle,
        'type': t.type.name,
        'when_label': t.whenLabel,
        'due_bucket': t.dueBucket,
        'overdue': t.overdue,
        'icon_name': t.iconName,
        'tone': t.tone.name,
        'animal_id': t.animalId,
        'group_id': t.groupId,
        'assignee_id': t.assigneeId,
        'action_kind': t.actionKind,
        'feed_product_name': t.feedProductName,
        'feed_purchase_source': t.feedPurchaseSource,
        'feed_catalog_product_number': t.feedCatalogProductNumber,
        'feed_marketplace_product_id': t.feedMarketplaceProductId,
        'feed_supplier_name': t.feedSupplierName,
        'feed_dry_matter_percent': t.feedDryMatterPercent,
        'feed_crude_protein_percent': t.feedCrudeProteinPercent,
        'feed_nem_mcal_per_kg': t.feedNemMcalPerKg,
      };

  static TaskItem _taskFromMap(Map<String, dynamic> m) => TaskItem(
        id: m['id'] as String,
        title: m['title'] as String,
        subtitle: m['subtitle'] as String? ?? '',
        type: TaskType.values.byName(m['type'] as String? ?? 'manual'),
        whenLabel: m['when_label'] as String? ?? '',
        dueBucket: m['due_bucket'] as String? ?? 'today',
        overdue: m['overdue'] == true,
        iconName: m['icon_name'] as String? ?? 'task',
        tone: TaskTone.values.byName(m['tone'] as String? ?? 'primary'),
        animalId: m['animal_id'] as String?,
        groupId: m['group_id'] as String?,
        assigneeId: m['assignee_id'] as String?,
        actionKind: m['action_kind'] as String?,
        feedProductName: m['feed_product_name'] as String?,
        feedPurchaseSource: m['feed_purchase_source'] as String?,
        feedCatalogProductNumber: m['feed_catalog_product_number'] as int?,
        feedMarketplaceProductId: m['feed_marketplace_product_id'] as String?,
        feedSupplierName: m['feed_supplier_name'] as String?,
        feedDryMatterPercent:
            (m['feed_dry_matter_percent'] as num?)?.toDouble(),
        feedCrudeProteinPercent:
            (m['feed_crude_protein_percent'] as num?)?.toDouble(),
        feedNemMcalPerKg: (m['feed_nem_mcal_per_kg'] as num?)?.toDouble(),
      );

  static Map<String, dynamic> _farmToMap(Farm f) => {
        'id': f.id,
        'name': f.name,
        'location': f.location,
        'currency': f.currency,
        'housing': f.housing.name,
        'owner_name': f.ownerName,
      };

  static Farm _farmFromMap(Map<String, dynamic> m) => Farm(
        id: m['id'] as String,
        name: m['name'] as String,
        location: m['location'] as String,
        currency: m['currency'] as String,
        housing: HousingType.values.byName(m['housing'] as String? ?? 'indoorFans'),
        ownerName: m['owner_name'] as String,
      );
}
