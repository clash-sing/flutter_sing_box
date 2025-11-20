import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';

import 'package:flutter_sing_box_example/pages/home_page.dart';
import 'package:flutter_sing_box_example/utils/snackbar_util.dart';
import 'package:mmkv/mmkv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final rootDir = await MMKV.initialize();
  debugPrint('mmkv rootDir: $rootDir');
  await FlutterSingBox().init();
  runApp(const ProviderScope(
    child: MyApp(),
  ));
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
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: ThemeData.light(
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(
        useMaterial3: true,
      ),
      home: HomePage(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
