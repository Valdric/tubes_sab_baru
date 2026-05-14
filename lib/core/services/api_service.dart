import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://bemobilepos-production.up.railway.app/api/v1";

  // ==========================================
  // 1. FUNGSI KHUSUS: LOGIN
  // ==========================================
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
        return jsonDecode(response.body);
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
        headers: {
          'Accept': 'application/json',
          // Nanti tambahin 'Authorization': 'Bearer $token' di sini kalau API butuh token (Sanctum/JWT)
        },
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
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
        headers: {
          'Accept': 'application/json',
        },
      );
      return _handleResponse(response);
    } catch (e) {
      throw e.toString();
    }
  }
}