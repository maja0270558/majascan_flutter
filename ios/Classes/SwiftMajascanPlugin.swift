import Flutter
import UIKit

public class SwiftMajascanPlugin: NSObject, FlutterPlugin {
    var result: FlutterResult?
    var hostViewController: UIViewController!
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "majascan", binaryMessenger: registrar.messenger())
        let instance = SwiftMajascanPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        if let delegate = UIApplication.shared.delegate , let window = delegate.window, let root = window?.rootViewController {
             instance.hostViewController = root
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "scan":
            self.result = result
            let scanController = MAJAScannerController()
            scanController.delegate = self
            let navigationController = UINavigationController(rootViewController: scanController)
            navigationController.navigationBar.backgroundColor = UIColor.clear
            navigationController.navigationBar.setBackgroundImage(UIImage(), for: .default)
            navigationController.navigationBar.shadowImage = UIImage()
//            navigationController.navigationBar.isTranslucent = true
           
            if hostViewController != nil {
                hostViewController.present(navigationController, animated: true, completion: nil)
            }
        default:
            result(FlutterMethodNotImplemented)
            break
        }
    }
}

extension SwiftMajascanPlugin: MAJAScannerDelegate {
    func didScanBarcodeWithResult(code: String) {
        if let channelResult = result {
            channelResult(code as NSString)
        }
    }
    
    func didFailWithErrorCode(code: String) {
        if let channelResult = result {
            channelResult(code as NSString)
        }    }
}
