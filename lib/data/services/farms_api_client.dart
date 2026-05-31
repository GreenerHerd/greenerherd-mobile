import 'package:dio/dio.dart';

import 'farms_remote_gateway.dart';

class FarmsApiException implements Exception {
  FarmsApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'FarmsApiException($statusCode): $message';
}

/// HTTP client for `gh-api-farms`.
class FarmsApiClient implements FarmsRemoteGateway {
  FarmsApiClient({
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

  void updateBearer(String bearerToken) {
    _dio.options.headers['authorization'] = 'Bearer $bearerToken';
  }

  @override
  Future<Map<String, dynamic>?> getFarm(String farmId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/farms/$farmId',
      );
      return _dataMap(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<({Map<String, dynamic> data, Map<String, dynamic>? meta})> createFarm(
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/farms',
      data: body,
    );
    return _dataWithMeta(response, expectedStatus: 201);
  }

  @override
  Future<Map<String, dynamic>> addSpecies(
    String farmId,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/species',
      data: body,
    );
    return _dataMap(response, expectedStatus: 201);
  }

  @override
  Future<Map<String, dynamic>> getOnboardingStatus(String farmId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/onboarding/status',
    );
    return _dataMap(response);
  }

  @override
  Future<Map<String, dynamic>> completeOnboarding(
    String farmId, {
    bool skipAnimals = false,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/onboarding/complete',
      data: {'skip_animals': skipAnimals},
    );
    return _dataMap(response);
  }

  Map<String, dynamic> _dataMap(
    Response<Map<String, dynamic>> response, {
    int expectedStatus = 200,
  }) {
    final status = response.statusCode ?? 0;
    if (status != expectedStatus) {
      throw FarmsApiException(
        _errorMessage(response.data) ?? 'Unexpected status $status',
        statusCode: status,
      );
    }
    final data = response.data?['data'];
    if (data is! Map) {
      throw FarmsApiException('Invalid response body');
    }
    return Map<String, dynamic>.from(data);
  }

  ({Map<String, dynamic> data, Map<String, dynamic>? meta}) _dataWithMeta(
    Response<Map<String, dynamic>> response, {
    int expectedStatus = 200,
  }) {
    final status = response.statusCode ?? 0;
    if (status != expectedStatus) {
      throw FarmsApiException(
        _errorMessage(response.data) ?? 'Unexpected status $status',
        statusCode: status,
      );
    }
    final data = response.data?['data'];
    if (data is! Map) {
      throw FarmsApiException('Invalid response body');
    }
    final meta = response.data?['meta'];
    return (
      data: Map<String, dynamic>.from(data),
      meta: meta is Map ? Map<String, dynamic>.from(meta) : null,
    );
  }

  String? _errorMessage(Map<String, dynamic>? body) {
    if (body == null) return null;
    final error = body['error'];
    if (error is Map && error['message'] is String) {
      return error['message'] as String;
    }
    return null;
  }
}
