import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class HttpService {
  
  // Default headers
  Map<String, String> _defaultHeaders() {
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
    };
  }

  // GET Request dengan optional custom headers
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = "${ApiConfig.baseUrl}$cleanEndpoint";
    
    // Merge default headers dengan custom headers
    final finalHeaders = {..._defaultHeaders(), ...?headers};
    
    print('🌐 GET REQUEST: $url');
    print('📋 Headers: $finalHeaders');
    
    final res = await http.get(
      Uri.parse(url),
      headers: finalHeaders,
    );
    
    print('📡 Status Code: ${res.statusCode}');
    print('📦 Response Body: ${res.body}');
    
    return _handleResponse(res, url);
  }

  // POST Request dengan optional custom headers
  Future<Map<String, dynamic>> post(
    String endpoint, 
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = "${ApiConfig.baseUrl}$cleanEndpoint";
    
    final finalHeaders = {..._defaultHeaders(), ...?headers};
    
    print('🌐 POST REQUEST: $url');
    print('📋 Headers: $finalHeaders');
    print('📤 Request Body: ${jsonEncode(body)}');

    final response = await http.post(
      Uri.parse(url),
      headers: finalHeaders,
      body: jsonEncode(body),
    );

    print('📡 Status Code: ${response.statusCode}');
    print('📦 Response Body: ${response.body}');

    return _handleResponse(response, url);
  }

  // PUT Request dengan optional custom headers
  Future<Map<String, dynamic>> put(
    String endpoint, 
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = "${ApiConfig.baseUrl}$cleanEndpoint";
    
    final finalHeaders = {..._defaultHeaders(), ...?headers};
    
    print('🌐 PUT REQUEST: $url');
    print('📋 Headers: $finalHeaders');
    print('📤 Request Body: ${jsonEncode(body)}');

    final response = await http.put(
      Uri.parse(url),
      headers: finalHeaders,
      body: jsonEncode(body),
    );

    print('📡 Status Code: ${response.statusCode}');
    print('📦 Response Body: ${response.body}');

    return _handleResponse(response, url);
  }

  // PATCH Request dengan optional custom headers
  Future<Map<String, dynamic>> patch(
    String endpoint, 
    Map<String, dynamic> body, {
    Map<String, String>? headers,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = "${ApiConfig.baseUrl}$cleanEndpoint";
    
    final finalHeaders = {..._defaultHeaders(), ...?headers};
    
    print('🌐 PATCH REQUEST: $url');
    print('📋 Headers: $finalHeaders');
    print('📤 Request Body: ${jsonEncode(body)}');

    final response = await http.patch(
      Uri.parse(url),
      headers: finalHeaders,
      body: jsonEncode(body),
    );

    print('📡 Status Code: ${response.statusCode}');
    print('📦 Response Body: ${response.body}');

    return _handleResponse(response, url);
  }

  // DELETE Request dengan optional custom headers
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final cleanEndpoint = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final url = "${ApiConfig.baseUrl}$cleanEndpoint";
    
    final finalHeaders = {..._defaultHeaders(), ...?headers};
    
    print('🌐 DELETE REQUEST: $url');
    print('📋 Headers: $finalHeaders');

    final response = await http.delete(
      Uri.parse(url),
      headers: finalHeaders,
    );

    print('📡 Status Code: ${response.statusCode}');
    print('📦 Response Body: ${response.body}');

    return _handleResponse(response, url);
  }

  // Helper method untuk handle response
  Map<String, dynamic> _handleResponse(http.Response response, String url) {
    final body = response.body.trim();

    if (body.startsWith('<!DOCTYPE') || body.startsWith('<html')) {
      throw Exception(
        'API mengembalikan HTML (Status: ${response.statusCode}).\n'
        'Kemungkinan endpoint salah atau server error.\n'
        'URL: $url'
      );
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return jsonDecode(body);
      } catch (e) {
        throw Exception('Gagal parsing JSON response: $e\nBody: $body');
      }
    } else if (response.statusCode >= 400 && response.statusCode < 500) {
      try {
        final errorData = jsonDecode(body);
        throw Exception(
          'Client Error ${response.statusCode}: ${errorData['message'] ?? body}'
        );
      } catch (e) {
        throw Exception('Client Error ${response.statusCode}: $body');
      }
    } else if (response.statusCode >= 500) {
      throw Exception(
        'Server Error ${response.statusCode}: Server sedang bermasalah.\n$body'
      );
    } else {
      throw Exception('HTTP Error ${response.statusCode}: $body');
    }
  }
}