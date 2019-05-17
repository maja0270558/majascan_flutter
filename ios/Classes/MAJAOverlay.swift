//
//  MAJAOverlay
//  majascan
//
//  Created by 1293 on 2019/5/16.
//

import UIKit

class MAJAOverlay: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        fromNib()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fromNib()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func draw(_ layer: CALayer, in ctx: CGContext) {
        super.draw(layer, in: ctx)
        let maskRect = CGRect(x: 0, y: 0, width: 200, height: 200)
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()
        path.addRect(maskRect)
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        layer.mask = maskLayer;
    }
}
