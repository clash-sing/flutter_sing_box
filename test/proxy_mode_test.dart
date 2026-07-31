import 'package:flutter_sing_box/flutter_sing_box.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ProxyMode 有且仅有 tun / systemProxy 两个值', () {
    expect(ProxyMode.values, [ProxyMode.tun, ProxyMode.systemProxy]);
  });

  test('defaultMixedPort 为 8890', () {
    expect(FlutterSingBoxConstants.defaultMixedPort, 8890);
  });
}
