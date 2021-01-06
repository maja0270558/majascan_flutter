//
//  LocalizationEnums.swift
//  Pods
//
//  Created by 1293 on 2019/8/13.
//

import Foundation

/**
 usage: title.text = Localizable.ScanPage.scannerTitle.localized
 */
enum Localizable {
    
    enum Global: String, LocalizableDelegate {
        case cancel, confirm, go
    }
    
    enum ScanPage: String, LocalizableDelegate {
        case cameraPermisionNonOpen
        case scannerTitle
        case goImmediately
        case deviceNotSupport
    }
}
