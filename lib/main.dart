import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'constants/colors.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(HandwritingRecognitionApp());
}

class HandwritingRecognitionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 800),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Inkling - Handwriting Recognition',
          theme: AppTheme.lightTheme,
          home: child,
          debugShowCheckedModeBanner: false,
        );
      },
      child: HomeScreen(),
    );
  }
}