//
//  SideMenuViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/25.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal final class SideMenuViewController: UIViewController, ModeVariety {
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var topLabel: UILabel!
    
    var mode: Mode = .member
    
    // MARK: - Initializer
    
    static func instantiate() -> SideMenuViewController {
        return R.storyboard.sideMenuViewController.sideMenuViewController()!
    }
    
    // MARK: - View Life Cycle
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        topLabel.text = R.string.localizable.sideMenuHeaderLabelMenuList(mode.buttonText)
    }
    
    // MARK: - IBAction
    
    @IBAction func settingButtonAction(_ settingButton: UIButton) {
        SideMenuItem.setting.selected()
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
            switch (self, DeviceModel.mode) {
            case (.memberList, _): return R.string.localizable.sideMenuLabelAttendanceMemberList()
            case (.lessonList, .organizer): return R.string.localizable.sideMenuLabelLessonList()
            case (.lessonList, .member): return R.string.localizable.sideMenuLabelAttendanceLessonList()
            case (.attendanceTable, _): return R.string.localizable.sideMenuLabelAttendanceTable()
            case (.backNumber, _): return R.string.localizable.sideMenuLabelBackNumber()
            case (.setting, _): return R.string.localizable.sideMenuLabelSetting()
            }
        }
        
        var destinationViewController: UIViewController {
            switch self {
            case .memberList: return ListViewController.instantiate(type: .member(nil))
            case .lessonList: return ListViewController.instantiate(type: .lesson(nil))
            case .attendanceTable: return ListViewController.instantiate(type: .attendance(nil))
            case .backNumber: return CommonWebViewController.instantiate(requestType: .backNumber)
            case .setting: return SettingViewController.instantiate()
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
        case .organizer: return [[.lessonList,.memberList, .attendanceTable]]
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

extension SideMenuViewController {
    
    func changeContentViewController(viewControllerList: [UIViewController]? = nil) {
        guard let viewControllers = viewControllerList else {
            if let item = menuItems.first?.first {
                AppDelegate.navigation?.setViewControllers([item.destinationViewController], animated: false)
            }
            return
        }
        AppDelegate.navigation?.setViewControllers(viewControllers, animated: false)
    }
    
    func reloadScreen() {
        if mode != DeviceModel.mode {
            mode = DeviceModel.mode
            changeContentViewController()
        }
        tableView.reloadData()
    }
}
