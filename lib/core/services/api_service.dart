import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = "https://bemobilepos-production.up.railway.app/api/v1";

  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'username': username,
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
}
