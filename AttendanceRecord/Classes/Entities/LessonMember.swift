//
//  LessonMember.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/25.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift

internal final class LessonMember: Object, ClonableObject {
    
    dynamic var lessonMemberId = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    dynamic var lessonId   = ""
    dynamic var memberId   = ""
    
    dynamic private(set) var primaryKeyForRealm = ""
    
    // MARK: - Override
    
    override static func primaryKey() -> String? {
        return "primaryKeyForRealm"
    }
    
    // プライマリーキーを更新
    fileprivate func updatePrimaryKey() {
        primaryKeyForRealm = "\(lessonId)+\(memberId)"
    }
}

extension LessonMember {
    /// convinience initializer
    
    convenience init(lessonId: String, memberId: String) {
        self.init()
        self.lessonId = lessonId
        self.memberId  = memberId
        updatePrimaryKey()
    }
    
    func updateColumn(reference: LessonMember) -> LessonMember {
        lessonId              = reference.lessonId
        memberId                = reference.memberId
        updatePrimaryKey()
        return self
    }
}

extension LessonMember {
    override var id: String {
        return memberId
    }
    
    override var titleName: String {
        return ""
    }
}


extension LessonMember {
    static func predicate(memberId: String) -> NSPredicate {
        return NSPredicate(format: "memberId = %@", memberId)
    }
}

