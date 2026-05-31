import 'package:dio/dio.dart';

import 'animals_remote_gateway.dart';

class AnimalsApiException implements Exception {
  AnimalsApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AnimalsApiException($statusCode): $message';
}

/// HTTP client for `gh-api-animals`.
class AnimalsApiClient implements AnimalsRemoteGateway {
  AnimalsApiClient({
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

  @override
  Future<List<Map<String, dynamic>>> listAnimals(
    String farmId, {
    String? species,
    String? groupId,
    String? tag,
  }) async {
    final query = <String, dynamic>{};
    if (species != null) query['species'] = species;
    if (groupId != null) query['group_id'] = groupId;
    if (tag != null) query['tag'] = tag;

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/animals',
      queryParameters: query.isEmpty ? null : query,
    );
    return _dataList(response);
  }

  @override
  Future<Map<String, dynamic>?> getAnimal(String farmId, String animalId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/api/v1/farms/$farmId/animals/$animalId',
      );
      return _dataMap(response);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) return null;
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> createAnimal(
    String farmId,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/animals',
      data: body,
    );
    return _dataMap(response, expectedStatus: 201);
  }

  @override
  Future<List<Map<String, dynamic>>> listGroups(String farmId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/groups',
    );
    return _dataList(response);
  }

  @override
  Future<Map<String, dynamic>> flagCull(String farmId, String animalId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/animals/$animalId/cull',
    );
    return _dataMap(response);
  }

  @override
  Future<Map<String, dynamic>> markSold(String farmId, String animalId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/animals/$animalId/sell',
    );
    return _dataMap(response);
  }

  @override
  Future<({Map<String, dynamic> group, List<Map<String, dynamic>> animals})>
      createGroupBulk(String farmId, Map<String, dynamic> body) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/groups/bulk',
      data: body,
    );
    final status = response.statusCode ?? 0;
    if (status != 201) {
      throw AnimalsApiException(
        _errorMessage(response.data) ?? 'Unexpected status $status',
        statusCode: status,
      );
    }
    final data = response.data?['data'];
    final meta = response.data?['meta'];
    if (data is! Map) {
      throw AnimalsApiException('Invalid bulk response');
    }
    final animals = meta is Map && meta['animals'] is List
        ? (meta['animals'] as List)
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList()
        : <Map<String, dynamic>>[];
    return (
      group: Map<String, dynamic>.from(data),
      animals: animals,
    );
  }

  List<Map<String, dynamic>> _dataList(Response<Map<String, dynamic>> response) {
    final status = response.statusCode ?? 0;
    if (status != 200) {
      throw AnimalsApiException(
        _errorMessage(response.data) ?? 'Unexpected status $status',
        statusCode: status,
      );
    }
    final data = response.data?['data'];
    if (data is! List) {
      throw AnimalsApiException('Invalid list response');
    }
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Map<String, dynamic> _dataMap(
    Response<Map<String, dynamic>> response, {
    int expectedStatus = 200,
  }) {
    final status = response.statusCode ?? 0;
    if (status != expectedStatus) {
      throw AnimalsApiException(
        _errorMessage(response.data) ?? 'Unexpected status $status',
        statusCode: status,
      );
    }
    final data = response.data?['data'];
    if (data is! Map) {
      throw AnimalsApiException('Invalid response body');
    }
    return Map<String, dynamic>.from(data);
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
