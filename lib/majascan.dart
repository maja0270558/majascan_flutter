import 'dart:async';

import 'package:flutter/services.dart';

class Majascan {
  static const MethodChannel _channel =
      const MethodChannel('majascan');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> get scanResult async {
    final String result = await _channel.invokeMethod('getScanResult');
    return result;
  }
}
