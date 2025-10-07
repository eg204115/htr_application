// lib/services/ocr_api_service.dart
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

class OcrProcessResult {
  final bool success;
  final String? text;
  final double? confidence;
  final String? processedImageBase64; // PNG (base64)
  final String? error;

  OcrProcessResult({
    required this.success,
    this.text,
    this.confidence,
    this.processedImageBase64,
    this.error,
  });

  factory OcrProcessResult.fromJson(Map<String, dynamic> j) {
    return OcrProcessResult(
      success: j['success'] == true,
      text: j['text'] as String?,
      confidence: (j['confidence'] is num) ? (j['confidence'] as num).toDouble() : null,
      processedImageBase64: j['processed_image'] as String?,
      error: j['error'] as String?,
    );
  }
}

class OcrHealth {
  final String status;
  final bool trocrAvailable;
  OcrHealth({required this.status, required this.trocrAvailable});
  factory OcrHealth.fromJson(Map<String, dynamic> j) => OcrHealth(
    status: (j['status'] ?? '').toString(),
    trocrAvailable: (j['trocr_available'] == true),
  );
}

class OcrApiService {
  final Dio _dio;

  /// Set your API base URL, e.g. "http://10.0.2.2:5000/" for Android emulator
  /// or "http://YOUR_LAN_IP:5000/" when testing on a real device.
  OcrApiService({
    required String baseUrl,
    String? apiKey, // optional Bearer token if you enabled auth
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 200),
  }) : _dio = Dio(
    BaseOptions(
      baseUrl: baseUrl.endsWith('/') ? baseUrl : '$baseUrl/',
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: apiKey == null ? null : {'Authorization': 'Bearer $apiKey'},
    ),
  );

  Future<OcrHealth> health() async {
    final resp = await _dio.get('health');
    return OcrHealth.fromJson(resp.data as Map<String, dynamic>);
  }

  /// Upload one image to /process. method defaults to "hybrid".
  Future<OcrProcessResult> processImage(XFile img, {String method = 'hybrid'}) async {
    try {
      final form = FormData.fromMap({
        'method': method,
        'image': await MultipartFile.fromFile(img.path, filename: img.name),
      });

      final response = await _dio.post('process', data: form);

      if (response.statusCode == 200) {
        return OcrProcessResult.fromJson(response.data as Map<String, dynamic>);
      } else {
        return OcrProcessResult(
          success: false,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      // Handle Dio errors (network, timeout, etc.)
      String errorMsg = 'Network error: ${e.message}';
      if (e.response != null) {
        errorMsg = 'Server error: ${e.response?.statusCode} - ${e.response?.statusMessage}';
      }
      return OcrProcessResult(success: false, error: errorMsg);
    } catch (e) {
      // Handle other errors
      return OcrProcessResult(success: false, error: 'Unexpected error: $e');
    }
  }
  /// Quick helper to validate base64 (optional to use in UI)
  static bool isValidBase64(String? s) {
    if (s == null || s.isEmpty) return false;
    try {
      base64Decode(s);
      return true;
    } catch (_) {
      return false;
    }
  }
}