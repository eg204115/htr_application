import 'package:image_picker/image_picker.dart';

class MockRecognitionService {
  Future<String> recognizeText(XFile image) async {
    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));

    // Mock responses for demonstration
    final mockResponses = [
      "This is a sample recognized text from your handwritten document. The actual implementation will connect to a real OCR service.",
      "Hello! This is your converted handwritten text. The final version will use Google Cloud Vision or similar service.",
      "The quick brown fox jumps over the lazy dog. This is mock data for frontend development.",
      "Congratulations! Your handwriting recognition is working. Connect to a real OCR API for actual text conversion.",
    ];

    // Return a random mock response
    return mockResponses[DateTime.now().millisecondsSinceEpoch % mockResponses.length];
  }
}