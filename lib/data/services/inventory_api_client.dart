import 'package:dio/dio.dart';

import '../models/inventory_models.dart';

class InventoryApiException implements Exception {
  InventoryApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'InventoryApiException($statusCode): $message';
}

class RecordFeedingResult {
  const RecordFeedingResult({
    required this.feedingId,
    required this.lowStockItems,
  });

  final String feedingId;
  final List<FeedInventoryItem> lowStockItems;
}

/// HTTP client for `gh-api-inventory`.
class InventoryApiClient {
  InventoryApiClient({
    required String baseUrl,
    required String bearerToken,
    Dio? dio,
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 15),
                headers: {
                  'content-type': 'application/json',
                  'authorization': 'Bearer $bearerToken',
                },
              ),
            );

  final Dio _dio;

  Future<List<FeedInventoryItem>> listFeed(String farmId) async {
    final data = await _getList('/api/v1/farms/$farmId/inventory/feed');
    return data
        .map((e) => FeedInventoryItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<MedicalInventoryItem>> listMedical(String farmId) async {
    final data = await _getList('/api/v1/farms/$farmId/inventory/medical');
    return data
        .map((e) =>
            MedicalInventoryItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<List<FeedInventoryItem>> listLowStock(String farmId) async {
    final envelope = await _get('/api/v1/farms/$farmId/inventory/low-stock');
    final feedItems = (envelope['feed_items'] as List? ?? []);
    return feedItems
        .map((e) => FeedInventoryItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<FeedInventoryItem> createFeed(
    String farmId,
    CreateFeedInventoryInput input,
  ) async {
    final data = await _post(
      '/api/v1/farms/$farmId/inventory/feed',
      input.toJson(),
      expectedStatus: 201,
    );
    return FeedInventoryItem.fromJson(data);
  }

  Future<MedicalInventoryItem> createMedical(
    String farmId,
    Map<String, dynamic> body,
  ) async {
    final data = await _post(
      '/api/v1/farms/$farmId/inventory/medical',
      body,
      expectedStatus: 201,
    );
    return MedicalInventoryItem.fromJson(data);
  }

  Future<List<MealPlan>> listMeals(String farmId) async {
    final data = await _getList('/api/v1/farms/$farmId/meals');
    return data
        .map((e) => MealPlan.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<MealPlan> createMeal(
    String farmId, {
    required String name,
    String? description,
  }) async {
    final data = await _post(
      '/api/v1/farms/$farmId/meals',
      {
        'name': name,
        if (description != null) 'description': description,
      },
      expectedStatus: 201,
    );
    return MealPlan.fromJson(data);
  }

  Future<SetMealIngredientsResult> setMealIngredients(
    String farmId,
    String mealId,
    List<MealIngredientInput> ingredients,
  ) async {
    final data = await _put(
      '/api/v1/farms/$farmId/meals/$mealId/ingredients',
      {
        'ingredients': ingredients
            .map(
              (i) => {
                'feed_inventory_item_id': i.feedInventoryItemId,
                'amount_kg': i.amountKg,
              },
            )
            .toList(),
      },
    );
    final meal = MealPlan.fromJson(data);
    return SetMealIngredientsResult(
      meal: meal,
      stockWarnings: meal.stockWarnings,
    );
  }

  Future<RecordFeedingResult> recordFeeding(
    String farmId, {
    required String groupId,
    String? mealTypeId,
    required double totalWeightKg,
    int? headCount,
    String? notes,
  }) async {
    final data = await _post(
      '/api/v1/farms/$farmId/feeding-records',
      {
        'group_id': groupId,
        if (mealTypeId != null) 'meal_type_id': mealTypeId,
        'total_weight_kg': totalWeightKg,
        if (headCount != null) 'head_count': headCount,
        if (notes != null) 'notes': notes,
      },
      expectedStatus: 201,
    );
    final low = (data['low_stock_items'] as List? ?? [])
        .map((e) => FeedInventoryItem.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
    final feeding = data['feeding'] as Map?;
    return RecordFeedingResult(
      feedingId: feeding?['id'] as String? ?? '',
      lowStockItems: low,
    );
  }

  Future<List<dynamic>> _getList(String path) async {
    final envelope = await _get(path);
    return envelope['data'] as List? ?? [];
  }

  Future<Map<String, dynamic>> _get(String path) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(path);
      return _unwrap(response);
    } on DioException catch (e) {
      throw InventoryApiException(
        _errorMessage(e.response?.data) ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> _post(
    String path,
    Map<String, dynamic> body, {
    int expectedStatus = 200,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final status = response.statusCode ?? 0;
      if (status != expectedStatus) {
        throw InventoryApiException(
          _errorMessage(response.data) ?? 'Unexpected status $status',
          statusCode: status,
        );
      }
      return _dataMap(response.data);
    } on DioException catch (e) {
      throw InventoryApiException(
        _errorMessage(e.response?.data) ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Future<Map<String, dynamic>> _put(
    String path,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.put<Map<String, dynamic>>(path, data: body);
      return _dataMap(response.data);
    } on DioException catch (e) {
      throw InventoryApiException(
        _errorMessage(e.response?.data) ?? e.message ?? 'Network error',
        statusCode: e.response?.statusCode,
      );
    }
  }

  Map<String, dynamic> _unwrap(Response<Map<String, dynamic>> response) {
    final status = response.statusCode ?? 0;
    if (status < 200 || status >= 300) {
      throw InventoryApiException(
        _errorMessage(response.data) ?? 'Unexpected status $status',
        statusCode: status,
      );
    }
    return Map<String, dynamic>.from(response.data ?? {});
  }

  Map<String, dynamic> _dataMap(Map<String, dynamic>? envelope) {
    if (envelope == null || envelope['data'] == null) {
      throw InventoryApiException('Empty response from inventory API');
    }
    final data = envelope['data'];
    if (data is Map) return Map<String, dynamic>.from(data);
    throw InventoryApiException('Unexpected inventory API payload');
  }

  String? _errorMessage(dynamic body) {
    if (body is! Map) return null;
    final error = body['error'];
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    return null;
  }
}
