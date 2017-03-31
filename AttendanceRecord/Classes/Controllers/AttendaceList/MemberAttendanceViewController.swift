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
            [[.back],[]]
        )
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
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
