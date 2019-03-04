//
//  MemberAttendanceViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/01.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import SWTableViewCell

internal final class MemberAttendanceViewController: UIViewController, HeaderViewDisplayable {
    
    @IBOutlet weak var headerView: HeaderView!
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    @IBOutlet fileprivate weak var emptyView: UIView!
    
    fileprivate var event: Event!
    
    fileprivate var editMode = false
    
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
            [[.back],[
                .edit(HeaderModel() {
                    let alert = UIAlertController(title: "表示設定",
                                                  message: "出席しないメンバーの非表示設定変更",
                                                  preferredStyle: .actionSheet)
                    
                    
                    let attendAction = UIAlertAction(title: self.editMode ? "設定モード解除" : "設定モード", style: UIAlertActionStyle.default) { _ in
                        if self.editMode {
                            self.editMode = false
                            self.tableView.visibleCells.forEach { cell in
                                if let swCell = cell as? SWTableViewCell {
                                    swCell.hideUtilityButtons(animated: true)
                                }
                            }
                        } else {
                            self.editMode = true
                            self.tableView.visibleCells.forEach { cell in
                                if let swCell = cell as? SWTableViewCell {
                                    swCell.showLeftUtilityButtons(animated: true)
                                }
                            }
                        }
                    }
                    let absencAction = UIAlertAction(title: "全ての非表示設定を取り消す",  style: UIAlertActionStyle.default) { _ in
                        let list = AttendanceManager.shared.eventAttendanceViewModels(event: self.event, filterHidden: false)
                        AttendanceManager.shared.saveAttendanceListToRealm(list.map { model in
                            let attendance = model.attendance.clone
                            attendance.isHidden = false
                            return attendance
                        })
                        self.tableView.reloadData()
                    }
                    let cancelAction = UIAlertAction(title: R.string.localizable.commonLabelCancel(),
                                                     style: UIAlertActionStyle.cancel)
                    alert.addAction(attendAction)
                    alert.addAction(absencAction)
                    alert.addAction(cancelAction)
                    AppDelegate.navigation?.present(alert, animated: true, completion: nil)
                }),
                .bulk(HeaderModel() {
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
        let attendaceList = AttendanceManager.shared.eventAttendanceViewModels(event: event)
        emptyView.isHidden = !attendaceList.isEmpty
        return attendaceList
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
        return MemberAttendanceViewCell.instantiate(self, viewModel: viewModels[indexPath.row],
                                                    index: indexPath.row, editMode: editMode) { _ in
            StoreReviewManager.shared.operateAttendance = true
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

// MARK: - SWTableViewCellDelegate

extension MemberAttendanceViewController: SWTableViewCellDelegate {
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerLeftUtilityButtonWith index: Int) {
        
        let attendanceList = self.viewModels.map { viewModel -> Attendance in
            return viewModel.attendance.clone
        }
        guard let index = tableView.indexPath(for: cell)?.row else {
            return
        }
        attendanceList[index].isHidden = true
        AttendanceManager.shared.saveAttendanceListToRealm(attendanceList)
        self.tableView.reloadData()
    }
}

