//
//  GroupTableViewCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2019/03/04.
//  Copyright © 2019年 酒井邦也. All rights reserved.
//

import UIKit
import RealmSwift
import SWTableViewCell

internal final class GroupTableViewCell: SWTableViewCell, NibRegistrable {
    
    @IBOutlet private weak var groupTitleLabel: UILabel!
    
    private var group: Group!
    
    override var entity: Object? {
        return group as Object
    }
    
    func setup(_ owner: SWTableViewCellDelegate, group: Group, listType: ListType) {
        groupTitleLabel.text = group.groupTitle
        self.group = group
        
        if DeviceModel.mode == .member, case .attendance = listType {
            return
        }
        
        let utilityButtons = NSMutableArray()
        utilityButtons.sw_addUtilityButton(with: AttendanceRecordColor.Cell.red, title: "削除")
        rightUtilityButtons = utilityButtons as [AnyObject]
        delegate = owner
    }
}
