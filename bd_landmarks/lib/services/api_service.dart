import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/landmark.dart';

class ApiService {
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

  Future<List<Landmark>> fetchLandmarks() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Landmark.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load landmarks: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching landmarks: $e');
    }
  }

  Future<bool> createLandmark(Landmark landmark, File imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      request.fields['title'] = landmark.title;
      request.fields['lat'] = landmark.lat.toString();
      request.fields['lon'] = landmark.lon.toString();

      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
        ),
      );

      final response = await request.send();

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        throw Exception('Failed to create landmark: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating landmark: $e');
    }
  }
}
