import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://bemobilepos-production.up.railway.app/api/v1";

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth-token', token);
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth-token');
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth-token');
  }

  Future<Map<String, String>> _getHeaders([bool isJson = true]) async {
    final token = await getToken();
    final Map<String, String> headers = {
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    if (isJson) headers['Content-Type'] = 'application/json';
    return headers;
  }

  dynamic _handleResponse(http.Response response) {
    final payload = jsonDecode(response.body);
    final bool success = payload['success'] ?? (response.statusCode >= 200 && response.statusCode < 300);

    if (!success) {
      if (response.statusCode == 401) {
        logout();
        throw 'Sesi berakhir, silakan login kembali.';
      }
      throw payload['message'] ?? 'Permintaan gagal (Error ${response.statusCode})';
    }

    return payload;
  }

  Future<dynamic> get(String endpoint, {Map<String, String>? params}) async {
    try {
      String url = baseUrl + endpoint;
      if (params != null && params.isNotEmpty) {
        final query = params.entries
            .where((e) => e.value.isNotEmpty)
            .map((e) => '${e.key}=${Uri.encodeComponent(e.value)}')
            .join('&');
        if (query.isNotEmpty) url += '?$query';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: await _getHeaders(false),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> patch(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(false),
      );
      return _handleResponse(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<dynamic> multipart(String endpoint, Map<String, String> fields, {
    String? filePath, 
    List<int>? fileBytes, 
    String? fileName, 
    String method = 'POST'
  }) async {
    try {
      final token = await getToken();
      final request = http.MultipartRequest(method, Uri.parse('$baseUrl$endpoint'));
      
      request.headers.addAll({
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      });

      request.fields.addAll(fields);

      if (fileBytes != null && fileName != null) {
        request.files.add(http.MultipartFile.fromBytes('image', fileBytes, filename: fileName));
      } else if (filePath != null) {
        request.files.add(await http.MultipartFile.fromPath('image', filePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      return _handleResponse(response);
    } catch (e) {
      throw e.toString();
    }
  }
}
