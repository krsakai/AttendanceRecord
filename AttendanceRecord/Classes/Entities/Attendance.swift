//
//  Attendance.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/28.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift

internal enum AttendanceStatus: String {
    case attend     = "◯"
    case undfine    = "△"
    case absence    = "✕"
    case noEntry    = "ー"
}

internal final class Attendance: Object, ClonableObject {
    
    dynamic fileprivate(set) var attendanceId               = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    dynamic fileprivate(set) var lessonId                   = ""
    dynamic fileprivate(set) var eventId                    = ""
    dynamic fileprivate(set) var memberId                   = ""
    dynamic var isHidden                   = false
    dynamic var reason                     = ""
    dynamic var attendanceStatusRawValue   = "-"
    
    var memberName: String {
        let member = MemberManager.shared.memberListDataFromRealm(predicate: Member.predicate(memberId: memberId)).first!
        return member.nameKana
    }
    
    dynamic private(set) var primaryKeyForRealm = ""
    
    // MARK: - Override
    
    override static func primaryKey() -> String? {
        return "primaryKeyForRealm"
    }
    
    // プライマリーキーを更新
    fileprivate func updatePrimaryKey() {
        primaryKeyForRealm = "\(eventId)+\(memberId)"
    }
    
    override static func indexedProperties() -> [String] {
        return ["eventId", "attendanceId"]
    }
    
    /// 保存対象外
    override static func ignoredProperties() -> [String] {
        return ["attendaceStatus"]
    }
}

extension Attendance {
    /// 出欠ステータス
    var attendaceStatus: AttendanceStatus {
        get {
            return AttendanceStatus(rawValue: attendanceStatusRawValue) ?? .noEntry
        }
        set {
            attendanceStatusRawValue = newValue.rawValue
        }
    }
    
    override var id: String {
        return attendanceId
    }
}

extension Attendance {
    /// イニシャライザ
    convenience init(lessonId: String, eventId: String, memberId: String, attendanceStatus: AttendanceStatus) {
        self.init()
        self.lessonId = lessonId
        self.eventId = eventId
        self.memberId = memberId
        self.attendanceStatusRawValue = attendanceStatus.rawValue
        
        updatePrimaryKey()
    }
    
    func updateColumn(reference: Attendance) -> Attendance {
        attendanceId                = reference.attendanceId
        eventId                     = reference.eventId
        memberId                    = reference.memberId
        lessonId                    = reference.lessonId
        reason                      = reference.reason
        attendanceStatusRawValue    = reference.attendanceStatusRawValue
        
        updatePrimaryKey()
        return self
    }
}

extension Attendance {
    static func predicate(lessonId: String, memberId: String) -> NSPredicate {
        return NSPredicate(format: "lessonId = %@ AND memberId = %@", lessonId, memberId)
    }
    
    static func predicate(lessonId: String, eventId: String, filterHidden: Bool = false) -> NSPredicate {
        if filterHidden {
            return NSPredicate(format: "lessonId = %@ AND eventId = %@ AND isHidden = NO", lessonId, eventId)
        } else {
            return NSPredicate(format: "lessonId = %@ AND eventId = %@", lessonId, eventId)
        }
        
    }
    
    static func predicate(lessonId: String, eventId: String, memberId: String) -> NSPredicate {
        return NSPredicate(format: "lessonId = %@ AND eventId = %@ And memberId = %@" , lessonId, eventId, memberId)
    }
    
    static func predicate(memberId: String) -> NSPredicate {
        return NSPredicate(format: "memberId = %@", memberId)
    }
}
