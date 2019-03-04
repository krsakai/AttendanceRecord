//
//  Group.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2019/03/04.
//  Copyright © 2019年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

internal final class Group: Object {
    
    dynamic fileprivate(set) var groupId   = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    dynamic fileprivate(set) var groupTitle = ""
    dynamic var updateTime = Date()
    
    override static func primaryKey() -> String? {
        return "groupId"
    }
}

extension Group {
    
    // MARK: - convinience initializer
    
    convenience init(groupTitle: String) {
        self.init()
        self.groupTitle = groupTitle
    }
}

extension Group: Mappable {
    
    convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        groupTitle    <- map["groupTitle"]
    }
}

extension Group {
    override var id: String {
        return groupId
    }
    
    override var titleName: String {
        return groupTitle
    }
}

extension Group {
    static func predicate(groupId: String) -> NSPredicate {
        return NSPredicate(format: "groupId = %@", groupId)
    }
}


