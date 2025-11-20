import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box_example/pages/connected_overview.dart';
import 'package:flutter_sing_box_example/utils/client_providers.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/snackbar_util.dart';
import 'config_profiles.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final _flutterSingBoxPlugin = FlutterSingBox();
  final List<Profile> _profiles = [];
  Profile? _selectedProfile;


  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    _selectedProfile = ProfileManager().getSelectedProfile();
    _profiles.clear();
    _profiles.addAll(ProfileManager().getProfiles());
    if (!mounted) return;
    setState(() {

    });
  }

  Future<void> _switchProfile(int profileId) async {
    ProfileManager().setSelectedProfile(profileId);
    _loadProfiles();
    if (ref.read(proxyStateStreamProvider).value == ProxyState.started) {
      try {
        await ref.read(flutterSingBoxProvider).stopVpn();
        debugPrint('stopVpn');
        await Future.delayed(const Duration(milliseconds: 1500));
        await ref.read(flutterSingBoxProvider).startVpn();
        debugPrint('startVpn');
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }

  Future<void> _startVpn() async {
    try {
      await requestPostNotificationPermission();
      await ref.read(flutterSingBoxProvider).startVpn();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () async {
              await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConfigProfiles())
              );
              _loadProfiles();
            },
          ),
        ],
      ),
      floatingActionButton: _buildFloatingActionButton(),
      body: _buildBody(),
    );
  }

  Widget _buildFloatingActionButton() {
    Widget buildButton(ProxyState proxyState) {
      return  FloatingActionButton(
        onPressed: () async {
          if (proxyState == ProxyState.started || proxyState == ProxyState.starting) {
            await FlutterSingBox().stopVpn();
          } else {
            await _startVpn();
          }
        },
        child: (proxyState == ProxyState.started || proxyState == ProxyState.starting)
            ? const Icon(Icons.stop)
            : const Icon(Icons.play_arrow),
      );
    }
    final asyncProxyState = ref.watch(proxyStateStreamProvider);
    return asyncProxyState.when(
      data: (data) {
        return buildButton(data);
      },
      error: (error, stack) {
        return FloatingActionButton( onPressed: null, child: Icon(Icons.error),);
      },
      loading: () => buildButton(ProxyState.stopped),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Column(
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
          ],
        ),
        Positioned(
          bottom: 16,
          left: 16,
          child: _buildOverviewButton(),
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
        onPressed: () {
          if (_selectedProfile?.id != profile.id) {
            _switchProfile(profile.id);
          }
        },
      ),
    );
  }

  Widget _buildOverviewButton() {
    final asyncProxyState = ref.watch(proxyStateStreamProvider);
    return asyncProxyState.when(
      data: (data) {
        if ( data == ProxyState.started || data == ProxyState.starting) {
          return FloatingActionButton(
            heroTag: 'overview',
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ConnectedOverview())
              );
            },
            child: const Icon(Icons.data_exploration),
          );
        } else {
          return const SizedBox.shrink();
        }
      },
      error: (error, stack) {
        return const SizedBox.shrink();
      },
      loading: () => const SizedBox.shrink(),
    );
  }

  Widget _buildLogs() {
    return StreamBuilder<List<String>>(
      stream: _flutterSingBoxPlugin.logStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final str = snapshot.data?.first ?? 'EMPTY!';
          return Text(str);
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
