import 'package:dio/dio.dart';

import 'group_nutrition_profile_resolver.dart';

class NutritionApiException implements Exception {
  NutritionApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'NutritionApiException($statusCode): $message';
}

/// HTTP client for `gh-api-nutrition` group nutrition endpoints.
class NutritionApiClient {
  NutritionApiClient({
    required String baseUrl,
    Dio? dio,
    Duration connectTimeout = const Duration(seconds: 5),
    Duration receiveTimeout = const Duration(seconds: 15),
  }) : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: connectTimeout,
                receiveTimeout: receiveTimeout,
                headers: const {'content-type': 'application/json'},
              ),
            );

  final Dio _dio;

  Future<Map<String, dynamic>> fetchGroupNutrition(
    String groupId,
    GroupNutritionProfile profile,
  ) async {
    final data = await _postData(
      '/api/v1/groups/$groupId/nutrition',
      profile.toRequestBody(),
    );
    return _normalizeNutritionPayload(data);
  }

  Future<Map<String, dynamic>> saveActiveFeedPlan(
    String groupId,
    GroupNutritionProfile profile,
  ) async {
    final data = await _postData(
      '/api/v1/groups/$groupId/nutrition/plans',
      profile.toRequestBody(),
      expectedStatus: 201,
    );
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> _postData(
    String path,
    Map<String, dynamic> body, {
    int expectedStatus = 200,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: body);
      final status = response.statusCode ?? 0;
      if (status != expectedStatus) {
        throw NutritionApiException(
          _errorMessage(response.data) ?? 'Unexpected status $status',
          statusCode: status,
        );
      }
      final envelope = response.data;
      if (envelope == null || envelope['data'] == null) {
        throw NutritionApiException('Empty response from nutrition API');
      }
      return Map<String, dynamic>.from(envelope['data'] as Map);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final message = _errorMessage(e.response?.data) ?? e.message ?? 'Network error';
      throw NutritionApiException(message, statusCode: status);
    }
  }

  String? _errorMessage(dynamic body) {
    if (body is! Map) return null;
    final error = body['error'];
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    return null;
  }

  Map<String, dynamic> _normalizeNutritionPayload(Map<String, dynamic> data) {
    final payload = Map<String, dynamic>.from(data);
    if (!payload.containsKey('feed_lines') && payload['recommendation'] is Map) {
      // API may return feed_lines at top level after POST; keep shape stable.
    }
    return payload;
  }
}
