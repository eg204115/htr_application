import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart'; // Add this import for clipboard

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
              color: AppColors.iconPrimary,
              size: 20.w,
            ),
            SizedBox(width: 8.w),
            Text(
              'Extracted Text',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            if (isProcessing) ...[
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12.w,
                      height: 12.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                      ),
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      'Processing...',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 120.h),
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: AppColors.borderLight,
              width: 1.w,
            ),
          ),
          child: _buildContent(),
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
              onPressed: () => _copyToClipboard(context, recognizedText),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.buttonPrimary,
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

  Widget _buildContent() {
    if (isProcessing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 24.w,
              height: 24.w,
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
                strokeWidth: 2.w,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              'Processing your image...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    }

    if (recognizedText.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.text_snippet_outlined,
                size: 32.w,
                color: AppColors.textLight,
              ),
              SizedBox(height: 8.h),
              Text(
                'No text extracted yet',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                'Process images to see extracted text here',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12.sp,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: SelectableText(
        recognizedText,
        style: TextStyle(
          fontSize: 14.sp, // Slightly smaller for better readability
          color: AppColors.textPrimary,
          height: 1.4,
        ),
      ),
    );
  }

  void _copyToClipboard(BuildContext context, String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));

      // Show success snackbar instead of dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: AppColors.primaryWhite, size: 20.w),
              SizedBox(width: 8.w),
              Text(
                'Text copied to clipboard!',
                style: TextStyle(fontSize: 14.sp, color: AppColors.primaryWhite),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Show error snackbar if copy fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.primaryWhite, size: 20.w),
              SizedBox(width: 8.w),
              Text(
                'Failed to copy text',
                style: TextStyle(fontSize: 14.sp, color: AppColors.primaryWhite),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.all(16.w),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }
}