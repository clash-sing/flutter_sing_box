import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box_example/pages/home_page.dart';
import 'package:flutter_sing_box_example/utils/snackbar_util.dart';
import 'package:mmkv/mmkv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MMKV.initialize();
  // await demoManager.loadData();
  await FlutterSingBox().init(kDebugMode);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  final _flutterSingBoxPlugin = FlutterSingBox();

  @override
  void initState() {
    super.initState();
    // initPlatformState();

  }

  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _flutterSingBoxPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: HomePage(),
/*
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Builder(builder: (scaffoldContext) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Running on: $_platformVersion\n'),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Subscription Link',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
*/
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
