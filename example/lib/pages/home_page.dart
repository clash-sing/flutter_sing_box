import 'package:material_ui/material_ui.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box_example/pages/connected_overview.dart';
import 'package:flutter_sing_box_example/utils/client_providers.dart';
import 'package:permission_handler/permission_handler.dart';

import '../utils/snackbar_util.dart';

/// 首页：VPN 启停演示。
///
/// 订阅管理（列表/切换/新增）已随插件移除 Profile CRUD 一并删除——
/// 订阅数据的事实源在宿主 App 侧，example 只演示插件的真实公开 API。
class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
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
      ),
      floatingActionButton: _buildFloatingActionButton(),
      body: _buildBody(),
    );
  }

  Widget _buildFloatingActionButton() {
    Widget buildButton(ProxyState proxyState) {
      return FloatingActionButton(
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
        return FloatingActionButton(onPressed: null, child: Icon(Icons.error));
      },
      loading: () => buildButton(ProxyState.stopped),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        const Center(child: Text('订阅管理由宿主 App 负责，此处演示 VPN 启停与连接概览')),
        Positioned(bottom: 16, left: 16, child: _buildOverviewButton()),
      ],
    );
  }

  Widget _buildOverviewButton() {
    final asyncProxyState = ref.watch(proxyStateStreamProvider);
    return asyncProxyState.when(
      data: (data) {
        if (data == ProxyState.started || data == ProxyState.starting) {
          return FloatingActionButton(
            heroTag: 'overview',
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ConnectedOverview()));
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
}
