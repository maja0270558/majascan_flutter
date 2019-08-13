//
//  CGPoint+Move.swift
//  majascan
//
//  Created by 1293 on 2019/5/17.
//

import Foundation

extension CGPoint {
    
    func move(x:CGFloat? = nil, y:CGFloat? = nil) -> CGPoint {
        var tempCopy = self
        if let x = x {
            tempCopy.x += x
        }
        
        if let y = y {
            tempCopy.y += y
        }
        
        return tempCopy
    }
    
    func up(y:CGFloat) -> CGPoint {
        return move(y: -y)
    }
    
    func down(y:CGFloat) -> CGPoint {
        return move(y: y)
    }
    
    func left(x:CGFloat) -> CGPoint {
        return move(x: -x)
    }
    
    func right(x:CGFloat) -> CGPoint {
        return move(x: x)
    }
}
