import 'package:dio/dio.dart';

import 'tasks_remote_gateway.dart';

class TasksApiException implements Exception {
  TasksApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'TasksApiException($statusCode): $message';
}

/// HTTP client for `gh-api-tasks`.
class TasksApiClient implements TasksRemoteGateway {
  TasksApiClient({
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
  Future<List<Map<String, dynamic>>> listTasks(
    String farmId, {
    String? status,
    String? groupId,
  }) async {
    final query = <String, dynamic>{};
    if (status != null) query['status'] = status;
    if (groupId != null) query['group_id'] = groupId;

    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/tasks',
      queryParameters: query.isEmpty ? null : query,
    );
    return _dataList(response);
  }

  @override
  Future<Map<String, dynamic>> completeTask(String taskId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/tasks/$taskId/complete',
    );
    return _dataMap(response, expectedStatus: 200);
  }

  @override
  Future<Map<String, dynamic>> dismissTask(String taskId) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/tasks/$taskId/dismiss',
    );
    return _dataMap(response, expectedStatus: 200);
  }

  List<Map<String, dynamic>> _dataList(Response<Map<String, dynamic>> response) {
    final status = response.statusCode ?? 0;
    if (status != 200) {
      throw TasksApiException(
        _errorMessage(response.data) ?? 'Unexpected status $status',
        statusCode: status,
      );
    }
    final envelope = response.data;
    final data = envelope?['data'];
    if (data is! List) {
      throw TasksApiException('Invalid tasks list response');
    }
    return data
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
  }

  Map<String, dynamic> _dataMap(
    Response<Map<String, dynamic>> response, {
    int expectedStatus = 200,
  }) {
    final status = response.statusCode ?? 0;
    if (status != expectedStatus) {
      throw TasksApiException(
        _errorMessage(response.data) ?? 'Unexpected status $status',
        statusCode: status,
      );
    }
    final data = response.data?['data'];
    if (data is! Map) {
      throw TasksApiException('Invalid task response');
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
