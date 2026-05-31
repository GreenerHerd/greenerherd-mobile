import 'package:dio/dio.dart';

import 'auth_remote_gateway.dart';

class AuthApiException implements Exception {
  AuthApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'AuthApiException($statusCode): $message';
}

/// HTTP client for `gh-api-auth`.
class AuthApiClient implements AuthRemoteGateway {
  AuthApiClient({required String baseUrl, Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: baseUrl,
                connectTimeout: const Duration(seconds: 5),
                receiveTimeout: const Duration(seconds: 15),
                headers: {'content-type': 'application/json'},
              ),
            );

  final Dio _dio;

  @override
  Future<Map<String, dynamic>> login({required String email}) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/login',
      data: {'email': email, 'password': 'dev'},
    );
    return _dataMap(response);
  }

  @override
  Future<Map<String, dynamic>> refresh(String refreshToken) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    return _dataMap(response);
  }

  Map<String, dynamic> _dataMap(Response<Map<String, dynamic>> response) {
    final status = response.statusCode ?? 0;
    if (status != 200) {
      throw AuthApiException(
        _errorMessage(response.data) ?? 'Unexpected status $status',
        statusCode: status,
      );
    }
    final data = response.data?['data'];
    if (data is! Map) {
      throw AuthApiException('Invalid response body');
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
