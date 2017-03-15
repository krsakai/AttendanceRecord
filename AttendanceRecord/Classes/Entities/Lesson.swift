//
//  Lesson.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/09.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

internal final class Lesson: Object {
    
    dynamic fileprivate(set) var lessonId   = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    dynamic fileprivate(set) var lessonTitle = ""
    dynamic var updateTime = Date()
    
    override static func primaryKey() -> String? {
        return "lessonId"
    }
}

extension Lesson {
    
    // MARK: - convinience initializer 
    
    convenience init(lessonTitle: String) {
        self.init()
        self.lessonTitle = lessonTitle
    }
}

extension Lesson: Mappable {
    
    convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        lessonTitle    <- map["lessonTitle"]
    }
}

extension Lesson {
    override var id: String {
        return lessonId
    }
    
    override var titleName: String {
        return lessonTitle
    }
}

extension Lesson {
    static func predicate(lessonId: String) -> NSPredicate {
        return NSPredicate(format: "lessonId = %@", lessonId)
    }
}

