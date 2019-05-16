import Flutter
import UIKit

public class SwiftMajascanPlugin: NSObject, FlutterPlugin {
  var result: FlutterResult!
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "majascan", binaryMessenger: registrar.messenger())
    let instance = SwiftMajascanPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    result("iOS " + UIDevice.current.systemVersion)
    switch call.method {
    case "scan":
        self.result = result
    default:
        result(FlutterMethodNotImplemented)
        break
    }
  }
}
