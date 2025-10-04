import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(HandwritingRecognitionApp());
}

class HandwritingRecognitionApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(384, 805.33), // Design size for reference (common mobile size)
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Handwriting Recognition',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
            useMaterial3: true,
          ),
          home: child,
          debugShowCheckedModeBanner: false,
        );
      },
      child: HomeScreen(),
    );
  }
}