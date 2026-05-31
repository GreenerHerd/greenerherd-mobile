import 'package:dio/dio.dart';

import 'people_remote_gateway.dart';

class PeopleApiException implements Exception {
  PeopleApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'PeopleApiException($statusCode): $message';
}

/// HTTP client for `gh-api-people`.
class PeopleApiClient implements PeopleRemoteGateway {
  PeopleApiClient({
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
  Future<List<Map<String, dynamic>>> listMembers(String farmId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/users',
    );
    return _dataList(response);
  }

  @override
  Future<({Map<String, dynamic> data, Map<String, dynamic>? meta})> inviteUser(
    String farmId,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/users/invite',
      data: body,
    );
    final status = response.statusCode ?? 0;
    if (status != 201) {
      throw PeopleApiException(
        _errorMessage(response.data) ?? 'Unexpected status $status',
        statusCode: status,
      );
    }
    final data = response.data?['data'];
    if (data is! Map) {
      throw PeopleApiException('Invalid invite response');
    }
    final meta = response.data?['meta'];
    return (
      data: Map<String, dynamic>.from(data),
      meta: meta is Map ? Map<String, dynamic>.from(meta) : null,
    );
  }

  List<Map<String, dynamic>> _dataList(Response<Map<String, dynamic>> response) {
    final status = response.statusCode ?? 0;
    if (status != 200) {
      throw PeopleApiException(
        _errorMessage(response.data) ?? 'Unexpected status $status',
        statusCode: status,
      );
    }
    final data = response.data?['data'];
    if (data is! List) {
      throw PeopleApiException('Invalid list response');
    }
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
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
