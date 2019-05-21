
import UIKit
import AVFoundation

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
        captureSessionInit()
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        
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
            guard let output = metadataOutput else {
                failed()
                return
            }
            /// Rect limit
            //            let rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: crosshairView.squareRect)
            //            output.rectOfInterest = rectOfInterest
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
                default: updatePreviewLayer(layer: previewLayerConnection, orientation: .portrait)
                    break
                }
            }
        }
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
            failed()
            return
        }
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        metadataOutput = AVCaptureMetadataOutput()
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr]
        } else {
            failed()
            return
        }
        captureSession.startRunning()
    }
    
    
    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
        delegate?.didFailWithErrorCode(code: "Your device does not support scanning a code from an item. Please use a device with a camera.")
        self.dismiss(animated: true, completion: nil)
        
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
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
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

