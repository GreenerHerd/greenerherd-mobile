import 'package:dio/dio.dart';

/// Returns a [Dio] that resolves every request with [handler].
Dio dioWithHandler(
  Response<dynamic> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'http://test'));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handlerInterceptor) {
        try {
          final response = handler(options);
          handlerInterceptor.resolve(response);
        } catch (e) {
          handlerInterceptor.reject(
            DioException(requestOptions: options, error: e),
          );
        }
      },
    ),
  );
  return dio;
}

Response<Map<String, dynamic>> jsonResponse(
  RequestOptions options, {
  required Map<String, dynamic> body,
  int statusCode = 200,
}) {
  return Response(
    requestOptions: options,
    statusCode: statusCode,
    data: body,
  );
}
