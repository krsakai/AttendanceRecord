//
//  MemberSearchViewCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/02.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal final class MemberSearchViewCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var nameLabel: UILabel!
    
    static func instantiate(owner: AnyObject, peripheralDevice: PeripheralDevice) -> MemberSearchViewCell {
        let cell = R.nib.memberSearchViewCell.firstView(owner: owner, options: nil)!
        cell.nameLabel.text = peripheralDevice.memberName
        return cell
    }
}
