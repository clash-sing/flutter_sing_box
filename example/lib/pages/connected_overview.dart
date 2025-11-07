import 'package:flutter/material.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';

class ConnectedOverview extends StatefulWidget {
  const ConnectedOverview({super.key});

  @override
  State<ConnectedOverview> createState() => _ConnectedOverviewState();
}

class _ConnectedOverviewState extends State<ConnectedOverview> {
  final _flutterSingBoxPlugin = FlutterSingBox();
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
              _buildStatus(),
            ],
          ),
        ),
      )
    );
  }

  Widget _buildStatus() {
    Row buildStatusRow(String text1, String text2) {
      return Row(
            children: [
              Expanded(child: Text(text1),),
              Expanded(child: Text(text2),),
            ],
          );
    }
    return StreamBuilder<ClientStatus>(
      stream: _flutterSingBoxPlugin.connectedStatusStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                buildStatusRow(
                    'TrafficAvailable: ${snapshot.data?.trafficAvailable ?? '--'}',
                    ''
                ),
                buildStatusRow(
                    'Memory: ${snapshot.data?.memory ?? '--'}',
                    'Goroutines: ${snapshot.data?.goroutines ?? '--'}'
                ),
                buildStatusRow(
                    'ConnectionsIn: ${snapshot.data?.connectionsIn ?? '--'}',
                    'ConnectionsOut: ${snapshot.data?.connectionsOut ?? '--'}'
                ),
                buildStatusRow(
                    'Uplink: ${snapshot.data?.uplink ?? '--'}',
                    'Downlink: ${snapshot.data?.downlink ?? '--'}'
                ),
                buildStatusRow(
                    'UplinkTotal: ${snapshot.data?.uplinkTotal ?? '--'}',
                    'DownlinkTotal: ${snapshot.data?.downlinkTotal ?? '--'}'
                ),
              ],
            ),
          );
        } else {
          return const Text('VPN Status: Disconnected');
        }
      },
    );

  }


  @override
  void dispose() {
    super.dispose();
  }
}
