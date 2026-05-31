import 'package:dio/dio.dart';

import 'finance_remote_gateway.dart';

class FinanceApiException implements Exception {
  FinanceApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => 'FinanceApiException($statusCode): $message';
}

class FinanceApiClient implements FinanceRemoteGateway {
  FinanceApiClient({
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
  Future<Map<String, dynamic>> getSummary(String farmId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/finance/summary',
    );
    return _dataMap(response);
  }

  @override
  Future<Map<String, dynamic>> addEntry(
    String farmId,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/finance/entries',
      data: body,
    );
    return _dataMap(response, expectedStatus: 201);
  }

  @override
  Future<List<Map<String, dynamic>>> listPurchases(String farmId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/finance/purchases',
    );
    return _dataList(response);
  }

  @override
  Future<Map<String, dynamic>> recordPurchase(
    String farmId,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/finance/purchases',
      data: body,
    );
    return _dataMap(response, expectedStatus: 201);
  }

  @override
  Future<List<Map<String, dynamic>>> listSales(String farmId) async {
    final response = await _dio.get<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/finance/sales',
    );
    return _dataList(response);
  }

  @override
  Future<Map<String, dynamic>> recordSale(
    String farmId,
    Map<String, dynamic> body,
  ) async {
    final response = await _dio.post<Map<String, dynamic>>(
      '/api/v1/farms/$farmId/finance/sales',
      data: body,
    );
    return _dataMap(response, expectedStatus: 201);
  }

  List<Map<String, dynamic>> _dataList(Response<Map<String, dynamic>> response) {
    final status = response.statusCode ?? 0;
    if (status != 200) {
      throw FinanceApiException(
        _errorMessage(response.data) ?? 'Unexpected status $status',
        statusCode: status,
      );
    }
    final data = response.data?['data'];
    if (data is! List) throw FinanceApiException('Invalid list response');
    return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Map<String, dynamic> _dataMap(
    Response<Map<String, dynamic>> response, {
    int expectedStatus = 200,
  }) {
    final status = response.statusCode ?? 0;
    if (status != expectedStatus) {
      throw FinanceApiException(
        _errorMessage(response.data) ?? 'Unexpected status $status',
        statusCode: status,
      );
    }
    final data = response.data?['data'];
    if (data is! Map) throw FinanceApiException('Invalid response body');
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
