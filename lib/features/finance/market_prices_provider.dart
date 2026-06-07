import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/enums.dart';

class MarketPrices {
  const MarketPrices({
    required this.milkPerLitre,
    required this.meatPerKg,
    required this.milkTrend,
    required this.meatTrend,
  });

  final Map<Species, double> milkPerLitre;
  final Map<Species, double> meatPerKg;
  final Map<Species, double> milkTrend;
  final Map<Species, double> meatTrend;

  static MarketPrices defaults = const MarketPrices(
    milkPerLitre: {
      Species.cattle: 4.50,
      Species.goat: 6.00,
      Species.sheep: 5.20,
    },
    meatPerKg: {
      Species.cattle: 38,
      Species.goat: 52,
      Species.sheep: 46,
    },
    milkTrend: {
      Species.cattle: 0.10,
      Species.goat: -0.20,
      Species.sheep: 0,
    },
    meatTrend: {
      Species.cattle: 1.10,
      Species.goat: -0.40,
      Species.sheep: 0,
    },
  );
}

final marketPricesProvider =
    AsyncNotifierProvider<MarketPricesNotifier, MarketPrices>(
  MarketPricesNotifier.new,
);

class MarketPricesNotifier extends AsyncNotifier<MarketPrices> {
  static const _key = 'gh_market_prices_v1';

  @override
  Future<MarketPrices> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return MarketPrices.defaults;
    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      return _fromJson(map);
    } catch (_) {
      return MarketPrices.defaults;
    }
  }

  Future<void> updatePrices(MarketPrices prices) async {
    state = AsyncData(prices);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(_toJson(prices)));
  }

  MarketPrices _fromJson(Map<String, dynamic> map) {
    final d = MarketPrices.defaults;
    double speciesVal(Map<String, dynamic>? m, String k, double fallback) {
      if (m == null) return fallback;
      return (m[k] as num?)?.toDouble() ?? fallback;
    }

    Map<Species, double> readMap(
      String key,
      Map<Species, double> fallback,
    ) {
      final m = map[key] as Map<String, dynamic>?;
      if (m == null) return fallback;
      return {
        for (final s in Species.values)
          s: speciesVal(m, s.name, fallback[s]!),
      };
    }

    return MarketPrices(
      milkPerLitre: readMap('milk', d.milkPerLitre),
      meatPerKg: readMap('meat', d.meatPerKg),
      milkTrend: readMap('milkTrend', d.milkTrend),
      meatTrend: readMap('meatTrend', d.meatTrend),
    );
  }

  Map<String, dynamic> _toJson(MarketPrices p) => {
        'milk': {for (final s in Species.values) s.name: p.milkPerLitre[s]},
        'meat': {for (final s in Species.values) s.name: p.meatPerKg[s]},
        'milkTrend': {for (final s in Species.values) s.name: p.milkTrend[s]},
        'meatTrend': {for (final s in Species.values) s.name: p.meatTrend[s]},
      };
}
