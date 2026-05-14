import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://bemobilepos-production.up.railway.app/api/v1";
  static String? _token;

  // Set token after login
  static void setToken(String token) => _token = token;
  static String? get token => _token;

  // Helper for common headers
  Map<String, String> _getHeaders([bool isJson = true]) {
    final Map<String, String> headers = {
      'Accept': 'application/json',
    };
    if (isJson) headers['Content-Type'] = 'application/json';
    if (_token != null) headers['Authorization'] = 'Bearer $_token';
    return headers;
  }
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username, // Pakai username sesuai API lu
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['data'] != null && data['data']['token'] != null) {
          _token = data['data']['token'];
        }
        return data;
      } else if (response.statusCode == 401) {
        throw 'Username atau Password salah!';
      } else if (response.statusCode == 422) {
        throw 'Format data tidak valid (422)';
      } else {
        throw 'Gagal terhubung ke server (${response.statusCode})';
      }
    } catch (e) {
      throw e.toString();
    }
  }

  // ==========================================
  // 2. FUNGSI UMUM: CRUD (Bisa dipakai di semua menu)
  // ==========================================

  // Helper: Fungsi internal untuk handle response CRUD biar kodingan gak berulang
  dynamic _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    } else {
      // Coba tangkap pesan error dari backend kalau ada
      String errorMessage = 'API Error (${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body);
        if (errorData['message'] != null) {
          errorMessage = errorData['message'];
        }
      } catch (_) {}
      throw errorMessage;
    }
  }

  // READ (GET)
  Future<dynamic> get(String endpoint) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(false),
      );
      return _handleResponse(response);
    } catch (e) {
      throw e.toString();
    }
  }

  // CREATE (POST)
  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw e.toString();
    }
  }

  // UPDATE (PUT)
  Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw e.toString();
    }
  }

  // DELETE
  Future<dynamic> delete(String endpoint) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: _getHeaders(false),
      );
      return _handleResponse(response);
    } catch (e) {
      throw e.toString();
    }
  }
}