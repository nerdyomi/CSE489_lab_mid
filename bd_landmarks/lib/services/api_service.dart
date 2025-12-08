import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/landmark.dart';

class ApiService {
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';

  Future<List<Landmark>> fetchLandmarks() async {
    try {
      final uri = Uri.parse(baseUrl);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      debugPrint('GET $uri => ${response.statusCode}');
      final previewLen = response.body.length > 200 ? 200 : response.body.length;
      debugPrint('Body (first $previewLen chars): ${response.body.substring(0, previewLen)}');

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);

        List<dynamic> items;
        if (decoded is List) {
          items = decoded;
        } else if (decoded is Map && decoded['data'] is List) {
          items = decoded['data'];
        } else {
          throw Exception('Unexpected response format');
        }

        return items
          .whereType<Map<String, dynamic>>()
          .map(Landmark.fromJson)
          .toList();
      } else {
        throw Exception('Failed to load landmarks: ${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Error fetching landmarks: request timed out');
    } on SocketException {
      throw Exception('Error fetching landmarks: network unavailable');
    } catch (e) {
      throw Exception('Error fetching landmarks: $e');
    }
  }

  Future<bool> createLandmark(Landmark landmark, File? imageFile) async {
    try {
      var request = http.MultipartRequest('POST', Uri.parse(baseUrl));

      request.fields['title'] = landmark.title;
      request.fields['lat'] = landmark.lat.toString();
      request.fields['lon'] = landmark.lon.toString();

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
          ),
        );
      }

      final response = await request.send();
      debugPrint('POST $baseUrl => ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        final body = await response.stream.bytesToString();
        throw Exception('${response.statusCode}: $body');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<bool> updateLandmark(Landmark landmark, File? imageFile) async {
    try {
      final uri = Uri.parse('$baseUrl?id=${landmark.id}');
      final request = http.MultipartRequest('PUT', uri);

      debugPrint('UPDATE - ID: ${landmark.id}, Title: ${landmark.title}, Lat: ${landmark.lat}, Lon: ${landmark.lon}');
      
      request.fields['id'] = landmark.id;
      request.fields['title'] = landmark.title;
      request.fields['lat'] = landmark.lat.toString();
      request.fields['lon'] = landmark.lon.toString();

      if (imageFile != null) {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }

      final response = await request.send();
      debugPrint('PUT $uri => ${response.statusCode}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        final body = await response.stream.bytesToString();
        debugPrint('PUT Error Response: $body');
        throw Exception('${response.statusCode}: $body');
      }
    } catch (e) {
      debugPrint('PUT Exception: $e');
      throw Exception('$e');
    }
  }

  Future<bool> deleteLandmark(String id) async {
    try {
      final uri = Uri.parse('$baseUrl?id=$id');
      final response = await http.delete(uri).timeout(const Duration(seconds: 10));

      debugPrint('DELETE $uri => ${response.statusCode}');
      debugPrint('Response: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      } else {
        throw Exception('${response.statusCode}');
      }
    } on TimeoutException {
      throw Exception('Request timed out');
    } on SocketException {
      throw Exception('Network error');
    } catch (e) {
      throw Exception('$e');
    }
  }
}
