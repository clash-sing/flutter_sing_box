
import 'package:flutter/material.dart';

// 1. 定义一个全局的 GlobalKey
// 这个 key 将持有 ScaffoldMessenger 的状态，允许我们从任何地方访问它。
final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

class SnackbarService {
  /// 显示一个标准的 SnackBar
  static void show(String message) {
    // 检查 key.currentState 是否存在，因为在 app 的极早期阶段可能还不存在
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  /// 显示一个表示错误的 SnackBar
  static void showError(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade700, // 使用醒目的错误颜色
        duration: const Duration(seconds: 4),
      ),
    );
  }

  /// 显示一个表示成功的 SnackBar
  static void showSuccess(String message) {
    scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade700, // 使用醒目的成功颜色
        duration: const Duration(seconds: 3),
      ),
    );
  }

}

