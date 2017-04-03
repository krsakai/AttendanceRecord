//
//  PeripheralDeviceManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/01.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

internal final class PeripheralDeviceManager {
    
    /// シングルトンインスタンス
    static let shared = PeripheralDeviceManager()
    
    /** 端末一覧情報をRealmに保存
     - parameter memberList: 端末一覧情報  **/
    func savePeripheralDeviceListToRealm(_ peripheralDeviceInfoList: [PeripheralDevice]) {
        let realm = try! Realm()
        try! realm.write {
            for peripheralDeviceInfo in peripheralDeviceInfoList {
                realm.add(peripheralDeviceInfo, update: true)
            }
        }
    }
    
    /// 端末一覧情報をRealmから取得
    func peripheralDeviceDataFromRealm(predicate: NSPredicate? = nil, realm: Realm = try! Realm()) -> [PeripheralDevice] {
        guard let predicate = predicate else {
            return Array(realm.objects(PeripheralDevice.self))
        }
        return Array(realm.objects(PeripheralDevice.self).filter(predicate))
    }
    
    /// 端末Realmを更新
    func updatePeripheralDeviceToRealm(peripheralDevice: PeripheralDevice, block: (PeripheralDevice) -> Void ) -> Void {
        let realm = try! Realm()
        try! realm.write {
            block( peripheralDevice )
        }
    }
}
