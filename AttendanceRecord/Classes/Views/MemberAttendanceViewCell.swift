//
//  MemberAttendanceViewCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/01.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal final class MemberAttendanceViewCell: UITableViewCell {
    
    private var completion: (() -> Void)?
    
    @IBOutlet private weak var numberLabel: UILabel!
    @IBOutlet private weak var eventNameLabel: UILabel!
    @IBOutlet private weak var eventDateLabel: UILabel!
    @IBOutlet private weak var attendanceButton: UIButton!
    
    private var viewModel: MemberAttendanceViewModel!
    
    static func instantiate(_ owner: AnyObject, viewModel: MemberAttendanceViewModel,
                            index: Int, completion: (() -> Void)? = nil) -> MemberAttendanceViewCell {
        let cell = R.nib.memberAttendanceViewCell.firstView(owner: owner, options: nil)!
        cell.numberLabel.text = String(index + 1)
        cell.eventNameLabel.text = viewModel.event.eventTitle
        cell.eventDateLabel.text = viewModel.event.eventDate.stringFromDate(format: .displayedYearToDay)
        cell.attendanceButton.setTitle(viewModel.attendance.attendanceStatusRawValue, for: .normal)
        cell.attendanceButton.setTitle(viewModel.attendance.attendanceStatusRawValue, for: .highlighted)
        cell.completion = completion
        cell.viewModel = viewModel
        return cell
    }
    
    @IBAction func didTap(attendanceButton: UIButton) {
        let alert = UIAlertController(title: R.string.localizable.commonLabelAttendanceInput(),
                                      message: viewModel.event.eventDate.stringFromDate(format: .displayedYearToDay),
                                      preferredStyle: .actionSheet)
        
        
        let attendAction = UIAlertAction(title: AttendanceStatus.attend.rawValue, style: UIAlertActionStyle.default) { _ in
            let attendance = self.viewModel.attendance.clone
            attendance.attendanceStatusRawValue = AttendanceStatus.attend.rawValue
            AttendanceManager.shared.saveAttendanceListToRealm([attendance])
            self.completion?()
        }
        let absencAction = UIAlertAction(title: AttendanceStatus.absence.rawValue,  style: UIAlertActionStyle.default) { _ in
            let attendance = self.viewModel.attendance.clone
            attendance.attendanceStatusRawValue = AttendanceStatus.absence.rawValue
            AttendanceManager.shared.saveAttendanceListToRealm([attendance])
            self.completion?()
        }
        let cancelAction = UIAlertAction(title: R.string.localizable.commonLabelCancel(),
                                         style: UIAlertActionStyle.cancel)
        alert.addAction(attendAction)
        alert.addAction(absencAction)
        alert.addAction(cancelAction)
        AppDelegate.navigation?.present(alert, animated: true, completion: nil)
    }
}
