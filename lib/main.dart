import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:xyz/core/bindings/app_bindings.dart';
import 'package:xyz/core/config/supabase_config.dart';
import 'package:xyz/core/router/app_pages.dart';
import 'package:xyz/core/theme/app_theme.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    final envFile = File('.env');
    if (await envFile.exists()) {
      await dotenv.load(fileName: '.env');
    }
  }
  await SupabaseConfig.init();
  await Hive.initFlutter();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, this.enableBindings = true});

  final bool enableBindings;

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'XYZ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialBinding: enableBindings ? AppBindings() : null,
      getPages: AppPages.routes,
      initialRoute: enableBindings ? '/splash' : '/',
    );
  }
}
