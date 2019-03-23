//
//  AttendanceStatus.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2019/03/24.
//  Copyright © 2019年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

internal enum AttendanceStatusTemplates: String {
    case attend     = "◯"
    case undfine    = "△"
    case absence    = "✕"
    case noEntry    = "ー"
}

internal final class AttendanceStatus: Object {
    
    dynamic fileprivate(set) var statusId = UUID().uuidString
    dynamic fileprivate(set) var rawValue = ""
    dynamic fileprivate(set) var updateDate = Date()
    
    // MARK: - Override
    
    override static func primaryKey() -> String? {
        return "statusId"
    }
}

extension AttendanceStatus {
    
    // MARK: - convinience initializer
    
    convenience init(rawValue: String) {
        self.init()
        self.rawValue = rawValue
    }
}

extension AttendanceStatus: Mappable {
    
    convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        rawValue    <- map["rawValue"]
    }
}
