import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../config.dart';

class ApiException implements Exception {
  const ApiException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({FlutterSecureStorage? secureStorage, Dio? dio})
    : secureStorage = secureStorage ?? const FlutterSecureStorage(),
      dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: baseUrl,
              headers: const {'Accept': 'application/json'},
            ),
          ) {
    this.dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await this.secureStorage.read(key: _tokenKey);
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            final token = await this.secureStorage.read(key: _tokenKey);
            await this.secureStorage.delete(key: _tokenKey);
            if (token != null && token.isNotEmpty) {
              await onUnauthorized?.call();
            }
          }
          handler.next(error);
        },
      ),
    );
  }

  static const String _tokenKey = 'auth_token';

  final FlutterSecureStorage secureStorage;
  final Dio dio;
  Future<void> Function()? onUnauthorized;

  static ApiException exceptionFrom(Object error) {
    if (error is DioException) {
      var data = error.response?.data;
      if (data is List<int>) {
        try {
          data = jsonDecode(utf8.decode(data));
        } on FormatException {
          data = null;
        }
      } else if (data is String) {
        try {
          data = jsonDecode(data);
        } on FormatException {
          data = null;
        }
      }
      if (data is Map && data['message'] is String) {
        return ApiException(data['message'] as String);
      }
      if (error.message != null) return ApiException(error.message!);
    }
    if (error is ApiException) return error;
    return const ApiException('Terjadi kesalahan saat menghubungi server');
  }
}
