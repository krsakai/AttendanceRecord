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
    
    @IBOutlet fileprivate weak var countLabel: UILabel!
    
    @IBOutlet fileprivate weak var filterButton: UIButton!
    
    @IBOutlet fileprivate weak var lineView: UIView!
    
    @IBOutlet fileprivate weak var filteredLabel: UILabel!
    
    @IBOutlet fileprivate weak var hiddenSettingLabel: UILabel!
    
    fileprivate var event: Event!
    
    fileprivate var editMode = false
    
    fileprivate var filterStatus: AttendanceStatus?
    
    fileprivate var viewModels: [AttendanceViewModel] = [AttendanceViewModel]()
    
    // MARK: - Initializer
    
    static func instantiate(event: Event) -> MemberAttendanceViewController {
        let viewController = R.storyboard.memberAttendanceViewController.memberAttendanceViewController()!
        viewController.event = event
        return viewController
    }
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        filteredLabel.textColor = AttendanceRecordColor.Common.red
        hiddenSettingLabel.textColor = AttendanceRecordColor.Common.red
        lineView.backgroundColor = DeviceModel.themeColor.color
        lineView.alpha = 0.5
        countLabel.textColor = DeviceModel.themeColor.color
        filterButton.setTitleColor(DeviceModel.themeColor.color, for: .normal)
        filterButton.setTitleColor(DeviceModel.themeColor.color, for: .highlighted)
        filterButton.layer.borderColor = DeviceModel.themeColor.color.cgColor
        filterButton.layer.borderWidth = 1
        filterButton.layer.cornerRadius = filterButton.frame.height / 2
        tableView.separatorColor = DeviceModel.themeColor.color
        tableView.register(MemberAttendanceViewCell.self)
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
                        self.reloadData()
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
                
                AttendanceManager.shared.attendanceStatusListDataFromRealm().forEach { status in
                    let action = UIAlertAction(title: status.rawValue, style: UIAlertActionStyle.default) { _ in
                        let attendanceList = self.viewModels.map { viewModel -> Attendance in
                            let attendance = viewModel.attendance.clone
                            attendance.attendanceStatusRawValue = status.rawValue
                            return attendance
                        }
                        AttendanceManager.shared.saveAttendanceListToRealm(attendanceList)
                        self.reloadData()
                    }
                    alert.addAction(action)
                }
                
                let cancelAction = UIAlertAction(title: R.string.localizable.commonLabelCancel(),
                                                 style: UIAlertActionStyle.cancel)
                    
                alert.addAction(cancelAction)
                AppDelegate.navigation?.present(alert, animated: true, completion: nil)
            })]]
        )
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        reloadData()
    }
    
    @IBAction func didFileterButtonTapped(_ sender: Any) {
        
        let alert = UIAlertController(title: "ステータスによる絞り込み",
                                      message: "選択したステータスのメンバーのみ表示します",
                                      preferredStyle: .actionSheet)
        
        AttendanceManager.shared.attendanceStatusListDataFromRealm().forEach { status in
            let action = UIAlertAction(title: status.rawValue, style: UIAlertActionStyle.default) { _ in
                self.filterStatus = status
                self.filteredLabel.text = status.rawValue
                self.filteredLabel.isHidden = false
                self.reloadData()
            }
            alert.addAction(action)
        }
        let action = UIAlertAction(title: "絞り込み解除", style: UIAlertActionStyle.default) { _ in
            self.filterStatus = nil
            self.filteredLabel.text = ""
            self.filteredLabel.isHidden = true
            self.reloadData()
        }
        alert.addAction(action)
        let cancelAction = UIAlertAction(title: R.string.localizable.commonLabelCancel(),
                                         style: UIAlertActionStyle.cancel)
        
        alert.addAction(cancelAction)
        AppDelegate.navigation?.present(alert, animated: true, completion: nil)
    }
}

extension MemberAttendanceViewController: UITableViewDataSource {
    
    static let defalutCellRowHeight = CGFloat(100)
    
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
        let cell = tableView.dequeueReusableCell(for: indexPath) as MemberAttendanceViewCell
        cell.setup(self,
            viewModel: viewModels[indexPath.row],
            index: indexPath.row,
            editMode: editMode) { _ in
                StoreReviewManager.shared.operateAttendance = true
                self.reloadData()
        }
        return cell
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

extension MemberAttendanceViewController: UIGestureRecognizerDelegate {
    @objc func attendanceButtonLongPress(_ recognizer: UILongPressGestureRecognizer) {
        
        guard recognizer.state == UIGestureRecognizerState.began else {
            return
        }
        var inputTextField: UITextField?
        let alertController: UIAlertController = UIAlertController(
            title: "ステータスの追加",
            message: "3文字以内の任意のステータスを追加できます。1度登録したら削除できません",
            preferredStyle: .alert
        )
        
        let addAction: UIAlertAction = UIAlertAction(title: "追加", style: .default) { action -> Void in
            if let text = inputTextField?.text, text.count != 0, text.count < 4 {
                AttendanceManager.shared.saveAttendanceStatusListToRealm([AttendanceStatus(rawValue: text)])
            } else {
                 let alertController: UIAlertController = UIAlertController(
                    title: "文字数制限",
                    message: "1〜3文字の任意の文字列を入力してください",
                    preferredStyle: .alert
                )
                let action: UIAlertAction = UIAlertAction(title: "OK", style: .default)
                alertController.addAction(action)
                UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
            }
        }
        let cancelAction: UIAlertAction = UIAlertAction(title: "キャンセル", style: .cancel)
        alertController.addAction(addAction)
        alertController.addAction(cancelAction)
        
        alertController.addTextField { textField -> Void in
            inputTextField = textField
            textField.placeholder = "任意のステータス"
        }
        UIApplication.topViewController()?.present(alertController, animated: true, completion: nil)
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
        self.reloadData()
    }
}

extension MemberAttendanceViewController {
    func reloadData() {
        let nonFilterList = AttendanceManager.shared.eventAttendanceViewModels(event: event, filterHidden: false)
        let attendaceList = AttendanceManager.shared.eventAttendanceViewModels(event: event, filterStatus: filterStatus)
        let isHiddenList = AttendanceManager.shared.attendanceListDataFromRealm(
            predicate: Attendance.predicate(event: event)
        )
        emptyView.isHidden = !attendaceList.isEmpty
        hiddenSettingLabel.isHidden = isHiddenList.isEmpty
        countLabel.text = "\(nonFilterList.count)人中 \(attendaceList.count)人表示"
        self.viewModels = attendaceList
        self.tableView.reloadData()
    }
}
