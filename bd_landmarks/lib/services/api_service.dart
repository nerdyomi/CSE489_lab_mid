import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import '../models/landmark.dart';

class ApiService {
  static const String baseUrl = 'https://labs.anontech.info/cse489/t3/api.php';
  late final Dio _dio;

  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      validateStatus: (status) {
        return status != null && status < 500;
      },
    ));
    
    // Add interceptor for debugging
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: false,
      responseBody: true,
      error: true,
      logPrint: (obj) => debugPrint(obj.toString()),
    ));
  }

  Future<List<Landmark>> fetchLandmarks() async {
    try {
      final response = await _dio.get(baseUrl);

      debugPrint('GET $baseUrl => ${response.statusCode}');
      final previewLen = response.data.toString().length > 200 ? 200 : response.data.toString().length;
      debugPrint('Body (first $previewLen chars): ${response.data.toString().substring(0, previewLen)}');

      if (response.statusCode == 200) {
        final decoded = response.data;

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
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Error fetching landmarks: request timed out');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Error fetching landmarks: network unavailable');
      }
      throw Exception('Error fetching landmarks: ${e.message}');
    } catch (e) {
      throw Exception('Error fetching landmarks: $e');
    }
  }

  Future<bool> createLandmark(Landmark landmark, File? imageFile) async {
    try {
      final formData = FormData.fromMap({
        'title': landmark.title,
        'lat': landmark.lat.toString(),
        'lon': landmark.lon.toString(),
        if (imageFile != null)
          'image': await MultipartFile.fromFile(imageFile.path, filename: 'image.jpg'),
      });

      final response = await _dio.post(baseUrl, data: formData);
      
      debugPrint('POST $baseUrl => ${response.statusCode}');
      debugPrint('Response: ${response.data}');
      
      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return true;
      } else {
        throw Exception('${response.statusCode}: ${response.data}');
      }
    } on DioException catch (e) {
      throw Exception('${e.response?.statusCode}: ${e.response?.data ?? e.message}');
    } catch (e) {
      throw Exception('$e');
    }
  }

  Future<bool> updateLandmark(Landmark landmark, File? imageFile) async {
    try {
      debugPrint('UPDATE - ID: ${landmark.id}, Title: ${landmark.title}, Lat: ${landmark.lat}, Lon: ${landmark.lon}');

      String? newImagePath;

      // Step 1: If new image, upload it first by creating a temporary landmark
      if (imageFile != null) {
        debugPrint('Step 1: Uploading new image...');
        try {
          final tempFormData = FormData.fromMap({
            'title': 'TEMP_${DateTime.now().millisecondsSinceEpoch}',
            'lat': landmark.lat.toString(),
            'lon': landmark.lon.toString(),
            'image': await MultipartFile.fromFile(
              imageFile.path,
              filename: imageFile.path.split('/').last,
            ),
          });

          final uploadResp = await _dio.post(baseUrl, data: tempFormData);
          debugPrint('Image upload response: ${uploadResp.data}');

          // Extract the image path from the created entry
          if (uploadResp.data is Map) {
            // Try different possible field names
            newImagePath = uploadResp.data['image'] ?? 
                          uploadResp.data['data']?['image'] ??
                          uploadResp.data['landmark']?['image'];
            
            // Delete the temp entry if we got an ID back
            if (uploadResp.data['id'] != null || uploadResp.data['data']?['id'] != null) {
              final tempId = uploadResp.data['id'] ?? uploadResp.data['data']?['id'];
              try {
                await _dio.delete('$baseUrl?id=$tempId');
                debugPrint('Deleted temp entry: $tempId');
              } catch (e) {
                debugPrint('Could not delete temp entry: $e');
              }
            }
          }
          debugPrint('Extracted image path: $newImagePath');
        } catch (e) {
          debugPrint('Image upload failed: $e');
          // Continue without image update
        }
      }

      // Step 2: Update the landmark with form-urlencoded (with or without new image path)
      debugPrint('Step 2: Updating landmark data...');
      final Map<String, dynamic> data = {
        'id': landmark.id,
        'title': landmark.title,
        'lat': landmark.lat.toString(),
        'lon': landmark.lon.toString(),
      };

      if (newImagePath != null) {
        data['image'] = newImagePath;
      }

      final response = await _dio.put(
        baseUrl,
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
        ),
      );
      
      debugPrint('PUT $baseUrl => ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return true;
      } else {
        debugPrint('PUT Error Response: ${response.data}');
        throw Exception('${response.statusCode}: ${response.data}');
      }
    } on DioException catch (e) {
      debugPrint('Exception: ${e.response?.statusCode}: ${e.response?.data ?? e.message}');
      throw Exception('${e.response?.statusCode}: ${e.response?.data ?? e.message}');
    } catch (e) {
      debugPrint('Exception: $e');
      throw Exception('$e');
    }
  }

  Future<bool> deleteLandmark(String id) async {
    try {
      final response = await _dio.delete('$baseUrl?id=$id');

      debugPrint('DELETE $baseUrl?id=$id => ${response.statusCode}');
      debugPrint('Response: ${response.data}');

      if (response.statusCode != null && response.statusCode! >= 200 && response.statusCode! < 300) {
        return true;
      } else {
        throw Exception('${response.statusCode}');
      }
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        throw Exception('Request timed out');
      } else if (e.type == DioExceptionType.connectionError) {
        throw Exception('Network error');
      }
      throw Exception('${e.message}');
    } catch (e) {
      throw Exception('$e');
    }
  }
}
