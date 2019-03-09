//
//  MemberSettingCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/04.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal enum MemberSettingType {
    case nameJp
    case email
    case fullNameSort
    
    var title: String {
        switch self {
        case .nameJp: return R.string.localizable.settingLabelMemberName()
        case .email: return R.string.localizable.settingLabelMemberEmail()
        case .fullNameSort: return "名前順(フルネーム)並び替え"
        }
    }
    
    var setting: Bool {
        get {
            switch self {
            case .nameJp: return DeviceModel.isRequireMemberName
            case .email: return DeviceModel.isRequireEmail
            case .fullNameSort: return DeviceModel.isFullNameSort
            }
        }
        set {
            switch self {
            case .nameJp: DeviceModel.isRequireMemberName = newValue
            case .email: DeviceModel.isRequireEmail = newValue
            case .fullNameSort: DeviceModel.isFullNameSort = newValue
            }
        }
    }
}

internal class MemberSettingCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    @IBOutlet private var settingSwitch: UISwitch!
    
    fileprivate var type: MemberSettingType!
    
    static func instantiate(_ owner: AnyObject, type: MemberSettingType) -> MemberSettingCell {
        let cell = R.nib.memberSettingCell.firstView(owner: owner, options: nil)!
        cell.type = type
        cell.titleLabel.text = type.title
        cell.settingSwitch.tintColor = DeviceModel.themeColor.color
        cell.settingSwitch.onTintColor = DeviceModel.themeColor.color
        cell.settingSwitch.isOn = type.setting
        return cell
    }
    
    @IBAction func valueChanged(settingSwitch: UISwitch) {
        type.setting = settingSwitch.isOn
    }
}
