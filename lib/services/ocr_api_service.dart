import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

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

class ConvertHandwrittenResult {
  final bool success;
  final String? error;
  final String? combinedText; // Combined text from all files
  final double? overallConfidence;
  final int? processedCount;
  final int? totalCount;
  final List<FileResult>? results; // Individual file results

  ConvertHandwrittenResult({
    required this.success,
    this.error,
    this.combinedText,
    this.overallConfidence,
    this.processedCount,
    this.totalCount,
    this.results,
  });

  factory ConvertHandwrittenResult.fromJson(Map<String, dynamic> j) {
    List<FileResult>? results;
    if (j['results'] is List) {
      results = (j['results'] as List).map((item) => FileResult.fromJson(item)).toList();
    }

    return ConvertHandwrittenResult(
      success: j['success'] == true,
      error: j['error'] as String?,
      combinedText: j['combined_text'] as String?,
      overallConfidence: (j['overall_confidence'] is num) ? (j['overall_confidence'] as num).toDouble() : null,
      processedCount: (j['processed_count'] is num) ? (j['processed_count'] as num).toInt() : null,
      totalCount: (j['total_count'] is num) ? (j['total_count'] as num).toInt() : null,
      results: results,
    );
  }
}

class FileResult {
  final String filename;
  final bool success;
  final String? text;
  final double? confidence;
  final String? error;

  FileResult({
    required this.filename,
    required this.success,
    this.text,
    this.confidence,
    this.error,
  });

  factory FileResult.fromJson(Map<String, dynamic> j) {
    return FileResult(
      filename: (j['filename'] ?? '').toString(),
      success: j['success'] == true,
      text: j['text'] as String?,
      confidence: (j['confidence'] is num) ? (j['confidence'] as num).toDouble() : null,
      error: j['error'] as String?,
    );
  }
}

class OcrHealth {
  final String status;
  final bool trocrAvailable;
  final bool handwritingConverterAvailable;

  OcrHealth({
    required this.status,
    required this.trocrAvailable,
    required this.handwritingConverterAvailable,
  });

  factory OcrHealth.fromJson(Map<String, dynamic> j) => OcrHealth(
    status: (j['status'] ?? '').toString(),
    trocrAvailable: (j['trocr_available'] == true),
    handwritingConverterAvailable: (j['handwriting_converter_available'] == true),
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
    Duration receiveTimeout = const Duration(seconds: 6000),
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

  /// Convert PDF or image to text PDF using /convert-handwritten endpoint
  Future<ConvertHandwrittenResult> convertHandwritten(List<PlatformFile> files) async {
    try {
      // Create form data with multiple files
      final formData = FormData();

      for (int i = 0; i < files.length; i++) {
        final file = files[i];
        formData.files.add(MapEntry(
          'files', // Use 'files' as field name for multiple files
          await MultipartFile.fromFile(file.path!, filename: file.name),
        ));
      }

      print('📤 Sending ${files.length} files to convert-handwritten endpoint');

      final response = await _dio.post(
        'convert-handwritten',
        data: formData,
      );

      if (response.statusCode == 200) {
        // Parse JSON response
        final responseData = response.data;
        print('📊 Convert handwritten response type: ${responseData.runtimeType}');

        if (responseData is Map<String, dynamic>) {
          return ConvertHandwrittenResult.fromJson(responseData);
        } else {
          return ConvertHandwrittenResult(
            success: false,
            error: 'Invalid response format from server',
          );
        }
      } else {
        return ConvertHandwrittenResult(
          success: false,
          error: 'Server error: ${response.statusCode}',
        );
      }
    } on DioException catch (e) {
      String errorMsg = 'Network error: ${e.message}';
      if (e.response != null) {
        try {
          final errorData = e.response?.data;
          print('❌ Dio error response: $errorData');
          if (errorData is Map && errorData['error'] != null) {
            errorMsg = errorData['error'].toString();
          } else if (errorData is String) {
            errorMsg = errorData;
          } else {
            errorMsg = 'Server error: ${e.response?.statusCode}';
          }
        } catch (_) {
          errorMsg = 'Server error: ${e.response?.statusCode}';
        }
      }
      return ConvertHandwrittenResult(success: false, error: errorMsg);
    } catch (e) {
      print('❌ Unexpected error in convertHandwritten: $e');
      return ConvertHandwrittenResult(success: false, error: 'Unexpected error: $e');
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