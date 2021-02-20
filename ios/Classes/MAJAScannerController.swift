
import UIKit
import AVFoundation

enum MAJAScanError: Error {
    case authorizationDenied(message: String)
    case deviceNotFound(message: String)
}


enum MAJAScanArguKey: String {
    case title = "TITLE"
    case barColor = "BAR_COLOR"
    case titleColor = "TITLE_COLOR"
    case flashLightEnable = "FLASHLIGHT"
    case squareColor = "QR_CORNER_COLOR"
    case scannerColor = "QR_SCANNER_COLOR"
    case scanAreaScale = "SCAN_AREA_SCALE"
    func getKeyValue<T>(dictionary: NSDictionary) -> T? {
        guard let result =  dictionary[self.rawValue] as? T else {
            return nil
        }
        return result
    }
}

enum SessionSetupResult {
    case success
    case notAuthorized
    case configurationFailed
}

protocol MAJAScannerDelegate: class {
    func didScanBarcodeWithResult(code: String)
    func didFailWithErrorCode(code: String)
}

class MAJAScannerController: UIViewController {
    
    var windowOrientation: UIInterfaceOrientation {
        if #available(iOS 13.0, *) {
            return view.window?.windowScene?.interfaceOrientation ?? .unknown
        } else {
            return UIApplication.shared.statusBarOrientation
        }
    }
    
    weak var delegate: MAJAScannerDelegate?
    
    // Camera
    private let sessionQueue = DispatchQueue(label: "session queue")
    private let session = AVCaptureSession()
    private var isSessionRunning = false
    private var setupResult: SessionSetupResult = .success
    @objc dynamic var metadataOutput: AVCaptureMetadataOutput!
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
 
    var previewView: PreviewView!

    
    // Flutter
    var argumentDictionary: NSDictionary = [:]
    // UI
    var crosshairView: CrosshairView! = nil
    let backButton: UIButton = UIButton(type: .custom)
    let flashlightButton: UIButton = UIButton(type: .custom)
    let navButtonFrame = CGRect(x: 0, y: 0, width: 20 , height: 20)
    var tintColor: UIColor = UIColor.white
    var barColor: UIColor = UIColor.clear
    var squareColor: UIColor = UIColor.orange
    var scannerColor: UIColor = UIColor.orange
    
    var barTitle: String = Localizable.ScanPage.scannerTitle.localized  // "掃描 QRcode"
    var flashLightEnable: Bool = true
    var backImage: UIImage?
    var flashlightImage: UIImage?
    var scanAreaScale: Double?
    
    
    
    /*
     Life cycle
     */
    override  func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = UIColor.black
        settingArgumentValue()
        configureNavigationBar()

        // Init preview view
        previewView = PreviewView()
        view.addSubview(previewView)
        
        crosshairView = CrosshairView(frame: UIScreen.main.bounds, color: self.squareColor, scannerColor: self.scannerColor, scale: self.scanAreaScale ?? 0.7)
        previewView.addSubview(crosshairView!)
        
        // Autolayout
        self.previewView.videoPreviewLayer.videoGravity = .resizeAspectFill
        previewView.autoLayout.fillSuperview()
        crosshairView.autoLayout.fillSuperview()
       
        // Setting camera
        // Set up the video preview view.
         previewView.session = session
        
        // Check auth
        /*
         Check the video authorization status. Video access is required and audio
         access is optional. If the user denies audio access, AVCam won't
         record audio during movie recording.
         */
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. Suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            setupResult = .notAuthorized
        }
        
        /*
                Setup the capture session.
                In general, it's not safe to mutate an AVCaptureSession or any of its
                inputs, outputs, or connections from multiple threads at the same time.
                
                Don't perform these tasks on the main queue because
                AVCaptureSession.startRunning() is a blocking call, which can
                take a long time. Dispatch session setup to the sessionQueue, so
                that the main queue isn't blocked, which keeps the UI responsive.
                */
               sessionQueue.async {
                   self.configureSession()
               }
    }
    
    override  func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
              sessionQueue.async {
                  switch self.setupResult {
                  case .success:
                      // Only setup observers and start the session if setup succeeded.
                      self.addObservers()
                      self.session.startRunning()
                      self.isSessionRunning = self.session.isRunning
                      
                  case .notAuthorized:
                      DispatchQueue.main.async {
                       let alertController = UIAlertController(title: Localizable.ScanPage.scannerTitle.localized, message: "\(Localizable.ScanPage.cameraPermisionNonOpen.localized)", preferredStyle: .alert)
                                let confirmAction = UIAlertAction(title: Localizable.Global.go.localized, style: .default) { (action) in
                                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                                    self.dismissWithoutResult()
                                }
                                let cancelAction = UIAlertAction(title: Localizable.Global.cancel.localized, style: .default) { (action) in
                                    self.dismissWithoutResult()
                                }
                                alertController.addAction(confirmAction)
                                alertController.addAction(cancelAction)
                        self.present(alertController, animated: true)
                      }
                      
                  case .configurationFailed:
                      DispatchQueue.main.async {
                        let alertController = UIAlertController(title: Localizable.ScanPage.scannerTitle.localized, message: "\(Localizable.ScanPage.deviceNotSupport.localized)", preferredStyle: .alert)
                                    let confirmAction = UIAlertAction(title: Localizable.Global.confirm.localized, style: .default) { (action) in
                                        self.dismissWithoutResult()
                                    }
                                    alertController.addAction(confirmAction)
                            self.present(alertController, animated: true)
                                    
                      }
                  }
              }
    }
    
    
    
    private func addObservers() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: session)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: session)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionInterruptionEnded),
                                               name: .AVCaptureSessionInterruptionEnded,
                                               object: session)
    }
    
    private func removeObservers() {
           NotificationCenter.default.removeObserver(self)
     }
    
    /// - Tag: HandleRuntimeError
       @objc
       func sessionRuntimeError(notification: NSNotification) {
           guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
           
           print("Capture session runtime error: \(error)")
           resumeInterruptedSession()
           // If media services were reset, and the last start succeeded, restart the session.
        if error.code == .mediaServicesWereReset {
               sessionQueue.async {
                   if self.isSessionRunning {
                       self.session.startRunning()
                       self.isSessionRunning = self.session.isRunning
                   }
               }
           }
       }
    
    /// - Tag: HandleInterruption
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        /*
         In some scenarios you want to enable the user to resume the session.
         For example, if music playback is initiated from Control Center while
         using AVCam, then the user can let AVCam resume
         the session running, which will stop music playback. Note that stopping
         music playback in Control Center will not automatically resume the session.
         Also note that it's not always possible to resume, see `resumeInterruptedSession(_:)`.
         */
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
            let reasonIntegerValue = userInfoValue.integerValue,
            let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("Capture session was interrupted with reason \(reason)")
            
            var showResumeButton = false
            if reason == .audioDeviceInUseByAnotherClient || reason == .videoDeviceInUseByAnotherClient {
                showResumeButton = true
            } else if reason == .videoDeviceNotAvailableWithMultipleForegroundApps {
                // Fade-in a label to inform the user that the camera is unavailable.
//                cameraUnavailableLabel.alpha = 0
//                cameraUnavailableLabel.isHidden = false
//                UIView.animate(withDuration: 0.25) {
//                    self.cameraUnavailableLabel.alpha = 1
//                }
            }
            if showResumeButton {
                resumeInterruptedSession()
            }
        }
    }
    
    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        print("Capture session interruption ended")
        resumeInterruptedSession()
   
    }
    
    override  func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sessionQueue.async {
                  if self.setupResult == .success {
                      self.session.stopRunning()
                      self.isSessionRunning = self.session.isRunning
                      self.removeObservers()
                  }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
         super.viewWillTransition(to: size, with: coordinator)
         
         if let videoPreviewLayerConnection = previewView.videoPreviewLayer.connection {
             let deviceOrientation = UIDevice.current.orientation
             guard let newVideoOrientation = AVCaptureVideoOrientation(deviceOrientation: deviceOrientation),
                 deviceOrientation.isPortrait || deviceOrientation.isLandscape else {
                     return
             }
             
             videoPreviewLayerConnection.videoOrientation = newVideoOrientation
         }
     }
    
    /*
     Init Method
     */
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
           return .all
    }
    
    /*
     Button action
     */
    @objc func backAction() -> Void {
        dismissWithoutResult()
    }

    func dismissWithoutResult() -> Void {
        delegate?.didScanBarcodeWithResult(code: "")
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
            barColor = UIColor(hexString: barColorHex) ?? UIColor.clear
        }
        
        if let squareColorHex: String = MAJAScanArguKey.squareColor.getKeyValue(dictionary: argumentDictionary)  {
            squareColor = UIColor(hexString: squareColorHex) ?? UIColor.orange
        }
        
        if let scannerColorHex: String = MAJAScanArguKey.scannerColor.getKeyValue(dictionary: argumentDictionary)  {
            scannerColor = UIColor(hexString: scannerColorHex) ?? UIColor.orange
        }
        
        if let newBarTitle: String = MAJAScanArguKey.title.getKeyValue(dictionary: argumentDictionary)  {
            barTitle = newBarTitle
        }
        
        if let flashLightEnableString: String = MAJAScanArguKey.flashLightEnable.getKeyValue(dictionary: argumentDictionary), let enableInt = Int(flashLightEnableString)  {
            
            flashLightEnable = enableInt == 0 ? false : true
        }
        
        if let scale: String = MAJAScanArguKey.scanAreaScale.getKeyValue(dictionary: argumentDictionary)  {
            scanAreaScale = Double(scale) ?? 0.7
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
    
    func success() {
        let ac = UIAlertController(title: "", message: Localizable.ScanPage.goImmediately.localized, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: Localizable.Global.cancel.localized, style: .default) { (action) in
            self.session.startRunning()
        }
        let confirmAction = UIAlertAction(title: Localizable.Global.go.localized, style: .default) { (action) in
            self.session.startRunning()
            self.dismiss(animated: true, completion: nil)
        }
        ac.addAction(cancelAction)
        ac.addAction(confirmAction)
        present(ac, animated: true)
    }
    
    private func configureSession() {
           if setupResult != .success {
               return
           }
           
           session.beginConfiguration()
        
           // Add video input.
           do {
               var defaultVideoDevice: AVCaptureDevice?
                              
               if let cameraDevice =  AVCaptureDevice.default(for: .video)  {
                   defaultVideoDevice = cameraDevice
               }
            
               guard let videoDevice = defaultVideoDevice else {
                   print("Default video device is unavailable.")
                   setupResult = .configurationFailed
                   session.commitConfiguration()
                   return
               }
               let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
               
               if session.canAddInput(videoDeviceInput) {
                   session.addInput(videoDeviceInput)
                   self.videoDeviceInput = videoDeviceInput
                   
                   DispatchQueue.main.async {
                       /*
                        Dispatch video streaming to the main queue because AVCaptureVideoPreviewLayer is the backing layer for PreviewView.
                        You can manipulate UIView only on the main thread.
                        Note: As an exception to the above rule, it's not necessary to serialize video orientation changes
                        on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                        
                        Use the window scene's orientation as the initial video orientation. Subsequent orientation changes are
                        handled by CameraViewController.viewWillTransition(to:with:).
                        */
                       var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                       if self.windowOrientation != .unknown {
                                          if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: self.windowOrientation) {
                                              initialVideoOrientation = videoOrientation
                                          }
                       }
                    
                       self.previewView.videoPreviewLayer.connection?.videoOrientation = initialVideoOrientation
                   }
               } else {
                   print("Couldn't add video device input to the session.")
                   setupResult = .configurationFailed
                   session.commitConfiguration()
                   return
               }
           } catch {
               print("Couldn't create video device input: \(error)")
               setupResult = .configurationFailed
               session.commitConfiguration()
               return
           }
           
           // Add the metadatta output.
            metadataOutput = AVCaptureMetadataOutput()
           
        
           if session.canAddOutput(metadataOutput) {
               session.addOutput(metadataOutput)
               metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
               metadataOutput.metadataObjectTypes = [.aztec, .code128, .code39, .code39Mod43, .code93, .dataMatrix, .ean13, .ean8, .interleaved2of5, .itf14, .pdf417, .qr]
           } else {
               print("Could not add photo output to the session")
               setupResult = .configurationFailed
               session.commitConfiguration()
               return
           }
           
           session.commitConfiguration()
       }
    
        @IBAction private func resumeInterruptedSession() {
          sessionQueue.async {
              /*
               The session might fail to start running, for example, if a phone or FaceTime call is still
               using audio or video. This failure is communicated by the session posting a
               runtime error notification. To avoid repeatedly failing to start the session,
               only try to restart the session in the error handler if you aren't
               trying to resume the session.
               */
              self.session.startRunning()
              self.isSessionRunning = self.session.isRunning
              if !self.session.isRunning {
                  DispatchQueue.main.async {
                      let alertController = UIAlertController(title: "", message: "Unable to resume", preferredStyle: .alert)
                      let cancelAction = UIAlertAction(title: NSLocalizedString("\(Localizable.Global.confirm.localized)", comment: ""), style: .cancel, handler: nil)
                      alertController.addAction(cancelAction)
                      self.present(alertController, animated: true, completion: nil)
                  }
              }
          }
      }
}

extension MAJAScannerController: AVCaptureMetadataOutputObjectsDelegate{
    @objc func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        session.stopRunning()
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let stringValue = readableObject.stringValue else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            delegate?.didScanBarcodeWithResult(code: stringValue)
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}

extension AVCaptureVideoOrientation {
    init?(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeRight
        case .landscapeRight: self = .landscapeLeft
        default: return nil
        }
    }
    
    init?(interfaceOrientation: UIInterfaceOrientation) {
        switch interfaceOrientation {
        case .portrait: self = .portrait
        case .portraitUpsideDown: self = .portraitUpsideDown
        case .landscapeLeft: self = .landscapeLeft
        case .landscapeRight: self = .landscapeRight
        default: return nil
        }
    }
}
