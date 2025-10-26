import 'package:flutter/material.dart';

import 'package:flutter_sing_box_example/pages/home_page.dart';
import 'package:flutter_sing_box_example/utils/snackbar_util.dart';
import 'package:mmkv/mmkv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MMKV.initialize();
  runApp(const MyApp());
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
      home: HomePage(),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
