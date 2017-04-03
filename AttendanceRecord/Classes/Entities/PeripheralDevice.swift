//
//  PeripheralDevice.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/01.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift

internal final class PeripheralDevice: Object {
    
    dynamic fileprivate(set) var peripheralId = ""
    dynamic var memberId = ""
    
    var isAvailable: Bool {
        return !memberId.isEmpty
    }
    
    var memberName: String {
        return MemberManager.shared.memberListDataFromRealm(predicate: Member.predicate(memberId: memberId)).first?.nameJp ?? "未登録メンバー"
    }
    
    override static func primaryKey() -> String? {
        return "peripheralId"
    }
}

extension PeripheralDevice {
    
    /// イニシャライザ
    convenience init(peripheralId: String, memberId: String = "") {
        self.init()
        self.peripheralId = peripheralId
        self.memberId = memberId
    }
}


extension PeripheralDevice {
    static func predicate(peripheralId: String) -> NSPredicate {
        return NSPredicate(format: "peripheralId = %@", peripheralId)
    }
}

