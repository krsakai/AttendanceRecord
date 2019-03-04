//
//  MemberAttendanceViewCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/01.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import SWTableViewCell

internal final class MemberAttendanceViewCell: SWTableViewCell {
    
    private var completion: (() -> Void)?
    
    @IBOutlet private weak var kanaNameLabel: UILabel!
    @IBOutlet private weak var jpNameLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    @IBOutlet private weak var attendanceButton: UIButton!
    
    private var viewModel: AttendanceViewModel!
    
    static func instantiate(_ owner: SWTableViewCellDelegate, viewModel: AttendanceViewModel,
                            index: Int, editMode: Bool = false ,
                            completion: (() -> Void)? = nil) -> MemberAttendanceViewCell {
        let cell = R.nib.memberAttendanceViewCell.firstView(owner: owner, options: nil)!
        cell.kanaNameLabel.text = viewModel.member.nameKana
        cell.jpNameLabel.text = viewModel.member.nameJp
        cell.emailLabel.text = viewModel.member.email
        cell.attendanceButton.setTitle(viewModel.attendance.attendanceStatusRawValue, for: .normal)
        cell.attendanceButton.setTitle(viewModel.attendance.attendanceStatusRawValue, for: .highlighted)
        cell.attendanceButton.setTitleColor(DeviceModel.themeColor.color, for: .normal)
        cell.attendanceButton.setTitleColor(DeviceModel.themeColor.color, for: .highlighted)
        cell.completion = completion
        cell.viewModel = viewModel
        let utilityButtons = NSMutableArray()
        utilityButtons.sw_addUtilityButton(with: DeviceModel.themeColor.color, title: "非表示")
        cell.leftUtilityButtons = utilityButtons as [AnyObject]
        cell.delegate = owner
        if editMode {
            cell.showLeftUtilityButtons(animated: false)
        } else {
            cell.hideUtilityButtons(animated: false)
        }
        return cell
    }
    
    @IBAction func didTap(attendanceButton: UIButton) {
        let alert = UIAlertController(title: R.string.localizable.commonLabelAttendanceInput(),
                                      message: viewModel.member.nameJp,
                                      preferredStyle: .actionSheet)
        
        
        let attendAction = UIAlertAction(title: AttendanceStatus.attend.rawValue, style: UIAlertActionStyle.default) { _ in
            let attendance = self.viewModel.attendance.clone
            attendance.attendanceStatusRawValue = AttendanceStatus.attend.rawValue
            AttendanceManager.shared.saveAttendanceListToRealm([attendance])
            self.completion?()
        }
        
        let undfineAction = UIAlertAction(title: AttendanceStatus.undfine.rawValue,  style: UIAlertActionStyle.default) { _ in
            let attendance = self.viewModel.attendance.clone
            attendance.attendanceStatusRawValue = AttendanceStatus.undfine.rawValue
            AttendanceManager.shared.saveAttendanceListToRealm([attendance])
            self.completion?()
        }
        let absencAction = UIAlertAction(title: AttendanceStatus.absence.rawValue,  style: UIAlertActionStyle.default) { _ in
            let attendance = self.viewModel.attendance.clone
            attendance.attendanceStatusRawValue = AttendanceStatus.absence.rawValue
            AttendanceManager.shared.saveAttendanceListToRealm([attendance])
            self.completion?()
        }
        let noEntryAction = UIAlertAction(title: AttendanceStatus.noEntry.rawValue,  style: UIAlertActionStyle.default) { _ in
            let attendance = self.viewModel.attendance.clone
            attendance.attendanceStatusRawValue = AttendanceStatus.noEntry.rawValue
            AttendanceManager.shared.saveAttendanceListToRealm([attendance])
            self.completion?()
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.commonLabelCancel(),
                                         style: UIAlertActionStyle.cancel)
        alert.addAction(attendAction)
        alert.addAction(undfineAction)
        alert.addAction(absencAction)
        alert.addAction(noEntryAction)
        alert.addAction(cancelAction)
        AppDelegate.navigation?.present(alert, animated: true, completion: nil)
    }
}
