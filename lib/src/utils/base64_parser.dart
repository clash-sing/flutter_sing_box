import 'package:flutter/material.dart';

class Base64Parser {
  static String parse(String base64) {
    final List<String> lines = base64.split('\n');
    for (var line in  lines) {
      final uri = Uri.tryParse(line);
      if (uri == null) {
        if (line.toUpperCase().startsWith('STATUS')) {
          // user info
          debugPrint(line);
        } else {
          continue;
        }
      } else {
        // parse uri
        debugPrint(uri.toString());
      }
    }
    return base64;
  }
}