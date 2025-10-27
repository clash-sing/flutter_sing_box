import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/snackbar_util.dart';
import 'config_profiles.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _flutterSingBoxPlugin = FlutterSingBox();
  final List<Profile> _profiles = [];
  Profile? _selectedProfile;


  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _flutterSingBoxPlugin.init(kDebugMode);
    _loadProfiles();

  }

  Future<void> _loadProfiles() async {
    _selectedProfile = profileManager.getSelectedProfile();
    _profiles.clear();
    _profiles.addAll(profileManager.getProfiles());
    if (!mounted) return;
    setState(() {

    });
  }

  Future<void> _switchProfile(int profileId) async {
    profileManager.setSelectedProfile(profileId);
    _loadProfiles();
    await _flutterSingBoxPlugin.stopVpn();
    await Future.delayed(Duration(seconds: 1));
    await _flutterSingBoxPlugin.startVpn();
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plugin example app'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        Expanded(
          flex: 1,
          child: _profiles.isEmpty
              ? const Center( child: Text('No subscription'),)
              : ListView.builder(
              itemCount: _profiles.length,
              itemBuilder: (context, index) {
                return _buildProfileItem(_profiles[index]);
              }
          ),
        ),
        _buildStatus(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStopButton(),
            _buildStartButton(),
            _buildConfigButton(),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileItem(Profile profile) {
    return ListTile(
      title: Text(profile.name),
      subtitle: Text(DateTime.fromMillisecondsSinceEpoch(profile.typed.lastUpdated).toString()),
      trailing: IconButton(
        icon: _selectedProfile?.id == profile.id
            ? const Icon(Icons.radio_button_checked)
            : const Icon(Icons.radio_button_unchecked),
        onPressed: _selectedProfile?.id == profile.id ? null : () {
          _switchProfile(profile.id);
        },
      ),
    );
  }

  Widget _buildStartButton() {
    return ElevatedButton(
      onPressed: _profiles.isEmpty ? null : () async {
        try {
          await requestPostNotificationPermission();
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
    );
  }

  Widget _buildStopButton() {
    return ElevatedButton(
      child: const Text('Stop VPN'),
      onPressed: () async {
        try {
          await _flutterSingBoxPlugin.stopVpn();
          SnackbarUtil.show('VPN已停止');
        } catch (e) {
          SnackbarUtil.showError('停止VPN失败: ${e.toString()}');
        }
      }
    );
  }

  Widget _buildConfigButton() {
    return ElevatedButton(
      child: const Text('Config'),
      onPressed: () async {
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ConfigProfiles())
        );
      }
    );
  }

  Widget _buildStatus() {
    return StreamBuilder<dynamic>(
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
    );

  }



  @override
  void dispose() {
    super.dispose();
  }
}
