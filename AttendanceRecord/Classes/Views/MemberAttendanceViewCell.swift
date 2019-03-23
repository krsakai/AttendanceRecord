//
//  MemberAttendanceViewCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/01.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import SWTableViewCell

internal final class MemberAttendanceViewCell: SWTableViewCell, NibRegistrable {
    
    private var completion: (() -> Void)?
    
    @IBOutlet private weak var kanaNameLabel: UILabel!
    @IBOutlet private weak var jpNameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var attendanceButton: UIButton!
    
    private var viewModel: AttendanceViewModel!
    
    func setup(_ owner: SWTableViewCellDelegate, viewModel: AttendanceViewModel,
               index: Int, editMode: Bool = false, completion: (() -> Void)? = nil) {
        kanaNameLabel.text = viewModel.member.nameKana
        jpNameLabel.text = viewModel.member.nameJp
        emailLabel.text = viewModel.member.email
        UIView.setAnimationsEnabled(false)
        attendanceButton.setTitle(viewModel.attendance.attendanceStatusRawValue, for: .normal)
        attendanceButton.setTitle(viewModel.attendance.attendanceStatusRawValue, for: .highlighted)
        attendanceButton.setTitleColor(DeviceModel.themeColor.color, for: .normal)
        attendanceButton.setTitleColor(DeviceModel.themeColor.color, for: .highlighted)
        attendanceButton.layoutIfNeeded()
        UIView.setAnimationsEnabled(true)
        self.completion = completion
        self.viewModel = viewModel
        let utilityButtons = NSMutableArray()
        utilityButtons.sw_addUtilityButton(with: DeviceModel.themeColor.color, title: "非表示")
        leftUtilityButtons = utilityButtons as [AnyObject]
        delegate = owner
        if editMode {
            showLeftUtilityButtons(animated: false)
        } else {
            hideUtilityButtons(animated: false)
        }
        attendanceButton.titleLabel?.adjustsFontSizeToFitWidth = true
        attendanceButton.titleLabel?.minimumScaleFactor = 0.1
        attendanceButton.titleLabel?.baselineAdjustment = .alignCenters
        let longPressRecognizer = UILongPressGestureRecognizer(
            target: owner,
            action: #selector(MemberAttendanceViewController.attendanceButtonLongPress(_:))
        )
        attendanceButton.addGestureRecognizer(longPressRecognizer)
    }
    
    @IBAction func didTap(attendanceButton: UIButton) {
        let alert = UIAlertController(title: R.string.localizable.commonLabelAttendanceInput(),
                                      message: viewModel.member.nameJp,
                                      preferredStyle: .actionSheet)
        
        AttendanceManager.shared.attendanceStatusListDataFromRealm().forEach { status in
            let action = UIAlertAction(title: status.rawValue, style: UIAlertActionStyle.default) { _ in
                let attendance = self.viewModel.attendance.clone
                attendance.attendanceStatusRawValue = status.rawValue
                AttendanceManager.shared.saveAttendanceListToRealm([attendance])
                self.completion?()
            }
            alert.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: R.string.localizable.commonLabelCancel(),
                                         style: UIAlertActionStyle.cancel)
        alert.addAction(cancelAction)
        AppDelegate.navigation?.present(alert, animated: true, completion: nil)
    }
}
