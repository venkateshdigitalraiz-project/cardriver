import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Interceptor for Dio that prints detailed request, response, and error logs to console.
class DioApiLogInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('🚀 [API REQUEST] ${options.method} ${options.uri}');
    if (options.headers.isNotEmpty) {
      debugPrint('📋 Headers: ${options.headers}');
    }
    if (options.queryParameters.isNotEmpty) {
      debugPrint('🔍 Query Params: ${options.queryParameters}');
    }
    if (options.data != null) {
      final bodyStr = options.data is Map || options.data is List
          ? jsonEncode(options.data)
          : options.data.toString();
      debugPrint('📦 Body: $bodyStr');
    }
    debugPrint('════════════════════════════════════════════════════════════════');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('📥 [API RESPONSE] ${response.requestOptions.method} ${response.requestOptions.uri}');
    debugPrint('📊 Status: ${response.statusCode}');
    if (response.data != null) {
      final bodyStr = response.data is Map || response.data is List
          ? jsonEncode(response.data)
          : response.data.toString();
      debugPrint('📄 Body: $bodyStr');
    }
    debugPrint('════════════════════════════════════════════════════════════════');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('❌ [API ERROR] ${err.requestOptions.method} ${err.requestOptions.uri}');
    debugPrint('⚠️ Error: ${err.message}');
    if (err.response != null) {
      debugPrint('📊 Status: ${err.response?.statusCode}');
      debugPrint('📄 Error Body: ${err.response?.data}');
    }
    debugPrint('════════════════════════════════════════════════════════════════');
    super.onError(err, handler);
  }
}

/// BaseClient wrapper for `http.Client` that logs every request and response.
class LoggingHttpClient extends http.BaseClient {
  final http.Client _inner;

  LoggingHttpClient([http.Client? inner]) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final startTime = DateTime.now();

    String bodyString = '';
    if (request is http.Request && request.body.isNotEmpty) {
      bodyString = request.body;
    }

    debugPrint('════════════════════════════════════════════════════════════════');
    debugPrint('🚀 [API REQUEST] ${request.method} ${request.url}');
    if (request.headers.isNotEmpty) {
      debugPrint('📋 Headers: ${request.headers}');
    }
    if (bodyString.isNotEmpty) {
      debugPrint('📦 Body: $bodyString');
    }
    debugPrint('════════════════════════════════════════════════════════════════');

    try {
      final streamedResponse = await _inner.send(request);
      final responseBytes = await streamedResponse.stream.toBytes();
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      final responseBody = utf8.decode(responseBytes, allowMalformed: true);

      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint('📥 [API RESPONSE] ${request.method} ${request.url} (${duration}ms)');
      debugPrint('📊 Status: ${streamedResponse.statusCode}');
      if (responseBody.isNotEmpty) {
        debugPrint('📄 Body: $responseBody');
      }
      debugPrint('════════════════════════════════════════════════════════════════');

      return http.StreamedResponse(
        http.ByteStream.fromBytes(responseBytes),
        streamedResponse.statusCode,
        contentLength: responseBytes.length,
        request: streamedResponse.request,
        headers: streamedResponse.headers,
        isRedirect: streamedResponse.isRedirect,
        persistentConnection: streamedResponse.persistentConnection,
        reasonPhrase: streamedResponse.reasonPhrase,
      );
    } catch (error) {
      final duration = DateTime.now().difference(startTime).inMilliseconds;
      debugPrint('════════════════════════════════════════════════════════════════');
      debugPrint('❌ [API ERROR] ${request.method} ${request.url} (${duration}ms): $error');
      debugPrint('════════════════════════════════════════════════════════════════');
      rethrow;
    }
  }
}

/// Helper factory to create a Dio instance preconfigured with logging.
Dio createLoggedDio([BaseOptions? options]) {
  final dio = Dio(
    options ??
        BaseOptions(
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
  );
  dio.interceptors.add(DioApiLogInterceptor());
  return dio;
}

