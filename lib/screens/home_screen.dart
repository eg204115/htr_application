import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/colors.dart';
import 'camera_screen.dart';
import '../widgets/recognition_result.dart';
import '../services/ocr_api_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ====== NEW: configure your API here ======
  static const String _apiBaseUrl = 'http://192.168.43.231:5000'; // Android emulator -> host machine
  // If you enabled Bearer auth on the server, put it here (or pass null if not used)
  static const String? _apiKey = null;
  // ==========================================

  final ImagePicker _picker = ImagePicker();
  final OcrApiService _ocrService =
  OcrApiService(baseUrl: _apiBaseUrl, apiKey: _apiKey);

  List<XFile> _selectedImages = [];
  List<PlatformFile> _selectedDocuments = [];
  String _recognizedText = '';
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/icon.png',
              width: 60.w,
              height: 60.w,
              fit: BoxFit.cover,
            ),
            SizedBox(width: 4.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Inkling',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryWhite,
                    fontSize: 20.sp,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Capture. Convert. Create.',
                  style: TextStyle(
                    color: AppColors.primaryWhite.withOpacity(0.9),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAppDescription(),
              SizedBox(height: 30.h),
              _buildFileSelectionSection(),
              SizedBox(height: 30.h),
              _buildSelectedFilesPreview(),
              SizedBox(height: 30.h),
              _buildActionButtons(),
              SizedBox(height: 30.h),
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
          'Document Transcription Service',
          style: TextStyle(
            fontSize: 24.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            height: 1.3,
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          'Capture, upload, or select handwritten documents and convert them to editable digital text.',
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildFileSelectionSection() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowLight,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Choose Input Method',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 20.h),
          _buildFileSelectionButtons(),
        ],
      ),
    );
  }

  Widget _buildFileSelectionButtons() {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 400) {
          return Column(
            children: [
              _buildCameraButton(),
              SizedBox(height: 12.h),
              _buildGalleryButton(),
              SizedBox(height: 12.h),
              _buildDocumentButton(),
            ],
          );
        }
        return Row(
          children: [
            Expanded(child: _buildCameraButton()),
            SizedBox(width: 12.w),
            Expanded(child: _buildGalleryButton()),
            SizedBox(width: 12.w),
            Expanded(child: _buildDocumentButton()),
          ],
        );
      },
    );
  }

  Widget _buildCameraButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.camera_alt, size: 20.w, color: AppColors.primaryWhite),
      label: Text('Camera', style: TextStyle(fontSize: 14.sp, color: AppColors.primaryWhite)),
      onPressed: _openCamera,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.primaryWhite,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  Widget _buildGalleryButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.photo_library, size: 20.w, color: AppColors.primaryWhite),
      label: Text('Gallery', style: TextStyle(fontSize: 14.sp, color: AppColors.primaryWhite)),
      onPressed: _pickFromGallery,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonSecondary,
        foregroundColor: AppColors.primaryWhite,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  Widget _buildDocumentButton() {
    return ElevatedButton.icon(
      icon: Icon(Icons.insert_drive_file, size: 20.w, color: AppColors.primaryWhite),
      label: Text('Documents', style: TextStyle(fontSize: 14.sp, color: AppColors.primaryWhite)),
      onPressed: _pickDocuments,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.info,
        foregroundColor: AppColors.primaryWhite,
        padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 12.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      ),
    );
  }

  Widget _buildSelectedFilesPreview() {
    final hasFiles = _selectedImages.isNotEmpty || _selectedDocuments.isNotEmpty;
    if (!hasFiles) {
      return Container(
        padding: EdgeInsets.all(24.w),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.borderLight, style: BorderStyle.solid),
        ),
        child: Column(
          children: [
            Icon(Icons.folder_open, size: 48.w, color: AppColors.textLight),
            SizedBox(height: 12.h),
            Text('No files selected', style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary)),
            SizedBox(height: 8.h),
            Text(
              'Use the buttons above to add images or documents',
              style: TextStyle(fontSize: 12.sp, color: AppColors.textLight),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.attachment, color: AppColors.iconPrimary, size: 20.w),
            SizedBox(width: 8.w),
            Text('Selected Files',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                '${_selectedImages.length + _selectedDocuments.length}',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        _buildFilesList(),
      ],
    );
  }

  Widget _buildFilesList() {
    return Column(
      children: [
        ..._selectedImages.asMap().entries.map(
              (entry) => _buildFileItem(
            entry.value.name,
            Icons.photo,
            AppColors.success,
            entry.key,
            isImage: true,
          ),
        ),
        ..._selectedDocuments.asMap().entries.map(
              (entry) => _buildFileItem(
            entry.value.name,
            _getDocumentIcon(entry.value.extension),
            AppColors.info,
            entry.key + _selectedImages.length,
            isImage: false,
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: Icon(Icons.add, size: 18.w, color: AppColors.buttonPrimary),
                label: Text('Add More Files', style: TextStyle(color: AppColors.buttonPrimary)),
                onPressed: _showFileSourceDialog,
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                  side: BorderSide(color: AppColors.buttonPrimary),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton.icon(
                icon: Icon(Icons.delete, size: 18.w, color: AppColors.primaryWhite),
                label: Text('Clear All', style: TextStyle(color: AppColors.primaryWhite)),
                onPressed: _clearAllFiles,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonDanger,
                  foregroundColor: AppColors.primaryWhite,
                  padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFileItem(
      String fileName,
      IconData icon,
      Color color,
      int index, {
        required bool isImage,
      }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [BoxShadow(color: AppColors.shadowLight, blurRadius: 4.r, offset: Offset(0, 2.h))],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(icon, color: color, size: 24.w),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fileName,
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                    overflow: TextOverflow.ellipsis),
                SizedBox(height: 4.h),
                Text(isImage ? 'Image' : 'Document', style: TextStyle(fontSize: 12.sp, color: AppColors.textLight)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, size: 20.w, color: AppColors.textLight),
            onPressed: () => _removeFile(index, isImage),
            padding: EdgeInsets.all(8.w),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final hasFiles = _selectedImages.isNotEmpty || _selectedDocuments.isNotEmpty;
    if (!hasFiles) return SizedBox();

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.text_fields, size: 24.w, color: AppColors.primaryWhite),
            label: Text(
              'Transcribe All Files',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: AppColors.primaryWhite),
            ),
            onPressed: _transcribeAllFiles,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonPrimary,
              foregroundColor: AppColors.primaryWhite,
              padding: EdgeInsets.symmetric(vertical: 18.h, horizontal: 16.w),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openCamera() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CameraScreen(existingImages: _selectedImages)),
    );
    if (result != null && result is List<XFile>) {
      setState(() {
        _selectedImages = result;
        _recognizedText = '';
      });
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage(
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 90,
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedImages.addAll(images);
          _recognizedText = '';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick images: $e');
    }
  }

  Future<void> _pickDocuments() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: true,
      );
      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedDocuments.addAll(result.files);
          _recognizedText = '';
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick documents: $e');
    }
  }

  void _showFileSourceDialog() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (context) => Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Select File Source', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
            SizedBox(height: 20.h),
            _buildSourceOption(Icons.camera_alt, 'Take Photos', 'Capture new images with camera', _openCamera),
            _buildSourceOption(
                Icons.photo_library, 'Choose from Gallery', 'Select images from your gallery', _pickFromGallery),
            _buildSourceOption(
                Icons.insert_drive_file, 'Upload Documents', 'PDF, Word, or text files', _pickDocuments),
            SizedBox(height: 20.h),
            OutlinedButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
              style: OutlinedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 32.w)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: AppColors.primaryBlue.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Icon(icon, color: AppColors.primaryBlue),
      ),
      title: Text(title, style: TextStyle(fontSize: 16.sp, color: AppColors.textPrimary)),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12.sp, color: AppColors.textLight)),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  IconData _getDocumentIcon(String? extension) {
    switch (extension?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      default:
        return Icons.insert_drive_file;
    }
  }

  void _removeFile(int index, bool isImage) {
    setState(() {
      if (isImage) {
        _selectedImages.removeAt(index);
      } else {
        _selectedDocuments.removeAt(index - _selectedImages.length);
      }
    });
  }

  void _clearAllFiles() {
    setState(() {
      _selectedImages.clear();
      _selectedDocuments.clear();
      _recognizedText = '';
    });
  }

  Future<void> _transcribeAllFiles() async {
    if (_selectedImages.isEmpty && _selectedDocuments.isEmpty) {
      _showErrorSnackBar('Please select files first');
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 1) quick health check (optional but nice)
      try {
        final h = await _ocrService.health();
        if (h.status.toLowerCase() != 'healthy') {
          _showErrorSnackBar('Server not healthy');
          setState(() => _isProcessing = false);
          return;
        }
      } catch (_) {
        _showErrorSnackBar('Cannot reach OCR server. Check URL / network.');
        setState(() => _isProcessing = false);
        return;
      }

      String combinedText = '=== TRANSCRIPTION RESULTS ===\n\n';

      // 2) images -> /process
      for (final image in _selectedImages) {
        final result = await _ocrService.processImage(image, method: 'hybrid');
        if (result.success) {
          final txt = (result.text ?? '').trim();
          final conf = result.confidence?.toStringAsFixed(3) ?? '—';
          combinedText += '📷 ${image.name}\nConfidence: $conf\n$txt\n\n';
        } else {
          combinedText += '📷 ${image.name}\nERROR: ${result.error ?? 'Unknown error'}\n\n';
        }
      }

      // 3) documents -> not supported by the Flask endpoint (only images)
      if (_selectedDocuments.isNotEmpty) {
        combinedText +=
        '⚠ ${_selectedDocuments.length} document(s) were selected, but the server only accepts images at /process.\n';
      }

      setState(() => _recognizedText = combinedText);
    } catch (e) {
      _showErrorSnackBar('Transcription failed: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(fontSize: 14.sp)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}