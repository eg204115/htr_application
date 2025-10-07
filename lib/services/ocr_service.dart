import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class OCRService {
  // For Android emulator, use 10.0.2.2 to connect to localhost
  // For real device, use your computer's IP address
  // static const String baseUrl = 'http://10.0.2.2:5000'; // Android emulator
  static const String baseUrl =
      'http://192.168.43.231:5000'; // Real device - replace with your IP

  // Check if backend server is available
  static Future<bool> checkServerHealth() async {
    try {
      final response = await http
          .get(
            Uri.parse('$baseUrl/api/health'),
            headers: {'Content-Type': 'application/json'},
          )
          .timeout(Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Server health check failed: $e');
      return false;
    }
  }

  // Convert XFile to base64
  static Future<String> imageToBase64(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      throw Exception('Failed to convert image to base64: $e');
    }
  }

  // Process single image
  static Future<Map<String, dynamic>> processSingleImage(
    XFile imageFile, {
    bool useTrocr = true,
    String textType = 'handwritten',
  }) async {
    try {
      final base64Image = await imageToBase64(imageFile);
print("Hello");
      final response = await http.post(
        Uri.parse('$baseUrl/api/process/single'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'image': base64Image,
          'use_trocr': useTrocr,
          'text_type': textType,
        }),
      );

      if (response.statusCode == 200) {
        print('response: ${response.body}');
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to process image: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('OCR processing error: $e');
    }
  }

  // Process multiple images
  static Future<Map<String, dynamic>> processMultipleImages(
    List<XFile> imageFiles, {
    bool useTrocr = true,
    String textType = 'handwritten',
  }) async {
    try {
      List<String> base64Images = [];

      // Convert all images to base64
      for (var imageFile in imageFiles) {
        final base64Image = await imageToBase64(imageFile);
        base64Images.add(base64Image);
      }

      final response = await http.post(
        Uri.parse('$baseUrl/api/process/batch'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'images': base64Images,
          'use_trocr': useTrocr,
          'text_type': textType,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Failed to process images: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      throw Exception('Batch OCR processing error: $e');
    }
  }

  // Get system info
  static Future<Map<String, dynamic>> getSystemInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/info'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get system info: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('System info error: $e');
    }
  }
}
