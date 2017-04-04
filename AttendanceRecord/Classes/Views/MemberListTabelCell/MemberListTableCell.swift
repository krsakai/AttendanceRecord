//
//  MemberListTableCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/26.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import SnapKit
import CTCheckbox
import RealmSwift
import SWTableViewCell

internal class MemberListTableCell: SWTableViewCell {
    
    @IBOutlet private weak var leftView: UIView!

    @IBOutlet private weak var nameJpLabel: UILabel!
    @IBOutlet private weak var nameKanaLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    
    var checkbox: CTCheckbox!
    
    var member: Member!
    
    override var entity: Object? {
        return member as Object
    }
    
    static func instantiate(_ owner: AnyObject, member: Member) -> MemberListTableCell {
        let cell = R.nib.memberListTableCell.firstView(owner: owner, options: nil)!
        cell.nameJpLabel.text = member.nameJp
        cell.nameKanaLabel.text = member.nameKana
        cell.emailLabel.text = member.email
        cell.member = member
        
        guard DeviceModel.mode == .organizer else {
            return cell
        }
        
        guard owner is SWTableViewCellDelegate else {
            cell.checkbox = CTCheckbox(frame: CGRect(x: cell.leftView.frame.size.width/2 - 25, y: cell.frame.size.height/2 - 35, width: 50, height: 50))
            cell.checkbox.checkboxSideLength = 30
            cell.checkbox.addTarget(cell, action: #selector(MemberListTableCell.changeCheckbox), for: .valueChanged)
            cell.checkbox.setColor(DeviceModel.themeColor.color, for: .normal)
            cell.checkbox.setColor(DeviceModel.themeColor.color, for: .highlighted)
            cell.addSubview(cell.checkbox)
            cell.checkbox.layoutIfNeeded()
            return cell
        }
        
        let utilityButtons = NSMutableArray()
        utilityButtons.sw_addUtilityButton(with: AttendanceRecordColor.Cell.red, title: "削除")
        cell.rightUtilityButtons = utilityButtons as [AnyObject]
        cell.delegate = owner as! SWTableViewCellDelegate
        return cell
    }
    
    func changeCheckbox(checkbox: CTCheckbox) {
        
    }
}
