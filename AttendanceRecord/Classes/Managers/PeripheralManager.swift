//
//  PeripheralManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/15.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth

internal final class PeripheralManager: NSObject {
    
    static let shared = PeripheralManager()
    
    fileprivate var peripheralManager: CBPeripheralManager!
    
    fileprivate var characteristic: CBMutableCharacteristic = {
        let properties: CBCharacteristicProperties = [.notify, .read, .write]
        let permissions: CBAttributePermissions = [.readable, .writeable]
        return CBMutableCharacteristic(type: DeviceModel.characteristicUUID, properties: properties,
                                       value: nil, permissions: permissions)
    }()
    
    fileprivate lazy var service: CBMutableService = {
        let service = CBMutableService(type: DeviceModel.serviceUUID, primary: true)
        service.characteristics = [self.characteristic]
        return service
    }()
    
    func start() {
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
    }
}

extension PeripheralManager:  CBPeripheralManagerDelegate {
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        peripheral.startAdvertising(DeviceModel.advertisementData)
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
        if let error = error {
            print("Failed... error: \(error)")
            return
        }
        peripheralManager.add(service)
        print("Succeeded!")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
        if let error = error {
            print("サービス追加失敗！ error: \(error)")
            return
        }
        
        print("サービス追加成功！")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        
        if request.characteristic.uuid.isEqual(characteristic.uuid) {
            
            // CBMutableCharacteristicのvalueをCBATTRequestのvalueにセット
            let member = DeviceModel.currentMember // member?.toJSONString()?.characteristicData
            let byte = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbcccccccccccccccccccccccccccccccccccdddddddddddddddddddddddddddddddddddddddddddeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeffffffffffffffffffffffffffffffffffff".characteristicData
            let length = [UInt8](byte)
            
            // リクエストに応答
            peripheralManager.respond(to: request, withResult: .success)
            AlertController.showAlert(title: request.value?.stringUTF8)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        
        for request in requests {
            
            if request.characteristic.uuid.isEqual(characteristic.uuid) {
                characteristic.value = request.value
                AlertController.showAlert(title: characteristic.value?.stringUTF8)
            }
        }
        
        // リクエストに応答
        peripheralManager.respond(to: requests[0], withResult: .success)
    }
}

extension String {
    var characteristicData: Data {
        guard let data = self.data(using: String.Encoding.utf8, allowLossyConversion: true) else {
            return "".self.data(using: String.Encoding.utf8, allowLossyConversion: true)!
        }
        return data
    }
}

extension Data {
    var stringUTF8: String {
        guard let string = String(data: self, encoding: .utf8) else {
            return ""
        }
        return string
    }
}
