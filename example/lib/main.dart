import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:toastification/toastification.dart';

import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ///ToastificationWrapper (optional)
  ///Just to toast the callback events
  runApp(ToastificationWrapper(child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        appBarTheme: AppBarTheme(backgroundColor: Colors.brown),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      getPages: AppPages.pages,
      initialRoute: AppRoutes.home,
    );
  }
}
