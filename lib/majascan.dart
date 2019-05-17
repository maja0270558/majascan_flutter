import 'dart:async';

import 'package:flutter/services.dart';

class MajaScan {
  static const MethodChannel _channel = const MethodChannel('majascan');
  static const CameraAccessDenied = 'PERMISSION_NOT_GRANTED';

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Future<String> startScan(Map<String, String> map) async {
    final String result = await _channel.invokeMethod('scan', map);
    return result;
  }
}

class ScanArgs {
  static const FLASHLIGHT = "FLASHLIGHT";
  static const TITLE = "TITLE";
  static const TITLE_COLOR = "TITLE_COLOR";
  static const BAR_COLOR = "BAR_COLOR";
}
