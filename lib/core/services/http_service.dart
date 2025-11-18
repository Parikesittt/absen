// lib/core/services/http_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../services/prefs_service.dart';

/// Custom exceptions (so caller can decide)
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  ApiException(this.message, {this.statusCode});
  @override
  String toString() => 'ApiException(status:$statusCode, message:$message)';
}

class UnauthorizedException extends ApiException {
  UnauthorizedException(String message) : super(message, statusCode: 401);
}

class NetworkException extends ApiException {
  NetworkException(String message) : super(message);
}

class ParseException extends ApiException {
  ParseException(String message) : super(message);
}

class HttpService {
  final Duration timeout = const Duration(seconds: 20);

  Map<String, String> _defaultHeaders() {
    return {"Content-Type": "application/json", "Accept": "application/json"};
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) => _call('GET', endpoint, null, headers: headers);

  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) => _call('POST', endpoint, body, headers: headers);

  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) => _call('PUT', endpoint, body, headers: headers);

  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) => _call('PATCH', endpoint, body, headers: headers);

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) => _call('DELETE', endpoint, null, headers: headers);

  Future<Map<String, dynamic>> _call(
    String method,
    String endpoint,
    Map<String, dynamic>? body, {
    Map<String, String>? headers,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = "${ApiConfig.baseUrl}$cleanEndpoint";

    // Merge headers and attach token if present
    final token = await PrefsService.getToken();
    final finalHeaders = {..._defaultHeaders(), ...?headers};
    if (token != null && token.isNotEmpty) {
      finalHeaders["Authorization"] = "Bearer $token";
    }

    // Logging
    debugPrint('🌐 $method REQUEST: $url');
    debugPrint('📋 Headers: $finalHeaders');
    if (body != null) debugPrint('📤 Request Body: ${jsonEncode(body)}');

    try {
      late http.Response res;

      final uri = Uri.parse(url);

      final future = () {
        switch (method) {
          case 'GET':
            return http.get(uri, headers: finalHeaders);
          case 'POST':
            return http.post(
              uri,
              headers: finalHeaders,
              body: jsonEncode(body),
            );
          case 'PUT':
            return http.put(uri, headers: finalHeaders, body: jsonEncode(body));
          case 'PATCH':
            return http.patch(
              uri,
              headers: finalHeaders,
              body: jsonEncode(body),
            );
          case 'DELETE':
            return http.delete(uri, headers: finalHeaders);
          default:
            throw ApiException('Unsupported HTTP method: $method');
        }
      }();

      res = await future.timeout(timeout);

      debugPrint('📡 Status Code: ${res.statusCode}');
      debugPrint('📦 Response Body: ${res.body}');

      return _handleResponse(res, url);
    } on SocketException catch (e) {
      // no internet
      debugPrint('Network error: $e');
      throw NetworkException('Tidak ada koneksi internet');
    } on TimeoutException catch (e) {
      debugPrint('Timeout: $e');
      throw NetworkException('Permintaan timeout. Coba lagi.');
    } on FormatException catch (e) {
      // JSON parsing or similar
      debugPrint('Format error: $e');
      throw ParseException('Gagal memproses response dari server.');
    } catch (e) {
      debugPrint('Unknown http error: $e');
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan: $e');
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response, String url) {
    final body = response.body.trim();

    // HTML error page
    if (body.startsWith('<!DOCTYPE') || body.startsWith('<html')) {
      throw ApiException(
        'API mengembalikan HTML (Status: ${response.statusCode}). URL: $url',
        statusCode: response.statusCode,
      );
    }

    // Success
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final jsonBody = jsonDecode(body);
        if (jsonBody is Map<String, dynamic>) return jsonBody;
        // sometimes API returns array at root or different shape
        return {'data': jsonBody};
      } catch (e) {
        throw ParseException('Gagal parsing JSON response: $e');
      }
    }

    // Unauthorized
    if (response.statusCode == 401) {
      String msg = 'Unauthorized';
      try {
        final parsed = jsonDecode(body);
        if (parsed is Map && parsed['message'] != null)
          msg = parsed['message'].toString();
      } catch (_) {}
      throw UnauthorizedException(msg);
    }

    // Client errors (400-499)
    if (response.statusCode >= 400 && response.statusCode < 500) {
      try {
        final errorData = jsonDecode(body);
        final message = (errorData is Map && errorData['message'] != null)
            ? errorData['message'].toString()
            : body;
        throw ApiException(message, statusCode: response.statusCode);
      } catch (e) {
        throw ApiException(
          'Client error ${response.statusCode}: $body',
          statusCode: response.statusCode,
        );
      }
    }

    // Server error
    throw ApiException(
      'Server Error ${response.statusCode}: $body',
      statusCode: response.statusCode,
    );
  }
}
