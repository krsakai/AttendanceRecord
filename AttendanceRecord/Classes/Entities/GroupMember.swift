//
//  GroupMember.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2019/03/04.
//  Copyright © 2019年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift

internal final class GroupMember: Object, ClonableObject {
    
    dynamic var groupMemberId = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    dynamic var groupId   = ""
    dynamic var memberId   = ""
    
    dynamic private(set) var primaryKeyForRealm = ""
    
    // MARK: - Override
    
    override static func primaryKey() -> String? {
        return "primaryKeyForRealm"
    }
    
    // プライマリーキーを更新
    fileprivate func updatePrimaryKey() {
        primaryKeyForRealm = "\(groupId)+\(memberId)"
    }
}

extension GroupMember {
    /// convinience initializer
    
    convenience init(groupId: String, memberId: String) {
        self.init()
        self.groupId = groupId
        self.memberId  = memberId
        updatePrimaryKey()
    }
    
    func updateColumn(reference: GroupMember) -> GroupMember {
        groupId              = reference.groupId
        memberId                = reference.memberId
        updatePrimaryKey()
        return self
    }
}

extension GroupMember {
    override var id: String {
        return memberId
    }
    
    override var titleName: String {
        return ""
    }
}


extension GroupMember {
    static func predicate(memberId: String) -> NSPredicate {
        return NSPredicate(format: "memberId = %@", memberId)
    }
    
    static func predicate(groupId: String) -> NSPredicate {
        return NSPredicate(format: "groupId = %@", groupId)
    }
}


