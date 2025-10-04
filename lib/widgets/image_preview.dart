import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class ImagePreviewWidget extends StatelessWidget {
  final XFile? selectedImage;
  final VoidCallback onTap;

  const ImagePreviewWidget({
    Key? key,
    required this.selectedImage,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Adjust height based on screen size
        final containerHeight = constraints.maxHeight < 600 ? 180.h : 250.h;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            height: containerHeight,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16.r), // Responsive border radius
              border: Border.all(
                color: Colors.grey.shade300,
                width: 2.w, // Responsive border width
              ),
            ),
            child: selectedImage != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(14.r), // Responsive border radius
              child: Image.network(
                selectedImage!.path,
                fit: BoxFit.cover,
                width: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    selectedImage!.path,
                    fit: BoxFit.cover,
                    width: double.infinity,
                  );
                },
              ),
            )
                : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.photo_camera,
                  size: 64.w, // Responsive icon size
                  color: Colors.grey.shade400,
                ),
                SizedBox(height: 16.h),
                Text(
                  'Tap to select an image',
                  style: TextStyle(
                    fontSize: 16.sp, // Responsive font size
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Supported formats: JPG, PNG',
                  style: TextStyle(
                    fontSize: 12.sp, // Responsive font size
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}