//
//  MemberSelectViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/31.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import CTCheckbox

internal enum SelectType {
    case lessonMember
    case addressMember
    
    var emptyMessage: String {
        switch self {
        case .lessonMember:
            return "選択可能な受講者がいません\n受講者管理から受講者を追加して下さい"
        case .addressMember:
            return "連絡帳に選択可能な受講者がいません\n端末の連絡帳に受講者を追加して下さい"
        }
    }
    
    var alertTitle: String {
        switch self {
        case .lessonMember, .addressMember:
            return R.string.localizable.memberSelectionAlertTitleMemberRegister()
        }
    }
    
    func alertMessage(extra: String) -> String {
        switch self {
        case .lessonMember:
            return R.string.localizable.memberSelectionAlertMessageMemberRegister(extra)
        case .addressMember:
            return "選択されたメンバーを登録してもよろしいですか？"
        }
    }
}

internal final class MemberSelectViewController: UIViewController, HeaderViewDisplayable {
    
    // MARK: IBOutlet
    
    @IBOutlet fileprivate var tableView: UITableView!
    
    @IBOutlet var headerView: HeaderView!
    
    @IBOutlet fileprivate weak var emptyView: UIView!
    
    @IBOutlet fileprivate weak var emptyMessageLabel: UILabel!
    
    
    // MARK: Property
    
    fileprivate var type = SelectType.lessonMember
    
    fileprivate var lesson = Lesson()
    
    fileprivate var memberList: [Member]!
    
    // MARK: Initilizer
    
    static func instantiate() -> MemberSelectViewController {
        let viewController = R.storyboard.memberSelectViewController.memberSelectViewController()!
        viewController.memberList = AddressManager.shared.selectableAddressList()
        viewController.type = .addressMember
        return viewController
    }
    
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
        emptyMessageLabel.text = type.emptyMessage
        emptyView.isHidden = !memberList.isEmpty
        setupHeaderView(R.string.localizable.headerTitleLabelMemberSelect(), buttonTypes: [[.close(nil)], [.selection(HeaderModel() {
            AlertController.showAlert(
                title: self.type.alertTitle,
                message: self.type.alertMessage(extra: self.lesson.lessonTitle),
                enableCancel: true,
                positiveAction: {
                    let checkedMemberList = self.checked.map { self.memberList[$0] }
                    if self.type == .lessonMember {
                        let lessonMemberList = checkedMemberList.map { LessonMember(lessonId: self.lesson.lessonId, memberId: $0.memberId) }
                        LessonManager.shared.saveLessonMemberListToRealm(lessonMemberList)
                    } else {
                        MemberManager.shared.saveMemberListToRealm(checkedMemberList)
                    }
                    UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
                })
            })]])
        updateHeaderButton()
        tableView.register(MemberListTableCell.self)
    }
    
    // MARK: Private Method
    
    fileprivate var checked = [Int]()
    
    fileprivate func updateHeaderButton() {
        if checked.count == 0 {
            refreshHeaderView(enabled: false, buttonTypes: [[],[.selection(nil)]])
        } else {
            refreshHeaderView(enabled: true, buttonTypes: [[],[.selection(nil)]])
        }
    }
}

extension MemberSelectViewController: UITableViewDataSource {
    
    // MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memberList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let checked = self.checked.index(of: indexPath.row) != nil ? true : false
        let cell = tableView.dequeueReusableCell(for: indexPath) as MemberListTableCell
        cell.setup(self, member: memberList[indexPath.row], index: indexPath.row, checked: checked)
        return cell
    }
}

extension MemberSelectViewController: CheckBoxDelegate {
    func changeCheckbox(checkbox: CTCheckbox, index: Int) {
        if checkbox.checked {
            checked.append(index)
        } else {
            checked.remove(at: checked.index(of: index)!)
        }
        updateHeaderButton()
    }
}
