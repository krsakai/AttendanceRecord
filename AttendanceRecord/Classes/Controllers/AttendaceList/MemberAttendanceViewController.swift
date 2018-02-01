//
//  MemberAttendanceViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/01.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal final class MemberAttendanceViewController: UIViewController, HeaderViewDisplayable {
    
    @IBOutlet weak var headerView: HeaderView!
    
    @IBOutlet private weak var tableView: UITableView!
    
    fileprivate var event: Event!
    
    // MARK: - Initializer
    
    static func instantiate(event: Event) -> MemberAttendanceViewController {
        let viewController = R.storyboard.memberAttendanceViewController.memberAttendanceViewController()!
        viewController.event = event
        return viewController
    }
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorColor = DeviceModel.themeColor.color
        setupHeaderView(event.eventTitle, buttonTypes:
            [[.back],[.bulk(HeaderModel() {
                let alert = UIAlertController(title: R.string.localizable.commonLabelAttendanceInput(),
                                              message: R.string.localizable.commonLabelBulkInput(),
                                              preferredStyle: .actionSheet)
                
                
                let attendAction = UIAlertAction(title: AttendanceStatus.attend.rawValue, style: UIAlertActionStyle.default) { _ in
                    let attendanceList = self.viewModels.map { viewModel -> Attendance in
                        let attendance = viewModel.attendance.clone
                        attendance.attendanceStatusRawValue = AttendanceStatus.attend.rawValue
                        return attendance
                    }
                    AttendanceManager.shared.saveAttendanceListToRealm(attendanceList)
                    self.tableView.reloadData()
                }
                let absencAction = UIAlertAction(title: AttendanceStatus.absence.rawValue,  style: UIAlertActionStyle.default) { _ in
                    let attendanceList = self.viewModels.map { viewModel -> Attendance in
                        let attendance = viewModel.attendance.clone
                        attendance.attendanceStatusRawValue = AttendanceStatus.absence.rawValue
                        return attendance
                    }
                    AttendanceManager.shared.saveAttendanceListToRealm(attendanceList)
                    self.tableView.reloadData()
                }
                let noEntryAction = UIAlertAction(title: AttendanceStatus.noEntry.rawValue,  style: UIAlertActionStyle.default) { _ in
                    let attendanceList = self.viewModels.map { viewModel -> Attendance in
                        let attendance = viewModel.attendance.clone
                        attendance.attendanceStatusRawValue = AttendanceStatus.noEntry.rawValue
                        return attendance
                    }
                    AttendanceManager.shared.saveAttendanceListToRealm(attendanceList)
                    self.tableView.reloadData()
                }
                let cancelAction = UIAlertAction(title: R.string.localizable.commonLabelCancel(),
                                                 style: UIAlertActionStyle.cancel)
                alert.addAction(attendAction)
                alert.addAction(absencAction)
                alert.addAction(noEntryAction)
                alert.addAction(cancelAction)
                AppDelegate.navigation?.present(alert, animated: true, completion: nil)
            })]]
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
}

extension MemberAttendanceViewController: UITableViewDataSource {
    
    static let defalutCellRowHeight = CGFloat(100)
    
    var viewModels: [AttendanceViewModel] {
        return AttendanceManager.shared.eventAttendanceViewModels(event: event)
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return MemberAttendanceViewController.defalutCellRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return MemberAttendanceViewCell.instantiate(tableView, viewModel: viewModels[indexPath.row],
                                                    index: indexPath.row) { _ in
            tableView.reloadData()
        }
    }
}

extension MemberAttendanceViewController: UITableViewDelegate {
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let attendance = viewModels[indexPath.row].attendance
        let viewController = MemoViewController.instantiate(attendance: attendance)
        navigationController?.pushViewController(viewController, animated: true)
    }
}
