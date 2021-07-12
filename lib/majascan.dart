import 'dart:async';
import 'dart:ffi';
import 'dart:ui';
import 'package:flutter/services.dart';

import 'package:flutter/widgets.dart';

class MajaScan {
  static const MethodChannel _channel = const MethodChannel('majascan');
  static const CameraAccessDenied = 'PERMISSION_NOT_GRANTED';

  static Future<String?> startScan({
    String title = "",
    bool flashlightEnable = true,
    Color? barColor,
    Color? titleColor,
    Color? qRCornerColor,
    Color? qRScannerColor,
    double scanAreaScale = 0.7,
  }) async {
    int flashlight = (flashlightEnable ? 1 : 0);

    Map<String, String> scanArgs = {
      ScanArgs.TITLE: title,
      ScanArgs.FLASHLIGHT: flashlight.toString(),
      ScanArgs.SCAN_AREA_SCALE: scanAreaScale.toString(), 
    };

    if (barColor != null) {
      scanArgs[ScanArgs.BAR_COLOR] = '#${barColor.value.toRadixString(16)}';
    }

    if (titleColor != null) {
      scanArgs[ScanArgs.TITLE_COLOR] = '#${titleColor.value.toRadixString(16)}';
    }

    if (qRCornerColor != null) {
      scanArgs[ScanArgs.QR_CORNER_COLOR] =
          '#${qRCornerColor.value.toRadixString(16)}';
    }

    if (qRScannerColor != null) {
      scanArgs[ScanArgs.QR_SCANNER_COLOR] =
      '#${qRScannerColor.value.toRadixString(16)}';
    }

    final String? result = await _channel.invokeMethod('scan', scanArgs);
    return result;
  }
}

class ScanArgs {
  static const FLASHLIGHT = "FLASHLIGHT";
  static const TITLE = "TITLE";
  static const TITLE_COLOR = "TITLE_COLOR";
  static const BAR_COLOR = "BAR_COLOR";
  static const QR_CORNER_COLOR = "QR_CORNER_COLOR";
  static const QR_SCANNER_COLOR = "QR_SCANNER_COLOR";
  static const SCAN_AREA_SCALE = "SCAN_AREA_SCALE";
}
