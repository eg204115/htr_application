import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';
import '../constants/colors.dart';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';

class CameraScreen extends StatefulWidget {
  final List<XFile> existingImages;

  const CameraScreen({Key? key, this.existingImages = const []}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<XFile> _capturedImages = [];
  bool _isFrontCamera = false;
  FlashMode _flashMode = FlashMode.off;

  @override
  void initState() {
    super.initState();
    _capturedImages.addAll(widget.existingImages);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    final camera = _isFrontCamera && cameras.length > 1
        ? cameras[1]
        : cameras.first;

    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue, // Updated color
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppColors.primaryWhite), // Updated color
          onPressed: () => Navigator.pop(context, _capturedImages),
        ),
        title: Text(
          'Capture Documents',
          style: TextStyle(color: AppColors.primaryWhite, fontSize: 18.sp), // Updated color
        ),
        actions: [
          if (_capturedImages.isNotEmpty)
            TextButton(
              onPressed: () => Navigator.pop(context, _capturedImages),
              child: Text(
                'Done (${_capturedImages.length})',
                style: TextStyle(color: AppColors.primaryWhite, fontSize: 16.sp), // Updated color
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Camera Preview
          Expanded(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_controller);
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),

          // Captured Images Preview
          if (_capturedImages.isNotEmpty)
            _buildCapturedImagesPreview(),

          // Camera Controls
          _buildCameraControls(),
        ],
      ),
    );
  }

  Widget _buildCapturedImagesPreview() {
    return Container(
      height: 120.h,
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
      color: Colors.black87,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _capturedImages.length,
        itemBuilder: (context, index) {
          return _buildImageThumbnail(_capturedImages[index], index);
        },
      ),
    );
  }

  Widget _buildImageThumbnail(XFile image, int index) {
    return Stack(
      children: [
        Container(
          width: 80.w,
          height: 100.h,
          margin: EdgeInsets.only(right: 8.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: Colors.white, width: 1.w),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.file(
              File(image.path),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          top: 4.h,
          right: 12.w,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.close, size: 16.w, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraControls() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 16.w),
      color: AppColors.primaryBlue,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Flash Toggle
          IconButton(
            icon: Icon(
              _flashMode == FlashMode.off ? Icons.flash_off : Icons.flash_on,
              color: Colors.white,
              size: 28.w,
            ),
            onPressed: _toggleFlash,
          ),

          // Capture Button
          GestureDetector(
            onTap: _captureImage,
            child: Container(
              width: 70.w,
              height: 70.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3.w),
              ),
              child: Container(
                margin: EdgeInsets.all(6.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),

          // Switch Camera
          IconButton(
            icon: Icon(Icons.cameraswitch, color: Colors.white, size: 28.w),
            onPressed: _switchCamera,
          ),
        ],
      ),
    );
  }

  void _toggleFlash() {
    setState(() {
      _flashMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    });
    _controller.setFlashMode(_flashMode);
  }

  void _switchCamera() async {
    setState(() {
      _isFrontCamera = !_isFrontCamera;
    });
    await _controller.dispose();
    _initializeCamera();
  }


  Future<void> _captureImage() async {
    try {
      await _initializeControllerFuture;
      final XFile image = await _controller.takePicture();

      // Crop the image - returns CroppedFile?
      final CroppedFile? croppedFile = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1.0, ratioY: 1.4),
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop Document',
            toolbarColor: Colors.blue.shade700,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.ratio4x3,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Crop Document',
          ),
        ],
      );

      if (croppedFile != null) {
        setState(() {
          _capturedImages.add(XFile(croppedFile.path));
        });
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }
  void _removeImage(int index) {
    setState(() {
      _capturedImages.removeAt(index);
    });
  }
}