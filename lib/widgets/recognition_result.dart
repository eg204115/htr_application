import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
              color: Colors.blue.shade700,
              size: 20.w, // Responsive icon size
            ),
            SizedBox(width: 8.w),
            Text(
              'Recognized Text',
              style: TextStyle(
                fontSize: 18.sp, // Responsive font size
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 120.h), // Responsive min height
          padding: EdgeInsets.all(16.w), // Responsive padding
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12.r), // Responsive border radius
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.w, // Responsive border width
            ),
          ),
          child: isProcessing
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 24.w, // Responsive loader size
                  height: 24.w, // Responsive loader size
                  child: CircularProgressIndicator(
                    color: Colors.blue.shade700,
                    strokeWidth: 2.w, // Responsive stroke width
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Processing your image...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14.sp, // Responsive font size
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
                fontSize: 16.sp, // Responsive font size
                color: Colors.grey.shade800,
                height: 1.4,
              ),
            ),
          )
              : Center(
            child: Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                'No text recognized yet.\nSelect an image and tap recognize.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 14.sp, // Responsive font size
                ),
              ),
            ),
          ),
        ),
        if (recognizedText.isNotEmpty && !isProcessing) ...[
          SizedBox(height: 16.h),
          Center(
            child: ElevatedButton.icon(
              icon: Icon(Icons.content_copy, size: 18.w), // Responsive icon size
              label: Text(
                'Copy to Clipboard',
                style: TextStyle(fontSize: 14.sp), // Responsive font size
              ),
              onPressed: () {
                _copyToClipboard(context, recognizedText);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: 12.h, // Responsive padding
                  horizontal: 20.w, // Responsive padding
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r), // Responsive border radius
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