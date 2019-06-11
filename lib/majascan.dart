import 'dart:async';
import 'dart:ui';
import 'package:flutter/services.dart';

import 'package:flutter/widgets.dart';

class MajaScan {
  static const MethodChannel _channel = const MethodChannel('majascan');
  static const CameraAccessDenied = 'PERMISSION_NOT_GRANTED';

  static Future<String> startScan(
      {String title = "",
      bool flashlightEnable = true,
      Color barColor,
      Color titleColor}) async {
    

    int flashlight = (flashlightEnable ? 1 : 0);

    Map<String, String> scanArgs = {
      ScanArgs.TITLE: title,
      ScanArgs.FLASHLIGHT: flashlight.toString(),
    };

    if (barColor != null) {
      scanArgs[ScanArgs.BAR_COLOR] = '#${barColor.value.toRadixString(16)}';
    }

    if (titleColor != null) {
      scanArgs[ScanArgs.TITLE_COLOR] = '#${titleColor.value.toRadixString(16)}';
    }

    final String result = await _channel.invokeMethod('scan', scanArgs);
    return result;
  }
}

class ScanArgs {
  static const FLASHLIGHT = "FLASHLIGHT";
  static const TITLE = "TITLE";
  static const TITLE_COLOR = "TITLE_COLOR";
  static const BAR_COLOR = "BAR_COLOR";
}
