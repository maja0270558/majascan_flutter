//
//  LocalizableDelegate.swift
//  Pods
//
//  Created by 1293 on 2019/8/13.
//

import Foundation

class Localize {
    
}

protocol LocalizableDelegate {
    var rawValue: String { get }
    var table: String? { get }
    var localized: String { get }
}

extension LocalizableDelegate {
    var localized: String {
        let path = Bundle(for: Localize.self).resourcePath! + "/local.bundle"
        let CABundle = Bundle(path: path)!

        
        print(path)

        return NSLocalizedString(rawValue, bundle: CABundle, comment: "")
    }
    var table: String? {
        return nil
    }
}
