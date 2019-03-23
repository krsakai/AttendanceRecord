//
//  Event.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/28.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

internal final class Event: Object, ClonableObject {
    
    dynamic fileprivate(set) var eventId    = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    dynamic fileprivate(set) var lessonId   = ""
    dynamic var eventTitle = ""
    dynamic var eventDate  = NSDateZero
    
    override static func primaryKey() -> String? {
        return "eventId"
    }
    
    // プライマリーキーを更新
    fileprivate func updatePrimaryKey() {
    }
    
    func updateColumn(reference: Event) -> Event {
        eventId     = reference.eventId
        lessonId    = reference.lessonId
        eventTitle  = reference.eventTitle
        eventDate   = reference.eventDate
        
        updatePrimaryKey()
        return self
    }
}

extension Event {
    
    /// イニシャライザ
    convenience init(lessonId: String, eventDate: Date, eventTitle: String) {
        self.init()
        self.lessonId = lessonId
        self.eventTitle = eventTitle
        self.eventDate = eventDate
    }
}

extension Event: Mappable {
    
    convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        lessonId      <- map["lessonId"]
        eventTitle    <- map["eventTitle"]
        eventDate     <- (map["eventDate"], stringToDateTransform(format: .noSeparatorYearToDay))
    }
}

extension Event {
    override var id: String {
        return eventId
    }
    
    override var titleName: String {
        return eventTitle
    }
}

extension Event {
    static func predicate(lessonId: String) -> NSPredicate {
        return NSPredicate(format: "lessonId = %@", lessonId)
    }
    
    static func predicate(eventId: String) -> NSPredicate {
        return NSPredicate(format: "eventId = %@", eventId)
    }
}

