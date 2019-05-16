
import UIKit
import AVFoundation

protocol MAJAScannerDelegate: class {
    func didScanBarcodeWithResult(code: String)
    func didFailWithErrorCode(code: String)
}

class MAJAScannerController: UIViewController {
    weak var delegate: MAJAScannerDelegate?
    var captureSession: AVCaptureSession!
    var metadataOutput: AVCaptureMetadataOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var crosshairView: CrosshairView? = nil
    
    @IBOutlet weak var previewView: UIView!
    
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
    
    
    override  func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
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
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        
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
            self.previewView.addSubview(crosshairView!)
            crosshairView?.autoLayout.fillSuperview()
            
            
            /// let rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: targetRect)
            guard metadataOutput != nil else {
                failed()
                return
            }
        }
        
    }
    
    override  func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
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

