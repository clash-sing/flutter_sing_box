import 'package:dio/dio.dart';

class SubscriptionClient {
  final Dio _dio = Dio(
    BaseOptions(
      headers: {
        'user-agent': 'ClashSing/1.0 (Flutter; iOS; Android)',
      },
    ),
  );
}