import Foundation
import UIKit

class CrosshairView: UIView {
    
    var minDistance: CGFloat {
        return min(self.bounds.height, self.bounds.width)
    }

    var squareWidth: CGFloat {
        if scale > 1 {
            scale = 1
        } else if scale < 0 {
            scale = 0
        }
        
        return minDistance * CGFloat(scale)
    }
    
    var cornerWidth: CGFloat {
        return squareWidth * 0.1
    }
    
    var topLeft: CGPoint {
        return CGPoint(x: UIScreen.main.bounds.width/2-squareWidth/2, y: UIScreen.main.bounds.height/2-squareWidth/2)
    }
    
    var topRight: CGPoint {
        return CGPoint(x: UIScreen.main.bounds.width/2+squareWidth/2, y: UIScreen.main.bounds.height/2-squareWidth/2)
    }
    
    var bottomLeft: CGPoint {
        return CGPoint(x: UIScreen.main.bounds.width/2-squareWidth/2, y: UIScreen.main.bounds.height/2+squareWidth/2)
    }
    
    var bottomRight: CGPoint {
        return CGPoint(x: UIScreen.main.bounds.width/2+squareWidth/2, y: UIScreen.main.bounds.height/2+squareWidth/2)
    }
    
    var squareRect: CGRect {
        return CGRect(x: topLeft.x, y: topLeft.y, width: squareWidth, height: squareWidth)
    }
    
    var backgroundView = UIView()
    var backgroundMaskLayer = CAShapeLayer()
    var scanView = UIView(frame: CGRect.zero)
    var scanGradientLayer = CAGradientLayer()
    var color: UIColor!
    var scannerColor: UIColor!
    var scale: Double!
    
    convenience init(frame: CGRect,color: UIColor = UIColor.orange, scannerColor:UIColor = UIColor.orange, scale: Double)  {
        self.init(frame: frame)
        self.color = color
        self.scannerColor = scannerColor
        self.scale = scale
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
        self.backgroundView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
        self.addSubview(backgroundView)
        self.addSubview(scanView)
        backgroundView.autoLayout.fillSuperview()
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)

    }
    
    @objc func appEnterForeground() {
        self.scanView.transform = .identity
        self.scanView.layer.removeAllAnimations()
        updateScanView()
    }
    
    @objc func appEnterBackground() {
      
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        self.contentMode = .redraw
        updateMaskLayer()
        updateScanView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func updateMaskLayer() {
        let maskRect = CGRect(x: topLeft.x, y: topLeft.y, width: squareWidth, height: squareWidth)
        let path = CGMutablePath()
        path.addRect(UIScreen.main.bounds)
        path.addRect(maskRect)
        
        backgroundMaskLayer.fillRule = CAShapeLayerFillRule.evenOdd
        backgroundMaskLayer.frame = self.bounds
        backgroundMaskLayer.path = path
        self.backgroundView.layer.mask = backgroundMaskLayer
    }
    
    func updateScanView(){
        self.scanView.frame = CGRect(x: topLeft.x, y: topLeft.y , width: squareWidth, height: 2)
        self.scanGradientLayer.frame = self.scanView.bounds
        let transform = CGAffineTransform(translationX: 0, y: -squareWidth)
        UIView.animate(withDuration: 1,
                       delay: 0,
                       options: [.repeat, .autoreverse, .beginFromCurrentState], animations: {
                        self.scanView.transform = transform
        },
                       completion: nil)
    }
    
    func gradientInit(){
        scanGradientLayer.startPoint = CGPoint.zero
        scanGradientLayer.endPoint = CGPoint(x: 1, y: 0)
        scanGradientLayer.frame = scanView.bounds
        scanGradientLayer.colors = [scannerColor.cgColor, UIColor.white.cgColor,scannerColor.cgColor]
        scanView.layer.addSublayer(scanGradientLayer)
    }
    
    override func draw(_ rect: CGRect) {

        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(5.0)
            context.setStrokeColor(color.cgColor)
            
            // top left corner
            context.move(to: topLeft)
            context.addLine(to: topLeft.right(x: cornerWidth))
            context.strokePath()
            
            context.move(to: topLeft)
            context.addLine(to: topLeft.down(y: cornerWidth))
            context.strokePath()
            
            // top right corner
            context.move(to: topRight)
            context.addLine(to: topRight.left(x: cornerWidth))
            context.strokePath()
            
            context.move(to: topRight)
            context.addLine(to: topRight.down(y: cornerWidth))
            context.strokePath()
            
            // bottom right corner
            context.move(to: bottomRight)
            context.addLine(to: bottomRight.left(x: cornerWidth))
            context.strokePath()
            
            context.move(to: bottomRight)
            context.addLine(to: bottomRight.up(y: cornerWidth))
            context.strokePath()
            
            // bottom left corner
            context.move(to: bottomLeft)
            context.addLine(to: bottomLeft.right(x: cornerWidth))
            context.strokePath()
            
            context.move(to: bottomLeft)
            context.addLine(to: bottomLeft.up(y: cornerWidth))
            context.strokePath()
            
            self.updateMaskLayer()
            
            // scan line
            self.gradientInit()
            self.updateScanView()
        }
    }
}
