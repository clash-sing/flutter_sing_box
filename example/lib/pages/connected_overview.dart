import 'dart:convert';
import 'dart:io';

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
  Profile? _profile;
  SingBox? _singBox;
  final List<GroupItem> _groupItems = [];

  @override
  initState() {
    super.initState();
    _profile = profileManager.getSelectedProfile();
    _initData();
  }

  Future<void> _initData() async {
    final path = _profile?.typed.path;
    if (path?.isNotEmpty != true) return;
    final file = File(path!);
    if (! await file.exists()) return;
    try {
      final map = jsonDecode(await file.readAsString());
      _singBox = SingBox.fromJson(map);
      _groupItems.addAll(
          _singBox!.outbounds.where(
                  (outbound) => outbound.outbounds?.isNotEmpty == true)
              .map((outbound) => GroupItem(outbound: outbound, isExpanded: false)
          )
      );

      if (!mounted) return;
      setState(() {

      });
    } catch (e) {
      debugPrint('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_profile?.name ?? '服务未启动'),
      ),
      body: SingleChildScrollView(
          child: Column(
            children: [
              _buildConnectedStatus(),
              _buildClashMode(),
              _buildGroups(),
            ],
          ),
        ),
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

  Widget _buildGroups() {
    final asyncGroup = ref.watch(groupStreamProvider);
    if (_singBox == null) {
      return const SizedBox.shrink();
    }
    final List<ClientGroup> clientGroups = asyncGroup.value ?? [];
    if (clientGroups.isNotEmpty) {
      for (var clientGroup in clientGroups) {
        final index = _groupItems.indexWhere((item) => item.outbound.tag == clientGroup.tag);
        if (index > -1) {
          _groupItems[index].selected = clientGroup.selected;
        }
      }
    }
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpansionPanelList(
          expansionCallback: (int index, bool isExpanded) {
            setState(() {
              _groupItems[index].isExpanded = isExpanded;
            });
          },
          children: _groupItems.map((item) {
            return ExpansionPanel(
              canTapOnHeader: true,
              headerBuilder: (BuildContext context, bool isExpanded) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    spacing: 8.0,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(item.outbound.tag),),
                          Text((item.outbound.outbounds?.length ?? 0).toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Text(item.outbound.type),
                          SizedBox(width: 12.0,),
                          Expanded(
                            child: Text(item.selected ?? '',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              body: _buildOutboundItem(item),
              isExpanded: item.isExpanded,
            );
          }).toList(),
      ),
    );
  }

  Widget _buildOutboundItem(GroupItem groupItem) {
    final List<Outbound> outbounds = [];
    groupItem.outbound.outbounds?.forEach((outboundTag) {
      final index = _singBox?.outbounds.indexWhere((outbound) {
        return outbound.tag == outboundTag;
      });
      if (index != null && index > -1) {
        final outbound = _singBox?.outbounds[index];
        if (outbound != null) {
          outbounds.add(outbound);
        }
      }
    });
    if (outbounds.isEmpty) {
      return const SizedBox.shrink();
    }
    return SizedBox(
      width: double.infinity,
      child: GridView.count(
        childAspectRatio: 3.0,
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: outbounds.map((outbound) {
          return Card(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              color: groupItem.selected == outbound.tag ? Colors.blueAccent : Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: SizedBox()),
                  Text(outbound.tag,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12.0, color: groupItem.selected == outbound.tag ? Colors.white : Colors.black),
                  ),
                  Expanded(child: SizedBox()),
                  Text(outbound.type,
                    style: TextStyle(fontSize: 12.0, color: groupItem.selected == outbound.tag ? Colors.white : Colors.black),
                  ),
                  Expanded(child: SizedBox()),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class GroupItem {
  Outbound outbound;
  bool isExpanded;
  String? selected;
  GroupItem({
    required this.outbound,
    required this.isExpanded,
    this.selected,
  });
}
