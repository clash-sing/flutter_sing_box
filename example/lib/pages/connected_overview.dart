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
    _profile = ProfileManager().getSelectedProfile();
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

  void _selectOutbound(GroupItem groupItem, String outboundTag) {
    try {
      setState(() {
        groupItem.selected = outboundTag;
      });
      ref.read(flutterSingBoxProvider).selectOutbound(groupTag: groupItem.outbound.tag, outboundTag: outboundTag);
    } catch(e) {
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
    if (_singBox == null) {
      return const SizedBox.shrink();
    }
    ref.watch(groupStreamProvider).when(
      data: (clientGroups) {
        for (var clientGroup in clientGroups) {
          final index = _groupItems.indexWhere((item) => item.outbound.tag == clientGroup.tag);
          if (index > -1) {
            _groupItems[index].selected = clientGroup.selected;
            _groupItems[index].isExpanded = clientGroup.isExpand;
            _groupItems[index].items = clientGroup.items ??  [];
          }
        }
      },
      loading: () {},
      error: (error, stack) {},
    );
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ExpansionPanelList(
        expansionCallback: (int index, bool isExpanded) {
          setState(() {
            _groupItems[index].isExpanded = isExpanded;
          });
          ref.read(flutterSingBoxProvider).setGroupExpand(
            groupTag: _groupItems[index].outbound.tag,
            isExpand: isExpanded,
          );
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
                        IconButton(
                          icon: Icon(Icons.speed),
                          onPressed: () {
                            ref.read(flutterSingBoxProvider).urlTest(
                              groupTag: item.outbound.tag,
                            );
                          },
                        ),
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
            child: InkWell(
              onTap: groupItem.outbound.type != OutboundType.selector ? null :() {
                _selectOutbound(groupItem, outbound.tag);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                color: groupItem.selected == outbound.tag ? Colors.blueAccent : Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Spacer(),
                    Text(outbound.tag,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.0, color: groupItem.selected == outbound.tag ? Colors.white : Colors.black),
                    ),
                    Spacer(),
                    Row(
                      children: [
                        Text(outbound.type,
                          style: TextStyle(fontSize: 12.0, color: groupItem.selected == outbound.tag ? Colors.white : Colors.black),
                        ),
                        SizedBox(width: 8.0,),
                        Text(
                          groupItem.items.firstWhere(
                                  (clientGroupItem) => clientGroupItem.tag == outbound.tag,
                              orElse: () => ClientGroupItem(tag: '', type: '', urlTestTime: 0, urlTestDelay: 0,)
                          ).urlTestDelay.toString()
                        ),
                      ],
                    ),
                    Spacer(),
                  ],
                ),
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
  List<ClientGroupItem> items;
  GroupItem({
    required this.outbound,
    required this.isExpanded,
    this.selected,
    this.items = const [],
  });
}
