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

internal final class Member: Object, ClonableObject {
    
    dynamic fileprivate(set) var memberId   = UUID().uuidString.replacingOccurrences(of: "-", with: "")
    dynamic var nameJp                  = ""
    dynamic var nameRoma                = ""
    dynamic var email                   = ""
    
    dynamic private(set) var primaryKeyForRealm = ""
    
    // MARK: - Override
    
    override static func primaryKey() -> String? {
        return "primaryKeyForRealm"
    }
    
    // プライマリーキーを更新
    fileprivate func updatePrimaryKey() {
        primaryKeyForRealm = "\(nameRoma)+\(email)"
    }
}

extension Member: Mappable {
    
    convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
        memberId   <- map["member_id"]
        nameJp     <- map["name_jp"]
        nameRoma   <- map["name_roma"]
        email      <- map["email"]
        
        updatePrimaryKey()
    }
}

extension Member {
    /// convinience initializer
    
    convenience init(memberId: String, nameJp: String, nameRoma: String, email: String) {
        self.init()
        self.memberId = memberId
        self.nameJp = nameJp
        self.nameRoma  = nameRoma
        self.email = email
        updatePrimaryKey()
    }
    
    convenience init(nameJp: String, nameRoma: String, email: String) {
        self.init()
        self.nameJp = nameJp
        self.nameRoma  = nameRoma
        self.email = email
        updatePrimaryKey()
    }
    
    func updateColumn(reference: Member) -> Member {
        memberId              = reference.memberId
        nameJp                = reference.nameJp
        nameRoma              = reference.nameRoma
        email                 = reference.email
        
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

