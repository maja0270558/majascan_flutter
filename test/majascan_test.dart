import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:majascan/majascan.dart';

void main() {
  const MethodChannel channel = MethodChannel('majascan');

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

//  test('getPlatformVersion', () async {
//    expect(await Majascan.platformVersion, '42');
//  });
}
