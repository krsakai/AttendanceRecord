//
//  CentralManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/15.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import CoreLocation
import CoreBluetooth
import ObjectMapper

protocol SearchResultDelegate {
    func update(peripheralList: [CBPeripheral])
}

protocol ConnectResultDelegate {
    func success(member: Member, peripheral: CBPeripheral, type: CommunicationType)
    func failure(peripheralList: [CBPeripheral])
}

internal enum CommunicationType {
    case member(Lesson?)
    case attendance(Event)
}

internal final class CentralManager: NSObject {
    
    static let shared = CentralManager()
    
    lazy var centralManager: CBCentralManager! = CBCentralManager(delegate: self, queue: nil)
    
    fileprivate var connectingPeripheral: CBPeripheral!
    
    fileprivate(set) var targetDevice: PeripheralDevice?
    
    fileprivate(set) var successHandlerList: [SuccessHandler] = [SuccessHandler]()
    
    fileprivate(set) var failureHandlerList: [FailureHandler] = [FailureHandler]()
    
    fileprivate(set) var searchedPeripheralList: [CBPeripheral] = [CBPeripheral]()
    
    fileprivate(set) var communicationType: CommunicationType?
    
    fileprivate(set) var searchResultDelegate: SearchResultDelegate?
    
    fileprivate(set) var connectResultDelegate: ConnectResultDelegate?
    
    typealias SuccessHandler = ((CBPeripheral, Member) -> Void)?

    typealias FailureHandler = ((CBPeripheral, String?) -> Void)?
    
    fileprivate enum CompletionType: Int {
        case peripheralConnect = 0
        case searchPeripherals = 1
    }
    
    // MARK: - Public Function
    
    func searchStart(delegate: SearchResultDelegate, completion: FailureHandler = nil) {
        failureHandlerList.removeAll()
        searchedPeripheralList.removeAll()
        
        searchResultDelegate = delegate
        centralManager.scanForPeripherals(withServices: nil, options: nil)
    }
    
    func searchStop() {
        centralManager.stopScan()
    }
    
    func communication(delegate: ConnectResultDelegate, targetDevice: PeripheralDevice, type: CommunicationType) {
        guard let peripheral = centralManager.retrievePeripherals(withIdentifiers: [UUID(uuidString: targetDevice.peripheralId)!]).first else {
            return
        }
        LoadingController.shared.show()
        connectResultDelegate = delegate
        communicationType = type
        failureHandlerList.append(addCancelAction)
        centralManager.connect(peripheral, options: nil)
    }
    
    // MARK: - Private Method
    
    private var addSuccessAction: SuccessHandler {
        return { peripheral, member in
            self.centralManager.cancelPeripheralConnection(peripheral)
            AlertController.showAlert(title: "接続に成功", message: "\(member.nameJp)さんを検出しました", positiveAction: { _ in
                self.connectResultDelegate?.success(member: member, peripheral: peripheral, type: self.communicationType!)
            })
        }
    }
    
    private var addCancelAction: FailureHandler {
        return { peripheral, errorString in
            self.centralManager.cancelPeripheralConnection(peripheral)
            AlertController.showAlert(title: "接続に失敗", message: "\(errorString)\nこの端末を一覧から削除してもよろしいですか？", positiveAction: { _ in
                self.connectResultDelegate?.failure(peripheralList: [peripheral])
            })
        }
    }
}

extension CentralManager: CBCentralManagerDelegate {
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
//            AlertController.showAlert(title: "Bluetoothの利用ができない状態です。再度お試しください")
        }
    }
    
    // MARK: - Scan Method
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if !searchedPeripheralList.contains(peripheral) {
            searchedPeripheralList.append(peripheral)
            searchResultDelegate?.update(peripheralList: searchedPeripheralList)
        }
    }
    
    // MARK: - Connect Status Detection
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        connectingPeripheral = peripheral
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        AlertController.showAlert(title: "接続に失敗しました")
        failureHandlerList.forEach { $0?(peripheral, nil) }
    }
}

// MARK: - Peripheral Delegate

extension CentralManager: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let error = error {
            failureHandlerList.forEach { $0?(peripheral, error.localizedDescription) }
            return
        }
        
        let services = connectingPeripheral.services
        guard let service = (services?.filter { $0.uuid == DeviceModel.serviceUUID }.first) else {
            failureHandlerList.forEach { $0?(peripheral, "このアプリでは使用できない端末です") }
            return
        }
        peripheral.discoverCharacteristics(nil, for: service)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if let error = error {
            failureHandlerList[CompletionType.peripheralConnect.rawValue]?(peripheral, error.localizedDescription)
            return
        }
        
        let characteristics = service.characteristics
        guard let characteristic =  (characteristics?.filter { $0.uuid == DeviceModel.characteristicUUID }.first) else {
            failureHandlerList[CompletionType.peripheralConnect.rawValue]?(peripheral, "このアプリでは使用できない端末です")
            return
        }
        peripheral.readValue(for: characteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            failureHandlerList[CompletionType.peripheralConnect.rawValue]?(peripheral, error.localizedDescription)
            return
        }
        
        let member = MemberManager.shared.memberListDataFromRealm().first!.clone
        _ = Mapper().toJSONString(member)?.characteristicData
        peripheral.writeValue("a".characteristicData, for: characteristic, type: CBCharacteristicWriteType.withResponse)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            failureHandlerList[CompletionType.peripheralConnect.rawValue]?(peripheral, error.localizedDescription)
            return
        }
        AlertController.showAlert(title: characteristic.value?.stringUTF8)
        centralManager.cancelPeripheralConnection(peripheral)
    }
}
