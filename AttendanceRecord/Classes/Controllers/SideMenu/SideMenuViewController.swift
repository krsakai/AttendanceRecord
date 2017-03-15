//
//  SideMenuViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/25.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal final class SideMenuViewController: UIViewController, ModeVariety {
    
    @IBOutlet private weak var tableView: UITableView!
    var mode: Mode = .member
    
    // MARK: - Initializer
    
    static func instantiate() -> SideMenuViewController {
        return R.storyboard.sideMenuViewController.sideMenuViewController()!
    }
    
    // MARK: - Action
    
    @IBAction func settingButtonAction(_ settingButton: UIButton) {
        SideMenuItem.setting.selected()
    }
    
    func refresh(mode: Mode) {
        self.mode = mode
        tableView.reloadData()
    }
}

extension SideMenuViewController: UITableViewDataSource {
    
    static let defalutCellRowHeight = CGFloat(64)
    
    enum SideMenuItem {
        case memberList
        case lessonList
        case attendanceTable
        case backNumber
        case setting
        
        var title: String {
            switch self {
            case .memberList: return R.string.localizable.sideMenuLabelMemberList()
            case .lessonList: return R.string.localizable.sideMenuLabelLessonList()
            case .attendanceTable: return R.string.localizable.sideMenuLabelAttendanceTable()
            case .backNumber: return R.string.localizable.sideMenuLabelBackNumber()
            case .setting: return R.string.localizable.sideMenuLabelSetting()
            }
        }
        
        var destinationViewController: UIViewController {
            switch self {
            case .memberList: return ListViewController.instantiate(type: .member(nil))
            case .lessonList: return ListViewController.instantiate(type: .lesson(nil))
            case .attendanceTable: return CommonWebViewController.instantiate(requestType: .attendanceList)
            case .backNumber: return CommonWebViewController.instantiate(requestType: .backNumber)
            case .setting: return CommonWebViewController.instantiate(requestType: .none)
            }
        }
        
        func cell(owner: AnyObject) -> SideMenuTableCell {
            switch self {
            case .memberList, .attendanceTable, .backNumber, .lessonList, .setting:
                return SideMenuTableCell.instantiate(owner, menuItem: self)
            }
        }
        
        func selected(completion: ((Bool) -> Void)? = nil) {
            switch self {
            case .memberList, .attendanceTable, .backNumber, .lessonList:
                AppDelegate.navigation?.evo_drawerController?.closeDrawer(animated: true, completion: completion)
                AppDelegate.navigation?.setViewControllers([destinationViewController], animated: false)
            case .setting:
                AppDelegate.navigation?.present(destinationViewController, animated: true, completion: nil)
            }
        }
    }
    
    var menuItems: [[SideMenuItem]] {
        switch mode {
        case .member: return [[.lessonList]]
        case .organizer: return [[.lessonList,.memberList]]
        }
        
    }
    
    // MARK: - UITableView DataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems[section].count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return menuItems.count
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return SideMenuViewController.defalutCellRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuItem = menuItems[indexPath.section][indexPath.row]
        return menuItem.cell(owner: tableView)
    }
}

extension SideMenuViewController: UITableViewDelegate {
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let menuItem = menuItems[indexPath.section][indexPath.row]
        menuItem.selected() { _ in
            tableView.deselectRow(at: indexPath, animated: false)
        }
        
    }
}
