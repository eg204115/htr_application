import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
            fontSize: 18.sp, // Responsive font size
          ),
        ),
        backgroundColor: Colors.blue.shade700,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 20.w, // Responsive horizontal padding
            vertical: 20.h,  // Responsive vertical padding
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App title and description
              _buildAppDescription(),
              SizedBox(height: 30.h),

              // Image preview section
              ImagePreviewWidget(
                selectedImage: _selectedImage,
                onTap: _showImageSourceDialog,
              ),
              SizedBox(height: 30.h),

              // Action buttons
              _buildActionButtons(),
              SizedBox(height: 30.h),

              // Recognition result section
              RecognitionResultWidget(
                recognizedText: _recognizedText,
                isProcessing: _isProcessing,
              ),
            ],
          ),
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
            fontSize: 24.sp,     // Responsive font size
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade800,
            height: 1.3,         // Better line height for responsiveness
          ),
          textAlign: TextAlign.left,
        ),
        SizedBox(height: 10.h),
        Text(
          'Capture or upload an image of handwritten text and convert it to editable digital text.',
          style: TextStyle(
            fontSize: 14.sp,     // Responsive font size
            color: Colors.grey.shade600,
            height: 1.4,         // Better line height
          ),
          textAlign: TextAlign.left,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // For very small screens, stack buttons vertically
        if (constraints.maxWidth < 350) {
          return Column(
            children: [
              _buildGalleryButton(),
              SizedBox(height: 12.h),
              _buildCameraButton(),
            ],
          );
        }

        // For normal screens, use horizontal layout
        return Row(
          children: [
            Expanded(child: _buildGalleryButton()),
            SizedBox(width: 12.w),
            Expanded(child: _buildCameraButton()),
          ],
        );
      },
    );
  }

  Widget _buildGalleryButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.photo_library, size: 20.w), // Responsive icon size
      label: Text(
        'Choose from Gallery',
        style: TextStyle(fontSize: 14.sp), // Responsive font size
      ),
      onPressed: _pickImageFromGallery,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green.shade500,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15.h), // Responsive padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r), // Responsive border radius
        ),
      ),
    );
  }

  Widget _buildCameraButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.camera_alt, size: 20.w), // Responsive icon size
      label: Text(
        'Take Photo',
        style: TextStyle(fontSize: 14.sp), // Responsive font size
      ),
      onPressed: _takePhoto,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 15.h), // Responsive padding
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r), // Responsive border radius
        ),
      ),
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r), // Responsive border radius
        ),
        child: Padding(
          padding: EdgeInsets.all(20.w), // Responsive padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Image Options',
                style: TextStyle(
                  fontSize: 18.sp, // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'What would you like to do with this image?',
                style: TextStyle(fontSize: 14.sp), // Responsive font size
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _recognizeText();
                      },
                      child: Text(
                        'Recognize Text',
                        style: TextStyle(fontSize: 14.sp), // Responsive font size
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        setState(() {
                          _selectedImage = null;
                          _recognizedText = '';
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade500,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        'Remove Image',
                        style: TextStyle(fontSize: 14.sp), // Responsive font size
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
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
        content: Text(
          message,
          style: TextStyle(fontSize: 14.sp), // Responsive font size
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w), // Responsive margin
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r), // Responsive border radius
        ),
      ),
    );
  }
}