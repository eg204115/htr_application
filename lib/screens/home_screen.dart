import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../widgets/image_preview.dart';
import '../widgets/recognition_result.dart';
import '../services/mock_recognition_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  XFile? _selectedImage;
  String _recognizedText = '';
  bool _isProcessing = false;
  final ImagePicker _picker = ImagePicker();
  final MockRecognitionService _recognitionService = MockRecognitionService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Handwriting Recognition',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // App title and description
            _buildAppDescription(),
            SizedBox(height: 30),

            // Image preview section
            ImagePreviewWidget(
              selectedImage: _selectedImage,
              onTap: _showImageSourceDialog,
            ),
            SizedBox(height: 30),

            // Action buttons
            _buildActionButtons(),
            SizedBox(height: 30),

            // Recognition result section
            RecognitionResultWidget(
              recognizedText: _recognizedText,
              isProcessing: _isProcessing,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Convert Handwritten Text to Digital Format',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
          ),
        ),
        SizedBox(height: 10),
        Text(
          'Capture or upload an image of handwritten text and convert it to editable digital text.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.photo_library, size: 20),
            label: Text(
              'Choose from Gallery',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: _pickImageFromGallery,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade500,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.camera_alt, size: 20),
            label: Text(
              'Take Photo',
              style: TextStyle(fontSize: 16),
            ),
            onPressed: _takePhoto,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _recognizedText = '';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      if (image != null) {
        setState(() {
          _selectedImage = image;
          _recognizedText = '';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to take photo: $e');
    }
  }

  void _showImageSourceDialog() {
    if (_selectedImage == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Image Options'),
        content: Text('What would you like to do with this image?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _recognizeText();
            },
            child: Text('Recognize Text'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedImage = null;
                _recognizedText = '';
              });
            },
            child: Text('Remove Image'),
          ),
        ],
      ),
    );
  }

  Future<void> _recognizeText() async {
    if (_selectedImage == null) {
      _showErrorSnackBar('Please select an image first');
      return;
    }

    setState(() => _isProcessing = true);

    // Simulate API call delay
    await Future.delayed(Duration(seconds: 2));

    try {
      final recognizedText = await _recognitionService.recognizeText(_selectedImage!);
      setState(() => _recognizedText = recognizedText);
    } catch (e) {
      _showErrorSnackBar('Recognition failed: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}