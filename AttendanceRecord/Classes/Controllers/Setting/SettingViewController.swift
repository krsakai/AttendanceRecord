//
//  SettingViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/28.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal enum Setting {
    case mode
    case themeColor
    case member(MemberSettingType)
    
    var title: String {
        switch self {
        case .mode: return R.string.localizable.modeTitleLabelModeSelect()
        case .themeColor: return R.string.localizable.modeTitleLabelThemeSelect()
        case .member: return R.string.localizable.modeTitleLabelMemberSetting()
        }
    }
    
    func cell(owner: AnyObject) -> UITableViewCell {
        switch self {
        case .mode: return ModeChangeCell.instantiate(owner)
        case .themeColor: return ThemeColorSelectCell.instantiate(owner)
        case .member(let type): return MemberSettingCell.instantiate(owner, type: type)
        }
    }
}

internal final class SettingViewController: UIViewController, HeaderViewDisplayable  {
    
    @IBOutlet weak var headerView: HeaderView!
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var settingList: [[Setting]] {
        return [[.mode], [.themeColor], [.member(.nameJp),.member(.email)]]
    }
    
    // MARK: - Initializer
    
    static func instantiate() -> SettingViewController {
        let viewController = R.storyboard.settingViewController.settingViewController()!
        return viewController
    }
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView(R.string.localizable.headerTitleLabelSettings(),
                        buttonTypes: [[.close(nil)],[]])
    }
}

extension SettingViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return settingList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return settingList[section][0].title
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settingList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return settingList[indexPath.section][indexPath.row].cell(owner: tableView)
    }
}

extension SettingViewController: ScreenReloadable {
    func reloadScreen() {
        headerView.refreshLayout()
        tableView.reloadData()
    }
}
