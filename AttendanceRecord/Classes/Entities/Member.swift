//
//  Member.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/26.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

internal enum MemberType: String {
    case normal     = "0"  // 通常
    case useApp     = "1"  // メンバーアプリを使用している
}

internal final class Member: Object, ClonableObject {
    
    dynamic fileprivate(set) var memberId   = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    dynamic var nameJp                  = ""
    dynamic var nameKana                = ""
    dynamic var email                   = ""
    dynamic var memberTypeRawValue      = "0"
    
    var memberType: MemberType? {
        get {
            return MemberType(rawValue: memberTypeRawValue)
        }
        set {
            memberTypeRawValue = newValue?.rawValue ?? "0"
        }
    }
    
    dynamic private(set) var primaryKeyForRealm = ""
    
    // MARK: - Override
    
    override static func primaryKey() -> String? {
        return "primaryKeyForRealm"
    }
    
    // プライマリーキーを更新
    fileprivate func updatePrimaryKey() {
        primaryKeyForRealm = memberId
    }
}

extension Member: Mappable {
    
    convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        memberId            <- map["member_id"]
        nameJp              <- map["name_jp"]
        nameKana            <- map["name_kana"]
        email               <- map["email"]
        memberTypeRawValue  <- map["memberTypeRawValue"]
        
        updatePrimaryKey()
    }
}

extension Member {
    /// convinience initializer
    
    convenience init(memberId: String, nameJp: String, nameKana: String, email: String, memberType: MemberType) {
        self.init()
        self.memberId = memberId
        self.nameJp = nameJp
        self.nameKana  = nameKana
        self.email = email
        self.memberTypeRawValue = memberType.rawValue
        
        updatePrimaryKey()
    }
    
    convenience init(nameJp: String, nameKana: String, email: String) {
        self.init()
        self.nameJp = nameJp
        self.nameKana  = nameKana
        self.email = email
        updatePrimaryKey()
    }
    
    func updateColumn(reference: Member) -> Member {
        memberId              = reference.memberId
        nameJp                = reference.nameJp
        nameKana              = reference.nameKana
        email                 = reference.email
        memberTypeRawValue    = reference.memberTypeRawValue
        
        updatePrimaryKey()
        return self
    }
}

extension Member {
    override var id: String {
        return memberId
    }
    
    override var titleName: String {
        return nameJp
    }
}

extension Member {
    static func predicate(memberId: String) -> NSPredicate {
        return NSPredicate(format: "memberId = %@", memberId)
    }
}

