import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('loadYaml', () async {
    var yaml = await rootBundle.loadString('assets/.local/test_sub.yaml');
    debugPrint(yaml);
  });
}