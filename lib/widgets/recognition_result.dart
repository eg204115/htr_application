import 'package:flutter/material.dart';

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
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Recognized Text',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800,
              ),
            ),
          ],
        ),
        SizedBox(height: 12),
        Container(
          width: double.infinity,
          constraints: BoxConstraints(minHeight: 120),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: isProcessing
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.blue.shade700,
                ),
                SizedBox(height: 16),
                Text(
                  'Processing your image...',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
              : recognizedText.isNotEmpty
              ? SelectableText(
            recognizedText,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
              height: 1.4,
            ),
          )
              : Center(
            child: Text(
              'No text recognized yet.\nSelect an image and tap recognize.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ),
        ),
        if (recognizedText.isNotEmpty && !isProcessing) ...[
          SizedBox(height: 16),
          ElevatedButton.icon(
            icon: Icon(Icons.content_copy, size: 18),
            label: Text('Copy to Clipboard'),
            onPressed: () {
              _copyToClipboard(context, recognizedText);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _copyToClipboard(BuildContext context, String text) {
    // For now, we'll just show a dialog since we don't have services set up
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Copy to Clipboard'),
        content: Text('This feature will be implemented with the backend service.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }
}