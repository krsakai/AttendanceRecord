//
//  Attendance.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/28.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift

internal final class Attendance: Object, ClonableObject {
    
    dynamic fileprivate(set) var attendanceId               = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    dynamic fileprivate(set) var lessonId                   = ""
    dynamic fileprivate(set) var eventId                    = ""
    dynamic fileprivate(set) var memberId                   = ""
    dynamic var memberNameKana             = ""
    dynamic var isHidden                   = false
    dynamic var reason                     = ""
    dynamic var attendanceStatusRawValue   = "-"
    
    var memberName: String {
        let member = MemberManager.shared.memberListDataFromRealm(predicate: Member.predicate(memberId: memberId)).first!
        return member.nameJpKana
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
            return AttendanceStatus(rawValue: attendanceStatusRawValue)
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
    convenience init(lessonId: String, eventId: String, memberId: String, attendanceStatus: AttendanceStatus = AttendanceStatus(rawValue: "ー")) {
        self.init()
        self.lessonId = lessonId
        self.eventId = eventId
        self.memberId = memberId
        self.memberNameKana = memberName
        self.attendanceStatusRawValue = attendanceStatus.rawValue
        
        updatePrimaryKey()
    }
    
    func updateColumn(reference: Attendance) -> Attendance {
        attendanceId                = reference.attendanceId
        eventId                     = reference.eventId
        memberId                    = reference.memberId
        memberNameKana              = reference.memberNameKana
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
    
    static func predicate(lessonId: String, eventId: String, filterHidden: Bool = false, filterStatus: AttendanceStatus? = nil) -> NSPredicate {
        guard let filterStatus = filterStatus else {
            if filterHidden {
                return NSPredicate(format: "lessonId = %@ AND eventId = %@ AND isHidden = NO", lessonId, eventId)
            } else {
                return NSPredicate(format: "lessonId = %@ AND eventId = %@", lessonId, eventId)
            }
        }
        
        if filterHidden {
            return NSPredicate(format: "lessonId = %@ AND eventId = %@ AND isHidden = NO AND attendanceStatusRawValue = %@", lessonId, eventId, filterStatus.rawValue)
        } else {
            return NSPredicate(format: "lessonId = %@ AND eventId = %@ AND attendanceStatusRawValue = %@", lessonId, eventId, filterStatus.rawValue)
        }
        
    }
    
    static func predicate(event: Event, isHidden: Bool = true) -> NSPredicate {
        if isHidden {
            return NSPredicate(format: "lessonId = %@ AND eventId = %@ AND isHidden = YES", event.lessonId, event.eventId)
        } else {
           return NSPredicate(format: "lessonId = %@ AND eventId = %@ AND isHidden = NO", event.lessonId, event.eventId)
        }
        
    }
    
    static func predicate(lessonId: String, eventId: String, memberId: String) -> NSPredicate {
        return NSPredicate(format: "lessonId = %@ AND eventId = %@ And memberId = %@" , lessonId, eventId, memberId)
    }
    
    static func predicate(memberId: String) -> NSPredicate {
        return NSPredicate(format: "memberId = %@", memberId)
    }
}
