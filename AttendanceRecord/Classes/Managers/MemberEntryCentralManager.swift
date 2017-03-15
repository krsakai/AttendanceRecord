//
//  MemberEntryCentralManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/15.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth
import ObjectMapper

internal final class MemberEntryCentralManager: NSObject {
    
    static let shared = MemberEntryCentralManager()
    
    fileprivate var timer: Timer?
    
    fileprivate lazy var centralManager: CBCentralManager! = CBCentralManager(delegate: self, queue: nil)
    
    fileprivate var peripheral: CBPeripheral!
    
    fileprivate var characteristic: CBCharacteristic!

    func searchMember() {
        LoadingController.shared.show()
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func confirm() {
//        timer = Timer.scheduledTimer(timeInterval: Double(5), target: self,
//                                     selector: #selector(confirm), userInfo: nil, repeats: false)
//        RunLoop.current.add(timer!, forMode: .defaultRunLoopMode)
//        AlertController.showAlert(title: "確認",  ok: { _ in
//            self.searchMember()
//        })
//        timer?.invalidate()
    }
}

extension MemberEntryCentralManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        self.peripheral = peripheral
        centralManager.connect(self.peripheral, options: nil)
        centralManager.stopScan()
    }
    
    // ペリフェラルへの接続が成功すると呼ばれる
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        self.peripheral.delegate = self
        self.peripheral.discoverServices(nil)
    }
    
    // ペリフェラルへの接続が失敗すると呼ばれる
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("failed...")
    }
    
    func read() {
         self.peripheral.readValue(for: self.characteristic)
    }
}

extension MemberEntryCentralManager: CBPeripheralDelegate {
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let error = error {
            print("error: \(error)")
            return
        }
        
        let services = self.peripheral.services
        guard let service =  (services?.filter { $0.uuid == DeviceModel.serviceUUID }.first) else {
            return
        }
        self.peripheral.discoverCharacteristics(nil, for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            print("error: \(error)")
            return
        }
        
        let characteristics = service.characteristics
        guard let characteristic =  (characteristics?.filter { $0.uuid == DeviceModel.characteristicUUID }.first) else {
            return
        }
        self.characteristic = characteristic
        peripheral.readValue(for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Failed... error: \(error)")
            return
        }
        
        let member = MemberManager.shared.memberListDataFromRealm().first!.clone
        let memberData = Mapper().toJSONString(member)?.data(using: .utf8, allowLossyConversion:true)
        AlertController.showAlert(title: "確認",  ok: { _ in
            self.peripheral.writeValue(memberData!, for: characteristic, type: CBCharacteristicWriteType.withResponse)
        })
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Write失敗...error: \(error)")
            return
        }
        centralManager.cancelPeripheralConnection(peripheral)
    }
}
