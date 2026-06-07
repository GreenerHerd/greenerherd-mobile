import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n/l10n_extensions.dart';
import '../../core/providers/providers.dart';
import '../../core/theme/gh_colors.dart';
import '../../features/nutrition/nutrition_providers.dart';
import '../../data/models/inventory_models.dart';
import '../../data/models/enums.dart';
import '../../data/models/models.dart';
import '../../data/services/feed_catalog_loader.dart';
import '../../data/services/feed_eligibility_service.dart';
import '../../shared/widgets/gh_app_bar.dart';
import 'feed_eligibility_ui.dart';

class RecordFeedingScreen extends ConsumerStatefulWidget {
  const RecordFeedingScreen({super.key, this.initialGroupId});

  final String? initialGroupId;

  @override
  ConsumerState<RecordFeedingScreen> createState() => _RecordFeedingScreenState();
}

class _RecordFeedingScreenState extends ConsumerState<RecordFeedingScreen> {
  List<AnimalGroup> _groups = [];
  List<FeedInventoryItem> _feedItems = [];
  List<MealPlan> _meals = [];
  List<FeedCatalogProduct>? _catalog;
  List<MarketplaceFeedProduct> _marketplace = [];
  List<Animal> _groupAnimals = [];
  String? _groupId;
  String? _mealId;
  String? _feedItemId;
  bool _useMealPlan = true;
  final _weight = TextEditingController();
  final _headCount = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final groups = await ref.read(groupRepositoryProvider).listGroups();
    final meals = await ref.read(inventoryRepositoryProvider).listMeals();
    final feed = await ref.read(inventoryRepositoryProvider).listFeed();
    final catalog = await FeedCatalogLoader.loadStandardProducts();
    final marketplace = await FeedCatalogLoader.loadMarketplaceProducts();
    if (mounted) {
      setState(() {
        _groups = groups;
        _meals = meals;
        _feedItems = feed;
        _catalog = catalog;
        _marketplace = marketplace;
        _groupId = widget.initialGroupId ??
            (groups.isNotEmpty ? groups.first.id : null);
        _mealId = meals.isNotEmpty ? meals.first.id : null;
        _feedItemId = feed.isNotEmpty ? feed.first.id : null;
        _loading = false;
      });
      await _refreshGroupAnimals();
    }
  }

  Future<void> _refreshGroupAnimals() async {
    if (_groupId == null) return;
    final animals =
        await ref.read(animalRepositoryProvider).listAnimals(groupId: _groupId);
    if (!mounted) return;
    setState(() {
      _groupAnimals =
          animals.where((a) => a.status == AnimalStatus.active).toList();
      _syncEligibleSelections();
    });
  }

  void _syncEligibleSelections() {
    final meals = _eligibleMeals;
    if (_mealId != null && !meals.any((m) => m.id == _mealId)) {
      _mealId = meals.isNotEmpty ? meals.first.id : null;
    }
    final feed = _eligibleFeedItems;
    if (_feedItemId != null && !feed.any((f) => f.id == _feedItemId)) {
      _feedItemId = feed.isNotEmpty ? feed.first.id : null;
    }
  }

  List<MealPlan> get _eligibleMeals {
    if (_groupAnimals.isEmpty || _catalog == null) return _meals;
    return _meals.where((meal) {
      final check = FeedEligibilityService.evaluateMealForAnimals(
        meal: meal,
        feedItems: _feedItems,
        catalog: _catalog!,
        animals: _groupAnimals,
        marketplace: _marketplace,
      );
      return !check.hasImpacts;
    }).toList();
  }

  List<FeedInventoryItem> get _eligibleFeedItems {
    if (_groupAnimals.isEmpty || _catalog == null) return _feedItems;
    return _feedItems.where((item) {
      final check = FeedEligibilityService.checkInventoryItem(
        item,
        catalog: _catalog!,
        animals: _groupAnimals,
        marketplace: _marketplace,
      );
      return check == null;
    }).toList();
  }

  bool get _hasRestrictedMeals =>
      _meals.length > _eligibleMeals.length && _groupAnimals.isNotEmpty;

  bool get _hasRestrictedFeedItems =>
      _feedItems.length > _eligibleFeedItems.length &&
      _groupAnimals.isNotEmpty;

  Future<bool> _confirmEligibilityIfNeeded() async {
    if (_groupId == null || _catalog == null || _groupAnimals.isEmpty) {
      return true;
    }
    if (_useMealPlan && _mealId != null) {
      MealPlan? meal;
      for (final m in _meals) {
        if (m.id == _mealId) {
          meal = m;
          break;
        }
      }
      if (meal == null) return true;
      final check = FeedEligibilityService.evaluateMealForAnimals(
        meal: meal,
        feedItems: _feedItems,
        catalog: _catalog!,
        animals: _groupAnimals,
        marketplace: _marketplace,
      );
      if (check.hasImpacts) {
        return confirmMealEligibilityImpacts(context, check);
      }
      return true;
    }
    if (!_useMealPlan && _feedItemId != null) {
      FeedInventoryItem? item;
      for (final f in _feedItems) {
        if (f.id == _feedItemId) {
          item = f;
          break;
        }
      }
      if (item == null) return true;
      final check = FeedEligibilityService.checkInventoryItem(
        item,
        catalog: _catalog!,
        animals: _groupAnimals,
        marketplace: _marketplace,
      );
      if (check != null && check.hasImpacts) {
        return confirmFeedEligibilityImpacts(
          context,
          title: context.l10n.feedEligibilityWarningTitle,
          message: context.l10n.feedEligibilityAddProductWarning(item.name),
          impacts: check.impacts,
        );
      }
    }
    return true;
  }

  @override
  void dispose() {
    _weight.dispose();
    _headCount.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_groupId == null) return;
    final kg = double.tryParse(_weight.text);
    if (kg == null || kg <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter total weight fed (kg)')),
      );
      return;
    }
    final proceed = await _confirmEligibilityIfNeeded();
    if (!proceed) return;
    setState(() => _saving = true);
    try {
      final result = await ref.read(inventoryRepositoryProvider).recordFeeding(
            groupId: _groupId!,
            mealTypeId: _mealId,
            totalWeightKg: kg,
            headCount: int.tryParse(_headCount.text),
          );
      if (!mounted) return;
      if (result.lowStockItems.isNotEmpty) {
        final names = result.lowStockItems.map((f) => f.name).join(', ');
        await showDialog<void>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Low stock alert'),
            content: Text(
              'These items are below one week\'s supply: $names. '
              'A notification will be sent on the next scheduler run.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK'),
              ),
            ],
          ),
        );
      }
      if (mounted) {
        ref.invalidate(groupTodaysFeedProvider(_groupId!));
        context.pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: GhAppBar(title: l10n.updateFeeding),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DropdownButtonFormField<String>(
            initialValue: _groupId,
            decoration: const InputDecoration(labelText: 'Animal group'),
            items: _groups
                .map(
                  (g) => DropdownMenuItem(
                    value: g.id,
                    child: Text('${g.name} (${g.headCount} head)'),
                  ),
                )
                .toList(),
            onChanged: (v) async {
              setState(() => _groupId = v);
              await _refreshGroupAnimals();
            },
          ),
          if (_hasRestrictedMeals || _hasRestrictedFeedItems) ...[
            const SizedBox(height: 12),
            const FeedEligibilityRestrictedBanner(),
          ],
          const SizedBox(height: 16),
          const Text('Feed type',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
          const SizedBox(height: 8),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: true,
                label: Text('Meal plan'),
                icon: Icon(Icons.restaurant_menu, size: 16),
              ),
              ButtonSegment(
                value: false,
                label: Text('Individual feed'),
                icon: Icon(Icons.grass, size: 16),
              ),
            ],
            selected: {_useMealPlan},
            onSelectionChanged: (s) => setState(() => _useMealPlan = s.first),
          ),
          const SizedBox(height: 12),
          if (_useMealPlan) ...[
            if (_eligibleMeals.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GhColors.warningLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: GhColors.warning),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No meal plans created yet. Go to Inventory > Meals to create one.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _mealId,
                decoration: const InputDecoration(labelText: 'Meal plan'),
                items: _eligibleMeals
                    .map(
                      (m) => DropdownMenuItem(
                        value: m.id,
                        child: Text(m.name),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _mealId = v),
              ),
          ] else ...[
            if (_eligibleFeedItems.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: GhColors.warningLight.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, size: 18, color: GhColors.warning),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'No feed products in inventory. Add feed first.',
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ],
                ),
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _feedItemId,
                decoration: const InputDecoration(labelText: 'Feed product'),
                items: _eligibleFeedItems
                    .map(
                      (f) => DropdownMenuItem(
                        value: f.id,
                        child: Text(
                            '${f.name} (${f.quantityKg.toStringAsFixed(0)} kg available)'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _feedItemId = v),
              ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _weight,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              labelText: _useMealPlan
                  ? 'Total weight fed (kg)'
                  : 'Weight fed (kg)',
            ),
          ),
          TextField(
            controller: _headCount,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'Head count (optional)'),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _saving ? null : _submit,
            style: FilledButton.styleFrom(backgroundColor: GhColors.primary),
            child: Text(_saving ? l10n.updatingFeeding : l10n.updateAction),
          ),
        ],
      ),
    );
  }
}
