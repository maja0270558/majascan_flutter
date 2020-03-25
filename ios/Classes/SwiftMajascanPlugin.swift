import Flutter
import UIKit

public class SwiftMajascanPlugin: NSObject, FlutterPlugin {
    var registrar: FlutterPluginRegistrar!

    var result: FlutterResult?
    var hostViewController: UIViewController!

    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "majascan", binaryMessenger: registrar.messenger())
        let instance = SwiftMajascanPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
        if let delegate = UIApplication.shared.delegate , let window = delegate.window, let root = window?.rootViewController {
            instance.hostViewController = root
            instance.registrar = registrar
        }
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "scan":
            self.result = result
            let scanController = MAJAScannerController()
            scanController.delegate = self
            let navigationController = UINavigationController(rootViewController: scanController)
            scanController.modalPresentationStyle = .fullScreen
            navigationController.modalPresentationStyle = .fullScreen
            if let arguDictinary = call.arguments as? NSDictionary {
               scanController.argumentDictionary = arguDictinary
            }
    
            if hostViewController != nil {
                let backIconKey = registrar.lookupKey(forAsset: "assets/back.png", fromPackage: "majascan")
                if let backIconPath = Bundle.main.path(forResource: backIconKey, ofType: nil) {
                    scanController.backImage = UIImage(imageLiteralResourceName: backIconPath)
                }
                let flashlightKey = registrar.lookupKey(forAsset: "assets/flashlight.png", fromPackage: "majascan")
                if let flashlightPath = Bundle.main.path(forResource: flashlightKey, ofType: nil) {
                    scanController.flashlightImage = UIImage(imageLiteralResourceName: flashlightPath)
                }
                
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
        }
    }
}
