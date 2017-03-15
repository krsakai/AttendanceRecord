//
//  SideMenuTableCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/25.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal class SideMenuTableCell: UITableViewCell {
    
    private var menuItem: SideMenuViewController.SideMenuItem?
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    static func instantiate(_ owner: AnyObject, menuItem: SideMenuViewController.SideMenuItem) -> SideMenuTableCell {
        let cell = R.nib.sideMemuTableCell.firstView(owner: owner, options: nil)!
        cell.titleLabel.text = menuItem.title
        cell.menuItem = menuItem
        return cell
    }
}
