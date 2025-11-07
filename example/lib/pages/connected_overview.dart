import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_sing_box_example/utils/client_providers.dart';

class ConnectedOverview extends ConsumerStatefulWidget {
  const ConnectedOverview({super.key});

  @override
  ConsumerState<ConnectedOverview> createState() => _ConnectedOverviewState();
}

class _ConnectedOverviewState extends ConsumerState<ConnectedOverview> {
  // final _flutterSingBoxPlugin = FlutterSingBox();
  Profile? _profile;
  @override
  initState() {
    super.initState();
    _profile = profileManager.getSelectedProfile();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_profile?.name ?? '服务未启动'),
      ),
      body: SizedBox(
        height: double.infinity,
        width: double.infinity,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildConnectedStatus(),
              _buildClashMode(),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildConnectedStatus() {
    final asyncStatus = ref.watch(connectedStreamProvider);
    return asyncStatus.when(
      data: (status) {
        return Text(
          'memory: ${status.memory}',
        );
      },
      loading: () => Text('Connected: loading...'),
      error: (error, stack) => Text('Connected: Error: $error'),
    );
  }

  Widget _buildClashMode() {
    final lastMode = ref.watch(clashModeStreamProvider);
    return lastMode.when(
      data: (data) {
        return Text('Clash Mode: ${data.modes}, ${data.currentMode}');
      },
      loading: () => Text('Clash Mode loading...'),
      error: (error, stack) => Text('Clash Mode Error: $error'),
    );
  }


  @override
  void dispose() {
    super.dispose();
  }
}
