import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box_example/utils/snackbar_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterSingBox().setup();
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
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    // We also handle the message potentially returning null.
    try {
      platformVersion =
          await _flutterSingBoxPlugin.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Builder(builder: (scaffoldContext) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Running on: $_platformVersion\n'),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      final content = await _flutterSingBoxPlugin.importProfile("");
                      SnackbarUtil.show('VPN已准备就绪');
                    } catch (e) {
                      SnackbarUtil.showError('初始化VPN失败: ${e.toString()}');
                    }
                  },
                  child: const Text('Import profile'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _flutterSingBoxPlugin.startVpn();
                      SnackbarUtil.show('VPN启动中...');
                    } on PlatformException catch (e) {
                      String errorMessage = '启动VPN失败';
                      if (e.code == 'NO_ACTIVITY') {
                        errorMessage = '无法获取Activity实例';
                      } else if (e.code == 'VPN_PERMISSION_DENIED') {
                        errorMessage = '用户拒绝了VPN权限';
                      } else if (e.code == 'VPN_ERROR') {
                        errorMessage = e.message ?? '启动VPN服务失败';
                      }
                      SnackbarUtil.showError(errorMessage);
                    } catch (e) {
                      SnackbarUtil.showError('未知错误: ${e.toString()}');
                    }
                  },
                  child: const Text('Start VPN'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      await _flutterSingBoxPlugin.stopVpn();
                      SnackbarUtil.show('VPN已停止');
                    } catch (e) {
                      SnackbarUtil.showError('停止VPN失败: ${e.toString()}');
                    }
                  },
                  child: const Text('Stop VPN'),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
