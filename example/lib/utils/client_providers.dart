import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sing_box/flutter_sing_box.dart';

final clashModeStreamProvider = StreamProvider<ClientClashMode>((ref) {
  return FlutterSingBox().clashModeStream;
});

final connectedStreamProvider = StreamProvider<ClientStatus>((ref) {
  return FlutterSingBox().connectedStatusStream;
});