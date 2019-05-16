
import UIKit
import AVFoundation

protocol MAJAScannerDelegate: class {
    func didScanBarcodeWithResult(code: String)
    func didFailWithErrorCode(code: String)
}

public class MAJAScannerController: UIViewController {
    weak var delegate: MAJAScannerDelegate?
    var captureSession: AVCaptureSession!
    var metadataOutput: AVCaptureMetadataOutput!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var crosshairView: CrosshairView? = nil
    
    @IBOutlet weak var previewView: UIView!
    
    public init() {
        super.init(nibName: "MAJAScannerController", bundle: Bundle(for: MAJAScannerController.self))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
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
        self.dismiss(animated: true, completion: nil)
    }
    
    func success() {
        let ac = UIAlertController(title: "", message: "是否立即前往", preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "取消", style: .default) { (action) in
            self.captureSession.startRunning()
        }
        
        let confirmAction = UIAlertAction(title: "前往", style: .default) { (action) in
            self.captureSession.startRunning()
        }
        
        ac.addAction(cancelAction)
        ac.addAction(confirmAction)
        present(ac, animated: true)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
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
            
            /// background inverse mask
            let backgroundView = UIView(frame: self.previewView.bounds)
            backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
            
            
            let fWidth = self.previewView.bounds.width
            let fHeight = self.previewView.bounds.size.height
            let squareWidth = fWidth * 0.7
            let targetRect = CGRect(x: fWidth/2-squareWidth/2, y: fHeight/2-squareWidth/2, width: squareWidth, height: squareWidth)
            
            let topLeft = CGPoint(x: fWidth/2-squareWidth/2, y: fHeight/2-squareWidth/2)
            
            let bottomLeft = CGPoint(x: fWidth/2-squareWidth/2, y: fHeight/2+squareWidth/2)
            
            let rectOfInterest = previewLayer.metadataOutputRectConverted(fromLayerRect: targetRect)
            
            guard let output = metadataOutput else {
                failed()
                return
            }
            output.rectOfInterest = rectOfInterest
            
            mask(viewToMask: backgroundView, maskRect: targetRect)
            self.previewView.addSubview(backgroundView)
            
            
            /// orange rect
            crosshairView = CrosshairView(frame: previewView.bounds)
            crosshairView?.backgroundColor = UIColor.clear
            self.previewView.addSubview(crosshairView!)
            
            /// scanner line
            let scannerView = UIView(frame: CGRect(x: topLeft.x, y: topLeft.y , width: squareWidth, height: 2))
            let gradientLayer = CAGradientLayer()
            gradientLayer.startPoint = CGPoint.zero
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
            gradientLayer.frame = scannerView.bounds
            
            gradientLayer.colors = [UIColor.orange.cgColor, UIColor.white.cgColor,UIColor.orange.cgColor]
            
            scannerView.layer.addSublayer(gradientLayer)
            UIView.animate(withDuration: 1, delay: 0, options: [.repeat, .autoreverse], animations: {
                scannerView.frame.origin = CGPoint(x: bottomLeft.x, y: bottomLeft.y )
            }, completion: nil)
            
            self.previewView.addSubview(scannerView)
            scannerView.bringSubview(toFront: self.previewView)
        }
        
    }
    
    func mask(viewToMask: UIView, maskRect: CGRect, invert: Bool = true) {
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        if (invert) {
            path.addRect(viewToMask.bounds)
        }
        path.addRect(maskRect)
        
        maskLayer.path = path
        if (invert) {
            maskLayer.fillRule = kCAFillRuleEvenOdd
        }
        
        // Set the mask of the view.
        viewToMask.layer.mask = maskLayer;
    }
    
    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning()
        }
    }
    
    func found(code: String) {
        print(code)
    }
    
    override public var prefersStatusBarHidden: Bool {
        return true
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
            found(code: stringValue)
        }
        success()
    }
    
}

