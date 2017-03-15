//
//  ClonableObject.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/25.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

protocol ClonableObject: class {
    var clone: Self {get}
    init()
    func updateColumn( reference: Self ) -> Self
}

extension ClonableObject {
    /// API更新用にRealmObjectのクローンを生成する
    var clone: Self {
        return Self().updateColumn(reference: self)
    }
}
