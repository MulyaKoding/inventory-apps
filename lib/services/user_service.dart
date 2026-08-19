import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class UserService {
  // Ganti dengan base URL API kamu
  static const String baseUrl = 'https://inventory-usr.vercel.app';

  /// Upload foto ke Cloudinary via API, return URL foto
  Future<String> uploadPhoto(File imageFile) async {
    final uri = Uri.parse('$baseUrl/api/user/upload-photo');
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('file', imageFile.path),
    );

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);
    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal upload foto');
    }

    return data['url'] as String;
  }

  /// Update profil (nama, email, dan/atau foto)
  Future<Map<String, dynamic>> updateProfile({
    required String userId,
    String? name,
    String? email,
    String? phone,
    String? urlPhotoUser,
  }) async {
    final uri = Uri.parse('$baseUrl/api/user/update-profile');
    final response = await http.patch(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'userId': userId,
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (urlPhotoUser != null) 'urlPhotoUser': urlPhotoUser,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200 || data['success'] != true) {
      throw Exception(data['message'] ?? 'Gagal update profil');
    }

    return data['data'] as Map<String, dynamic>;
  }
}
