import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class MockRecognitionService {
  Future<String> recognizeText(XFile image) async {
    await Future.delayed(Duration(seconds: 1));

    final mockResponses = [
      "This is transcribed text from your captured document. The handwriting recognition would extract text from images in production.",
      "Document successfully transcribed. This is sample text that would be extracted using OCR technology for handwritten content.",
      "Transcription completed. The system would analyze the handwriting patterns and convert them to digital text with high accuracy.",
    ];

    return mockResponses[DateTime.now().millisecondsSinceEpoch % mockResponses.length];
  }

  Future<String> recognizeDocument(PlatformFile document) async {
    await Future.delayed(Duration(seconds: 2));

    final extension = document.extension?.toLowerCase();

    switch (extension) {
      case 'pdf':
        return "PDF document transcription completed. This would extract text from all pages of the PDF file containing handwritten content.";
      case 'doc':
      case 'docx':
        return "Word document processed successfully. Handwritten text from the document has been converted to editable digital format.";
      case 'txt':
        return "Text file content extracted. This would process any handwritten text content within the document.";
      default:
        return "Document transcription completed. The file has been processed for handwritten text recognition.";
    }
  }
}