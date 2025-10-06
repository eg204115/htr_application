import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../constants/colors.dart';

class RecognitionResultWidget extends StatelessWidget {
  final String recognizedText;
  final bool isProcessing;

  const RecognitionResultWidget({
    Key? key,
    required this.recognizedText,
    required this.isProcessing,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.text_fields,
              color: AppColors.iconPrimary, // Updated color
              size: 20.w,
            ),
            SizedBox(width: 8.w),
            Text(
              'Recognized Text',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary, // Updated color
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 120.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite, // Updated color
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.borderLight, // Updated color
              width: 1.w,
            ),
          ),
          child: isProcessing
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24.w,
                  height: 24.w,
                  child: CircularProgressIndicator(
                    color: AppColors.primaryBlue, // Updated color
                    strokeWidth: 2.w,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Processing your image...',
                  style: TextStyle(
                    color: AppColors.textSecondary, // Updated color
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          )
              : recognizedText.isNotEmpty
              ? SingleChildScrollView(
            child: SelectableText(
              recognizedText,
              style: TextStyle(
                fontSize: 16.sp,
                color: AppColors.textPrimary, // Updated color
                height: 1.4,
              ),
            ),
          )
              : Center(
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                'No text recognized yet.\nSelect files and tap transcribe.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textLight, // Updated color
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ),
        if (recognizedText.isNotEmpty && !isProcessing) ...[
          SizedBox(height: 16.h),
          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.content_copy, size: 18.w, color: AppColors.primaryWhite),
              label: Text(
                'Copy to Clipboard',
                style: TextStyle(fontSize: 14.sp, color: AppColors.primaryWhite),
              ),
              onPressed: () {
                _copyToClipboard(context, recognizedText);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary, // Updated color
                foregroundColor: AppColors.primaryWhite,
                padding: EdgeInsets.symmetric(
                  vertical: 12.h,
                  horizontal: 20.w,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }


  void _copyToClipboard(BuildContext context, String text) {
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
              Icon(
                Icons.info_outline,
                size: 40.w, // Responsive icon size
                color: Colors.blue.shade600,
              ),
              SizedBox(height: 16.h),
              Text(
                'Copy to Clipboard',
                style: TextStyle(
                  fontSize: 18.sp, // Responsive font size
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'This feature will be implemented with the backend service.',
                style: TextStyle(fontSize: 14.sp), // Responsive font size
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 14.sp), // Responsive font size
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}