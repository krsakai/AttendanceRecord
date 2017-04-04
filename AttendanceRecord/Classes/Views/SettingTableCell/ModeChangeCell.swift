//
//  ModeChangeCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/28.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import SwiftTask
import HSegmentControl

internal class ModeChangeCell: UITableViewCell {
    
    @IBOutlet private weak var segmentControl: HSegmentControl!
    
    fileprivate var modeList: [Mode] {
        return [.organizer, .member]
    }
    
    static func instantiate(_ owner: AnyObject) -> ModeChangeCell {
        let cell = R.nib.modeChangeCell.firstView(owner: owner, options: nil)!
        cell.segmentControl.dataSource = cell
        cell.segmentControl.selectedIndex = cell.modeList.index(of: DeviceModel.mode) ?? 0
        cell.segmentControl.numberOfDisplayedSegments = cell.modeList.count
        cell.segmentControl.selectedTitleFont = UIFont.systemFont(ofSize: 17)
        cell.segmentControl.selectedTitleColor = UIColor.white
        cell.segmentControl.unselectedTitleFont = UIFont.systemFont(ofSize: 17)
        cell.segmentControl.unselectedTitleColor = UIColor.gray
        cell.segmentControl.segmentIndicatorViewContentMode = .bottom
        cell.segmentControl.segmentIndicatorView.backgroundColor = DeviceModel.themeColor.color
        return cell
    }
    
    @IBAction func valueChanged(segmentControl: HSegmentControl) {
        
        guard self.modeList[segmentControl.selectedIndex] == .member else {
            return
        }
        
        ModeSelectTask {  _, fulfill, reject, _ in
            AlertController.showAlert(title: R.string.localizable.modeAlertTitleUnimplemented(),
                                      message: R.string.localizable.modeAlertMessageUnimplemented(),
                                      enableCancel: true, positiveLabel: R.string.localizable.commonLabelAppStore(),
                                      positiveAction: { fulfill() }, negativeAction: { reject() })
            }.success { _ in
                return ModeSelectTask {  _, fulfill, reject, _ in
                    let viewController = EntryViewController.instantiate(entryModel: EntryModel(entryType: .member, entryCompletion: { member in
                        DeviceModel.setCurrentMember(member: member as! Member)
                        fulfill()
                }, entryReject: { _ in
                    reject()
                }))
                    UIApplication.topViewController()?.present(viewController, animated: true)
                }
            }.success { _ in
                DeviceModel.mode = self.modeList[segmentControl.selectedIndex]
                AppDelegate.reloadScreen()
            }.failure { _ in
                self.segmentControl.selectedIndex = 0
        }
        
//        guard DeviceModel.currentMember == nil else {
//            DeviceModel.mode = self.modeList[segmentControl.selectedIndex]
//            AppDelegate.reloadScreen()
//            return
//        }
//        
//        ModeSelectTask {  _, fulfill, reject, _ in
//            AlertController.showAlert(title: R.string.localizable.modeAlertTitleNoEntry(),
//                                        message: R.string.localizable.modeAlertMessageNoEntry(),
//                                        enableCancel: true, ok: { fulfill() }, cancel: { reject() })
//        }.success { _ in
//            return ModeSelectTask {  _, fulfill, reject, _ in
//                let viewController = EntryViewController.instantiate(entryModel: EntryModel(entryType: .member, entryCompletion: { member in
//                    DeviceModel.setCurrentMember(member: member as! Member)
//                    fulfill()
//                }, entryReject: { _ in
//                    reject()
//                }))
//                UIApplication.topViewController()?.present(viewController, animated: true)
//            }
//        }.success { _ in
//            DeviceModel.mode = self.modeList[segmentControl.selectedIndex]
//            AppDelegate.reloadScreen()
//        }.failure { _ in
//            self.segmentControl.selectedIndex = 0
//        }
    }
}

extension ModeChangeCell: HSegmentControlDataSource {
    
    func numberOfSegments(_ segmentControl: HSegmentControl) -> Int {
        return modeList.count
    }
    
    func segmentControl(_ segmentControl: HSegmentControl, titleOfIndex index: Int) -> String {
        return modeList[index].buttonText
    }
}
