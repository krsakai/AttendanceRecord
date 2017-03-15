//
//  MemberListTableCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/26.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal class MemberListTableCell: UITableViewCell {
    
    @IBOutlet private weak var nameJpLabel: UILabel!
    @IBOutlet private weak var nameRomaLabel: UILabel!
    @IBOutlet private weak var emailLabel: UILabel!
    
    static func instantiate(_ owner: AnyObject, member: Member) -> MemberListTableCell {
        let cell = R.nib.memberListTableCell.firstView(owner: owner, options: nil)!
        cell.nameJpLabel.text = member.nameJp
        cell.nameRomaLabel.text = member.nameRoma
        cell.emailLabel.text = member.email
        return cell
    }
}
