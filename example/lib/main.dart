import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box_example/demo_manager.dart';
import 'package:flutter_sing_box_example/pages/config_profiles.dart';
import 'package:flutter_sing_box_example/utils/snackbar_util.dart';
import 'package:mmkv/mmkv.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MMKV.initialize();
  await demoManager.loadData();
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
  final TextEditingController _controller = TextEditingController();
  @override
  void initState() {
    super.initState();
    initPlatformState();
    listenStatus();

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

  Future<void> listenStatus() async {

  }

  Future<bool> requestPostNotificationPermission() async {
    try {
      var status = await Permission.notification.request();
      if (status.isGranted) {
        return true;
      } else if (status.isDenied) {
        SnackbarUtil.showError('用户拒绝了权限（可再次请求）');
        return false;
      } else if (status.isPermanentlyDenied) {
        SnackbarUtil.showError('权限被永久拒绝，需引导用户去设置中开启');
        openAppSettings(); // 跳转到应用设置页面
        return false;
      }
    } catch (e) {
      SnackbarUtil.showError('获取权限失败: ${e.toString()}');
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      home: Scaffold(
        appBar: AppBar(title: const Text('Plugin example app')),
        body: Builder(builder: (scaffoldContext) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Running on: $_platformVersion\n'),
                StreamBuilder<dynamic>(
                  stream: _flutterSingBoxPlugin.vpnStatusStream,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final status = snapshot.data as Map;
                      final uplink = status['uplink'];
                      final downlink = status['downlink'];
                      return Column(
                        children: [
                          Text('Uplink: $uplink B/s'),
                          Text('Downlink: $downlink B/s'),
                        ],
                      );
                    }
                    return const Text('VPN Status: Disconnected');
                  },
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: 'Subscription Link',
                    border: OutlineInputBorder(),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (_controller.text.isNotEmpty) {
                        final uri = Uri.tryParse(_controller.text);
                        if (uri != null && uri.hasAbsolutePath && ['http', 'https'].contains(uri.scheme)) {
                          final singBox = await _flutterSingBoxPlugin.importProfile(uri.toString());
                          SnackbarUtil.show('订阅链接已导入');
                        } else {
                          SnackbarUtil.showError('订阅链接格式错误');
                        }
                      } else {
                        SnackbarUtil.showError('请输入订阅链接');
                      }
                    } catch (e) {
                      SnackbarUtil.showError('导入失败: ${e.toString()}');
                    }
                  },
                  child: const Text('Import profile'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      if (singBoxManager.profile == null) {
                        SnackbarUtil.showError('请先导入订阅链接');
                        return;
                      }
                      bool isGranted = await requestPostNotificationPermission();
                      if (!isGranted) {
                        return;
                      }
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
                ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          scaffoldContext,
                          MaterialPageRoute(builder: (context) => ConfigProfiles())
                      );
                    },
                    child: const Text('新增订阅')),
              ],
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
