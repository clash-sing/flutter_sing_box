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
    Row buildStatusRow(String text1, String text2) {
      return Row(
        children: [
          Expanded(child: Text(text1),),
          Expanded(child: Text(text2),),
        ],
      );
    }
    final asyncStatus = ref.watch(connectedStreamProvider);
    return asyncStatus.when(
      data: (status) {
        return Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              buildStatusRow(
                  'Memory: ${status.memory}',
                  'Goroutines: ${status.goroutines}'
              ),
              buildStatusRow(
                  'ConnectionsIn: ${status.connectionsIn}',
                  'ConnectionsOut: ${status.connectionsOut}'
              ),
              buildStatusRow(
                  'Uplink: ${status.uplink}',
                  'Downlink: ${status.downlink}'
              ),
              buildStatusRow(
                  'UplinkTotal: ${status.uplinkTotal}',
                  'DownlinkTotal: ${status.downlinkTotal}'
              ),
            ],
          ),
        );
      },
      loading: () => Text('Connected status: loading...'),
      error: (error, stack) => Text('Connected status error: $error'),
    );
  }

  Widget _buildClashMode() {
    List<Widget> buildChildren(ClientClashMode clashMode) {
      return clashMode.modes.map((mode) {
        return OutlinedButton(
          onPressed: () {
            ref.read(flutterSingBoxProvider).setClashMode(mode);
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: mode == clashMode.currentMode
              ? Colors.blue : Colors.white
          ),
          child: Text(mode,
            style: TextStyle(color: mode == clashMode.currentMode ? Colors.white : Colors.blue),
          ),
        );
      }).toList(growable: false);
    }

    final asyncClashMode = ref.watch(clashModeStreamProvider);
    return asyncClashMode.when(
      data: (data) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: buildChildren(data),
        );
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
