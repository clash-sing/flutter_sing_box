import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';

final flutterSingBoxProvider = Provider<FlutterSingBox>((ref) {
  // 这个实例会在整个 App 的生命周期中被共享
  return FlutterSingBox();
});

final clashModeStreamProvider = StreamProvider<ClientClashMode>((ref) {
  final singBox = ref.watch(flutterSingBoxProvider);
  // 监听这个共享实例的 Stream
  return singBox.clashModeStream;
});

final connectedStreamProvider = StreamProvider<ClientStatus>((ref) {
  // 获取共享实例
  final singBox = ref.watch(flutterSingBoxProvider);
  // 监听共享实例的 Stream
  return singBox.connectedStatusStream;
});

final proxyStateStreamProvider = StreamProvider<ProxyState>((ref) {
  final singBox = ref.watch(flutterSingBoxProvider);
  return singBox.proxyStateStream;
});

final groupStreamProvider = StreamProvider<List<ClientGroup>>((ref) {
  final singBox = ref.watch(flutterSingBoxProvider);
  return singBox.groupStream;
});

final logStreamProvider = StreamProvider<List<String>>((ref) {
  final singBox = ref.watch(flutterSingBoxProvider);
  return singBox.logStream;
});
