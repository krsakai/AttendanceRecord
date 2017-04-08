//
//  MemberSearchViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/02.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import CoreBluetooth

internal class MemberSearchViewController: UIViewController, HeaderViewDisplayable {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var headerView: HeaderView!
    
    @IBOutlet fileprivate weak var footerView: FooterView!
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    // MARK: - Property
    
    fileprivate var peripheralDeviceList: [PeripheralDevice] = [PeripheralDevice]()
    
    // MARK - Initializer
    
    static func instantiate() -> MemberSearchViewController {
        
        let viewController = R.storyboard.memberSearchViewController.memberSearchViewController()!
        return viewController
    }
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = DeviceModel.themeColor.color
        setupHeaderView(R.string.localizable.memberSearchTitleLabelMemberSearch(), buttonTypes: [[.close(HeaderModel() {
            CentralManager.shared.searchStop()
        })],[]])
        CentralManager.shared.searchStart(delegate: self)
    }
}

extension MemberSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return peripheralDeviceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = MemberSearchViewCell.instantiate(owner: tableView, peripheralDevice: peripheralDeviceList[indexPath.row])
        return cell
    }
}

extension MemberSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        CentralManager.shared.communication(delegate: self, targetDevice: peripheralDeviceList[indexPath.row], type: .member(nil))
    }
}

extension MemberSearchViewController: SearchResultDelegate {
    
    func update(peripheralList: [CBPeripheral]) {
        peripheralList.forEach { peripheral in
            let predicate = PeripheralDevice.predicate(peripheralId: peripheral.identifier.uuidString)
            if let device = PeripheralDeviceManager.shared.peripheralDeviceDataFromRealm(predicate: predicate).first {
                if (peripheralDeviceList.filter { $0.peripheralId == device.peripheralId }.first == nil) {
                    peripheralDeviceList.append(device)
                }
            } else {
                let device = PeripheralDevice(peripheralId: peripheral.identifier.uuidString)
                PeripheralDeviceManager.shared.savePeripheralDeviceListToRealm([device])
                peripheralDeviceList.append(device)
            }
        }
        tableView.reloadData()
    }
}

extension MemberSearchViewController: ConnectResultDelegate {
    
    func success(member: Member, peripheral: CBPeripheral, type: CommunicationType) {
        
    }
    
    func failure(peripheralList: [CBPeripheral]) {
        
        peripheralList.forEach { peripheral in
            if let device = (peripheralDeviceList.filter { $0.peripheralId == peripheral.identifier.uuidString }.first),
               let index = peripheralDeviceList.index(of: device) {
                peripheralDeviceList.remove(at: index)
            }
        }
        tableView.reloadData()
    }
}
