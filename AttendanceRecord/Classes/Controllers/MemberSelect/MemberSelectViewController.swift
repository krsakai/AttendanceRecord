//
//  MemberSelectViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/31.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

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
        viewController.memberList = MemberManager.shared.memberListDataFromRealm()
        return viewController
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
         super.viewDidLoad()
        setupHeaderView(R.string.localizable.headerTitleLabelMemberSelect(), buttonTypes: [[.close(nil)],[]])
    }
    
    // MARK: Private Method
    
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

extension MemberSelectViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        LessonManager.shared.saveLessonMemberListToRealm([LessonMember(lessonId: lesson.lessonId, memberId: memberList[indexPath.row].memberId)])
        dismiss(animated: true, completion: nil)
    }
}
