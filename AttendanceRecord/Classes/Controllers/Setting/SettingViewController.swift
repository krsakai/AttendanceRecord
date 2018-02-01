//
//  SettingViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/28.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import GoogleMobileAds

internal enum Setting {
    case mode
    case themeColor
    case member(MemberSettingType)
    case mailAddress
    case fileimport
    
    var title: String {
        switch self {
        case .mode: return R.string.localizable.modeTitleLabelModeSelect()
        case .themeColor: return R.string.localizable.modeTitleLabelThemeSelect()
        case .member: return R.string.localizable.modeTitleLabelMemberSetting()
        case .mailAddress: return R.string.localizable.settingLabelEmailAddress()
        case .fileimport: return R.string.localizable.settingLabelDataDataManagement()
        }
    }
    
    func cell(owner: AnyObject) -> UITableViewCell {
        switch self {
        case .mode: return ModeChangeCell.instantiate(owner)
        case .themeColor: return ThemeColorSelectCell.instantiate(owner)
        case .member(let type): return MemberSettingCell.instantiate(owner, type: type)
        case .mailAddress: return MailSettingCell.instantiate(owner: owner)
        case .fileimport: return FileImportCell.instantiate(owner: owner)
        }
    }
}

internal final class SettingViewController: UIViewController, HeaderViewDisplayable  {
    
    @IBOutlet weak var headerView: HeaderView!
    
    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    fileprivate var settingList: [[Setting]] {
        return [ [.member(.nameJp),.member(.email)], [.mailAddress], [.themeColor], [.mode], [.fileimport]]
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
        bannerView.rootViewController = self
        let request = GADRequest()
        #if DEBUG
            request.testDevices = [kGADSimulatorID]
        #endif
        bannerView.load(request)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let request = GADRequest()
        #if DEBUG
            request.testDevices = [kGADSimulatorID]
        #endif
        bannerView.load(request)
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
