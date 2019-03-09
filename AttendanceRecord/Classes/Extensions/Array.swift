//
//  Array.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/02.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation

/// Array拡張メソッド
extension Array {
    
    /// 指定されたオブジェクトのインデックスを取得
    ///
    /// :param: obj
    /// :returns: みつかった場合インデックス, みつからない場合はnil
    func indexOfObject<T: Equatable>(obj: T) -> Int? {
        if self.count > 0 {
            for (i, objectToCompare) in enumerated() {
                let to = objectToCompare as! T
                if obj == to {
                    return i
                }
            }
        }
        
        return nil
    }
    
    /// 指定されたオブジェクトを削除
    ///
    /// :param: obj 削除するオブジェクト
    /// :returns: 指定されたオブジェクトを削除した配列
    mutating func removeObject<T: Equatable>(obj: T) -> Array {
        self = self.filter({$0 as? T != obj})
        return self;
    }
    
    var indexCount: Int {
        return count - 1
    }
}

extension Array where Element == Member {

    var sortedName: [Member] {
        return DeviceModel.isFullNameSort ? sorted { $0.nameJp.changeKana < $1.nameJp.changeKana } : self
    }
}

extension Array where Element == Attendance {
    
    var sortedName: [Attendance] {
        return DeviceModel.isFullNameSort ? sorted { $0.memberName.changeKana < $1.memberName.changeKana } : self
    }
}
