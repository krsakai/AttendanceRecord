//
//  MemberSelectViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/31.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import CTCheckbox

internal final class MemberSelectViewController: UIViewController, HeaderViewDisplayable {
    
    // MARK: IBOutlet
    
    @IBOutlet fileprivate var tableView: UITableView!
    
    @IBOutlet var headerView: HeaderView!
    
    // MARK: Property
    
    fileprivate var lesson: Lesson!
    
    fileprivate var memberList: [Member]!
    
    // MARK: Initilizer
    
    static func instantiate(lesson: Lesson) -> MemberSelectViewController {
        let viewController = R.storyboard.memberSelectViewController.memberSelectViewController()!
        viewController.lesson = lesson
        viewController.memberList = MemberManager.shared.memberListDataFromRealm().filter { member in
            let lessonMemberList = LessonManager.shared.lessonMemberListDataFromRealm(predicate: LessonMember.predicate(lessonId: lesson.lessonId))
            var check: Bool = true
            lessonMemberList.forEach { lessonMember in
                if lessonMember.memberId == member.memberId { check = false }
            }
            return check
        }
        return viewController
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
         super.viewDidLoad()
        setupHeaderView(R.string.localizable.headerTitleLabelMemberSelect(), buttonTypes: [[.close(nil)], [.selection(HeaderModel() {
            AlertController.showAlert(title: R.string.localizable.memberSelectionAlertTitleMemberRegister(),
                                      message: R.string.localizable.memberSelectionAlertMessageMemberRegister(self.lesson.lessonTitle),
                                      enableCancel: true, positiveAction: {
                let selectCellList = self.cells.filter { $0.checkbox.checked }
                let lessonMemberList = selectCellList.map { LessonMember(lessonId: self.lesson.lessonId, memberId: $0.member.memberId) }
                LessonManager.shared.saveLessonMemberListToRealm(lessonMemberList)
                UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
            })
        })]])
        updateHeaderButton()
    }
    
    // MARK: Private Method
    
    fileprivate var cells: [MemberListTableCell] {
        guard self.tableView.numberOfRows(inSection: 0) > 0 else {
            return [MemberListTableCell]()
        }
        return (0...self.tableView.numberOfRows(inSection: 0) - 1 ).map { row in
            self.tableView.cellForRow(at: IndexPath(row: row, section: 0)) as! MemberListTableCell
        }
    }
    
    fileprivate func updateHeaderButton() {
        guard let _ = (cells.filter { $0.checkbox.checked }.first) else {
            refreshHeaderView(enabled: false, buttonTypes: [[],[.selection(nil)]])
            return
        }
        refreshHeaderView(enabled: true, buttonTypes: [[],[.selection(nil)]])
    }
}

extension MemberSelectViewController: UITableViewDataSource {
    
    // MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return MemberListTableCell.instantiate(self, member: memberList[indexPath.row])
    }
}

extension MemberSelectViewController: CheckBoxDelegate {
    func changeCheckbox(checkbox: CTCheckbox) {
        updateHeaderButton()
    }
}
