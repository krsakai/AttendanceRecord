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
    
    fileprivate var member: Member!
    
    // MARK: - Initializer
    
    static func instantiate(member: Member) -> MemberAttendanceViewController {
        let viewController = R.storyboard.memberAttendanceViewController.memberAttendanceViewController()!
        viewController.member = member
        return viewController
    }
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView(member.nameJp, buttonTypes: [[.back], [.delete({
            MemberManager.shared.removeMemberToRealm(self.member)
        })]])
    }
}

extension MemberAttendanceViewController: UITableViewDataSource {
    
    static let defalutCellRowHeight = CGFloat(100)
    
    var viewModels: [MemberAttendanceViewModel] {
        return AttendanceManager.shared.memberAttendanceViewModels(member: member)
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
