
import UIKit
import AVFoundation

enum MAJAScanError: Error {
    case authorizationDenied(message: String)
    case deviceNotFount(message: String)
}


enum MAJAScanArguKey: String {
    case title = "TITLE"
    case barColor = "BAR_COLOR"
    case titleColor = "TITLE_COLOR"
    case flashLightEnable = "FLASHLIGHT"
    
    func getKeyValue<T>(dictionary: NSDictionary) -> T? {
        guard let result =  dictionary[self.rawValue] as? T else {
            return nil
        }
        return result
    }
}

protocol MAJAScannerDelegate: class {
    func didScanBarcodeWithResult(code: String)
    func didFailWithErrorCode(code: String)
}

class MAJAScannerController: UIViewController {
    weak var delegate: MAJAScannerDelegate?
    // Camera
    var captureSession: AVCaptureSession!
    var metadataOutput: AVCaptureMetadataOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    // Flutter
    var argumentDictionary: NSDictionary = [:]
    // UI
    var crosshairView: CrosshairView! = nil
    let backButton: UIButton = UIButton(type: .custom)
    let flashlightButton: UIButton = UIButton(type: .custom)
    let navButtonFrame = CGRect(x: 0, y: 0, width: 20 , height: 20)
    var tintColor: UIColor = UIColor.white
    var barColor: UIColor = UIColor.clear
    var barTitle: String = "掃描 QRcode"
    var flashLightEnable: Bool = true
    var backImage: UIImage?
    var flashlightImage: UIImage?
    
    @IBOutlet weak var previewView: UIView!
    
    /*
     Life cycle
     */
    override  func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        settingArgumentValue()
    }
    
    func previewLayerInit(){
        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
        if previewLayer == nil {
            /// add preview layer
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = self.previewView.bounds
            previewLayer.videoGravity = .resizeAspectFill
            previewView.layer.addSublayer(previewLayer)
            /// overlay rect
            crosshairView = CrosshairView(frame: UIScreen.main.bounds)
            previewView.addSubview(crosshairView!)
            crosshairView.autoLayout.fillSuperview()
            //            guard let output = metadataOutput else {
            //                failed()
            //                return
            //            }
            /// Rect limit
            //            let rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: crosshairView.squareRect)
            //            output.rectOfInterest = rectOfInterest
        }
    }
    
    func checkCameraAuth(success: @escaping ()->Void, fail: @escaping () -> Void){
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            captureSessionInit()
            success()
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    self.captureSessionInit()
                    success()
                } else {
                    fail()
                }
            }
            
        case .denied: // The user has previously denied access.
            fail()
            return
            
        case .restricted: // The user can't grant access due to restrictions.
            fail()
            return
        }
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        updatePreviewLayerOrientation()
        checkCameraAuth(success: {
            self.previewLayerInit()
        }) {
            self.failed(error: MAJAScanError.authorizationDenied(message: "請開啟相機權限才能使用掃瞄QR-code"))
        }
        
        
    }
    
    override  func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    override  func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePreviewLayerOrientation()
    }
    
    /*
     Init Method
     */
    init() {
        super.init(nibName: "MAJAScannerController", bundle: Bundle(for: MAJAScannerController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func updatePreviewLayerOrientation(){
        if let connection =  self.previewLayer?.connection  {
            let currentDevice: UIDevice = UIDevice.current
            let orientation: UIDeviceOrientation = currentDevice.orientation
            let previewLayerConnection : AVCaptureConnection = connection
            
            if previewLayerConnection.isVideoOrientationSupported {
                switch (orientation) {
                case .portrait: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                case .landscapeRight: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                    break
                case .landscapeLeft: updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                    break
                case .portraitUpsideDown: updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                    break
                default:
                    let statusBarOrientation = UIApplication.shared.statusBarOrientation
                    switch statusBarOrientation {
                    case .landscapeLeft:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeLeft)
                    case .landscapeRight:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .landscapeRight)
                    case .portrait:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    case .portraitUpsideDown:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portraitUpsideDown)
                    case .unknown:
                        updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    }
                    break
                }
            }
        }
    }
    
    
    private func updatePreviewLayer(layer: AVCaptureConnection, orientation: AVCaptureVideoOrientation) {
        
        layer.videoOrientation = orientation
        
        previewLayer.frame = self.view.bounds
    }
    
    /*
     Button action
     */
    @objc func backAction() -> Void {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func flashlightAction () -> Void {
        guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
        guard device.hasTorch else { return }
        do {
            try device.lockForConfiguration()
            
            if (device.torchMode == AVCaptureDevice.TorchMode.on) {
                device.torchMode = AVCaptureDevice.TorchMode.off
                flashlightButton.isSelected = false
            } else {
                do {
                    try device.setTorchModeOn(level: 1.0)
                    flashlightButton.isSelected = true
                } catch {
                    print(error)
                }
            }
            
            device.unlockForConfiguration()
        } catch {
            print(error)
        }
    }
    
    
    
    func settingArgumentValue() {
        if let tintColorHex: String = MAJAScanArguKey.titleColor.getKeyValue(dictionary: argumentDictionary)  {
            tintColor = UIColor(hexString: tintColorHex) ?? UIColor.white
        }
        
        if let barColorHex: String = MAJAScanArguKey.barColor.getKeyValue(dictionary: argumentDictionary)  {
            print(barColorHex)
            barColor = UIColor(hexString: barColorHex) ?? UIColor.clear
        }
        
        if let newBarTitle: String = MAJAScanArguKey.title.getKeyValue(dictionary: argumentDictionary)  {
            barTitle = newBarTitle
        }
        
        if let flashLightEnableString: String = MAJAScanArguKey.flashLightEnable.getKeyValue(dictionary: argumentDictionary), let enableInt = Int(flashLightEnableString)  {
            
            flashLightEnable = enableInt == 0 ? false : true
        }
    }
    
    
    func configureNavigationBar() {
        self.navigationController?.navigationBar.barTintColor = barColor
        
        if barColor == UIColor.clear {
            self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
            self.navigationController?.navigationBar.shadowImage = UIImage()
            self.navigationController?.navigationBar.isTranslucent = true
        }
        
        
        backButton.setImage(backImage?.maskWithColor(color: tintColor), for: .normal)
        backButton.setTitle("", for: .normal)
        backButton.setTitleColor(backButton.tintColor, for: .normal)
        backButton.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        backButton.imageView?.contentMode = .scaleAspectFit
        backButton.frame = navButtonFrame
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        
        if flashLightEnable {
            flashlightButton.setImage(flashlightImage?.maskWithColor(color: tintColor), for: .normal)
            flashlightButton.setImage(flashlightImage?.maskWithColor(color: UIColor.yellow), for: .selected)
            flashlightButton.setTitle("", for: .normal)
            flashlightButton.setTitleColor(flashlightButton.tintColor, for: .normal)
            flashlightButton.addTarget(self, action: #selector(flashlightAction), for: .touchUpInside)
            flashlightButton.imageView?.contentMode = .scaleAspectFit
            flashlightButton.frame = navButtonFrame
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: flashlightButton)
        }
        
        self.navigationItem.title = barTitle
        let textAttributes = [NSAttributedString.Key.foregroundColor:tintColor]
        navigationController?.navigationBar.titleTextAttributes = textAttributes
    }
    
    func captureSessionInit(){
        captureSession = AVCaptureSession()
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            failed(error: MAJAScanError.deviceNotFount(message: "目前裝置不支援 QR code 掃描, 請使用有攝影機的裝置"))
            return
        }
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed(error: MAJAScanError.deviceNotFount(message: "目前裝置不支援 QR code 掃描, 請使用有攝影機的裝置"))
            return
        }
        metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed(error: MAJAScanError.deviceNotFount(message: "目前裝置不支援 QR code 掃描, 請使用有攝影機的裝置"))
            return
        }
        captureSession.startRunning()
    }
    
    
    func failed(error: MAJAScanError) {
        
        switch error {
        case .authorizationDenied(let message):
            let alertController = UIAlertController(title: "掃瞄QR碼", message: "\(message)", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "前往設定", style: .default) { (action) in
                UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
                self.dismiss(animated: true, completion: nil)
            }
            let cancelAction = UIAlertAction(title: "取消", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(confirmAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true)
            
        case .deviceNotFount(let message):
            let alertController = UIAlertController(title: "掃瞄QR碼", message: "\(message)", preferredStyle: .alert)
            let confirmAction = UIAlertAction(title: "確定", style: .default) { (action) in
                self.dismiss(animated: true, completion: nil)
            }
            alertController.addAction(confirmAction)
            present(alertController, animated: true)
            
        }
        captureSession = nil
    }
    
    func success() {
        let ac = UIAlertController(title: "", message: "是否立即前往", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (action) in
            self.captureSession.startRunning()
        }
        let confirmAction = UIAlertAction(title: "前往", style: .default) { (action) in
            self.captureSession.startRunning()
            self.dismiss(animated: true, completion: nil)
        }
        ac.addAction(cancelAction)
        ac.addAction(confirmAction)
        present(ac, animated: true)
    }
}

extension MAJAScannerController: AVCaptureMetadataOutputObjectsDelegate{
    @objc func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        captureSession.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didScanBarcodeWithResult(code: stringValue)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

