import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../constants/colors.dart';

class RecognitionResultWidget extends StatefulWidget {
  final String recognizedText;
  final bool isProcessing;

  const RecognitionResultWidget({
    Key? key,
    required this.recognizedText,
    required this.isProcessing,
  }) : super(key: key);

  @override
  _RecognitionResultWidgetState createState() => _RecognitionResultWidgetState();
}

class _RecognitionResultWidgetState extends State<RecognitionResultWidget> {
  late TextEditingController _textController;
  bool _isEditing = false;
  bool _isSavingPdf = false;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.recognizedText);
  }

  @override
  void didUpdateWidget(RecognitionResultWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.recognizedText != oldWidget.recognizedText && !_isEditing) {
      _textController.text = widget.recognizedText;
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

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
            if (widget.isProcessing) ...[
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
              color: _isEditing ? AppColors.primaryBlue : AppColors.borderLight,
              width: _isEditing ? 2.w : 1.w,
            ),
          ),
          child: _buildContent(),
        ),
        if (widget.recognizedText.isNotEmpty && !widget.isProcessing) ...[
          SizedBox(height: 16.h),
          _buildActionButtons(),
        ],
      ],
    );
  }

  Widget _buildContent() {
    if (widget.isProcessing) {
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

    if (widget.recognizedText.isEmpty) {
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

    if (_isEditing) {
      return TextField(
        controller: _textController,
        maxLines: null,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: 'Edit your extracted text here...',
          hintStyle: TextStyle(color: AppColors.textLight),
        ),
        style: TextStyle(
          fontSize: 14.sp,
          color: AppColors.textPrimary,
          height: 1.4,
        ),
        onChanged: (value) {
          // Text is automatically updated in the controller
        },
      );
    } else {
      return SingleChildScrollView(
        child: SelectableText(
          _textController.text,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textPrimary,
            height: 1.4,
          ),
        ),
      );
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              size: 18.w,
              color: AppColors.primaryWhite,
            ),
            label: Text(
              _isEditing ? 'Save Changes' : 'Edit Text',
              style: TextStyle(fontSize: 14.sp, color: AppColors.primaryWhite),
            ),
            onPressed: _toggleEditMode,
            style: ElevatedButton.styleFrom(
              backgroundColor: _isEditing ? AppColors.success : AppColors.buttonPrimary,
              foregroundColor: AppColors.primaryWhite,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            icon: _isSavingPdf
                ? SizedBox(
              width: 18.w,
              height: 18.w,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryWhite),
              ),
            )
                : Icon(Icons.picture_as_pdf, size: 18.w, color: AppColors.primaryWhite),
            label: Text(
              _isSavingPdf ? 'Saving...' : 'Save as PDF',
              style: TextStyle(fontSize: 14.sp, color: AppColors.primaryWhite),
            ),
            onPressed: _isSavingPdf ? null : _saveAsPdf,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.buttonDanger,
              foregroundColor: AppColors.primaryWhite,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: ElevatedButton.icon(
            icon: Icon(Icons.content_copy, size: 18.w, color: AppColors.primaryWhite),
            label: Text(
              'Copy Text',
              style: TextStyle(fontSize: 14.sp, color: AppColors.primaryWhite),
            ),
            onPressed: () => _copyToClipboard(_textController.text),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.info,
              foregroundColor: AppColors.primaryWhite,
              padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _toggleEditMode() {
    setState(() {
      if (_isEditing) {
        // Save changes - text is already updated in the controller
        _showSuccessSnackBar('Text changes saved');
      }
      _isEditing = !_isEditing;
    });
  }

  Future<void> _saveAsPdf() async {
    if (_textController.text.isEmpty) {
      _showErrorSnackBar('No text to save as PDF');
      return;
    }

    setState(() {
      _isSavingPdf = true;
    });

    try {
      // Create a new PDF document
      final PdfDocument document = PdfDocument();

      // Add a page
      final PdfPage page = document.pages.add();

      // Create a PDF font
      final PdfFont font = PdfStandardFont(PdfFontFamily.helvetica, 12);

      // Create PDF text element
      final PdfTextElement element = PdfTextElement(
        text: _textController.text,
        font: font,
        brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      );

      // Create PDF layout format
      final PdfLayoutFormat format = PdfLayoutFormat(
        layoutType: PdfLayoutType.paginate,
        breakType: PdfLayoutBreakType.fitPage,
      );

      // Draw the text element on the page
      final PdfLayoutResult result = element.draw(
        page: page,
        bounds: Rect.fromLTWH(50, 50, page.getClientSize().width - 100, page.getClientSize().height - 100),
        format: format,
      )!;

      // Get application documents directory
      final Directory directory = await getApplicationDocumentsDirectory();
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String filePath = '${directory.path}/extracted_text_$timestamp.pdf';

      // Save the document
      final File file = File(filePath);
      await file.writeAsBytes(await document.save());

      // Dispose the document
      document.dispose();

      // Open the PDF file
      await OpenFile.open(filePath);

      setState(() {
        _isSavingPdf = false;
      });

      _showSuccessSnackBar('PDF saved successfully!');

      print('✅ PDF saved to: $filePath');
      print('📄 PDF contains ${_textController.text.length} characters');

    } catch (e) {
      setState(() {
        _isSavingPdf = false;
      });

      print('❌ PDF save failed: $e');
      _showErrorSnackBar('Failed to save PDF: $e');
    }
  }

  void _copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
      _showSuccessSnackBar('Text copied to clipboard!');
    } catch (e) {
      _showErrorSnackBar('Failed to copy text: $e');
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: AppColors.primaryWhite, size: 20.w),
            SizedBox(width: 8.w),
            Text(
              message,
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
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.primaryWhite, size: 20.w),
            SizedBox(width: 8.w),
            Text(
              message,
              style: TextStyle(fontSize: 14.sp, color: AppColors.primaryWhite),
            ),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
        duration: Duration(seconds: 3),
      ),
    );
  }
}