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
        let path = Bundle(for: Localize.self).path(forResource: "majascanLocalizeBundle", ofType: "bundle")!
        let bundle = Bundle(path: path) ?? Bundle.main
        return  NSLocalizedString(rawValue, tableName: "majascan", bundle: bundle, value: "", comment: "")
    }
    var table: String? {
        return nil
    }
}
