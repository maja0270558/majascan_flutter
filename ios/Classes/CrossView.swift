import Foundation
import UIKit

class CrosshairView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
     override func draw(_ rect: CGRect) {
        let fWidth = rect.width
        let fHeight = rect.height
        let squareWidth = fWidth * 0.7
        let cornerWidth = squareWidth * 0.1
        
        let topLeft = CGPoint(x: fWidth/2-squareWidth/2, y: fHeight/2-squareWidth/2)
        let topRight = CGPoint(x: fWidth/2+squareWidth/2, y: fHeight/2-squareWidth/2)
        let bottomLeft = CGPoint(x: fWidth/2-squareWidth/2, y: fHeight/2+squareWidth/2)
        let bottomRight = CGPoint(x: fWidth/2+squareWidth/2, y: fHeight/2+squareWidth/2)
        
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(5.0)
            context.setStrokeColor(UIColor.orange.cgColor)
            
            // top left corner
            context.move(to: topLeft)
            context.addLine(to: CGPoint(x: fWidth/2-squareWidth/2+cornerWidth, y: fHeight/2-squareWidth/2))
            context.strokePath()
            
            context.move(to: topLeft)
            context.addLine(to: CGPoint(x: fWidth/2-squareWidth/2, y: fHeight/2-squareWidth/2+cornerWidth))
            context.strokePath()
            
            // top right corner
            context.move(to: topRight)
            context.addLine(to: CGPoint(x: fWidth/2+squareWidth/2, y: fHeight/2-squareWidth/2+cornerWidth))
            context.strokePath()
            
            context.move(to: topRight)
            context.addLine(to: CGPoint(x: fWidth/2+squareWidth/2-cornerWidth, y: fHeight/2-squareWidth/2))
            context.strokePath()
            
            // bottom right corner
            context.move(to: bottomRight)
            context.addLine(to: CGPoint(x: fWidth/2+squareWidth/2-cornerWidth, y: fHeight/2+squareWidth/2))
            context.strokePath()
            
            context.move(to: bottomRight)
            context.addLine(to: CGPoint(x: fWidth/2+squareWidth/2, y: fHeight/2+squareWidth/2-cornerWidth))
            context.strokePath()
            
            // bottom left corner
            context.move(to: bottomLeft)
            context.addLine(to: CGPoint(x: fWidth/2-squareWidth/2+cornerWidth, y: fHeight/2+squareWidth/2))
            context.strokePath()
            
            context.move(to: bottomLeft)
            context.addLine(to: CGPoint(x: fWidth/2-squareWidth/2, y: fHeight/2+squareWidth/2-cornerWidth))
            context.strokePath()
            
            
        }
    }
}
