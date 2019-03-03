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

internal protocol CheckBoxDelegate {
    func changeCheckbox(checkbox: CTCheckbox, index: Int)
}

internal class MemberListTableCell: SWTableViewCell, NibRegistrable {
    
    @IBOutlet private weak var leftView: UIView!

    @IBOutlet private weak var nameJpLabel: UILabel!
    @IBOutlet private weak var nameKanaLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    
    private var checkboxDelegate: CheckBoxDelegate?
    
    var checkbox: CTCheckbox!
    
    var index: Int!
    
    var member: Member!
    
    override var entity: Object? {
        return member as Object
    }
    
    func changeCheckbox(checkbox: CTCheckbox) {
        checkboxDelegate?.changeCheckbox(checkbox: checkbox, index: index)
    }
    
    func setup(_ owner: AnyObject, member: Member, index: Int = 0, checked: Bool = false) {
        self.index = index
        checkboxDelegate = owner as? CheckBoxDelegate
        nameJpLabel.text = member.nameJp
        nameKanaLabel.text = member.nameKana
        emailLabel.text = member.email
        self.member = member
        
        guard DeviceModel.mode == .organizer else {
            return
        }
        
        guard owner is SWTableViewCellDelegate else {
            checkbox = CTCheckbox(frame: CGRect(x: leftView.frame.size.width/2 - 25, y: frame.size.height/2 - 35, width: 50, height: 50))
            checkbox.checkboxSideLength = 30
            checkbox.checked = checked
            checkbox.addTarget(self, action: #selector(MemberListTableCell.changeCheckbox), for: .valueChanged)
            checkbox.setColor(DeviceModel.themeColor.color, for: .normal)
            checkbox.setColor(DeviceModel.themeColor.color, for: .highlighted)
            addSubview(checkbox)
            checkbox.layoutIfNeeded()
            return
        }
        
        let utilityButtons = NSMutableArray()
        utilityButtons.sw_addUtilityButton(with: AttendanceRecordColor.Cell.red, title: "削除")
        rightUtilityButtons = utilityButtons as [AnyObject]
        delegate = owner as! SWTableViewCellDelegate
    }
}
