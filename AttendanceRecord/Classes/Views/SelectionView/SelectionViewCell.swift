//
//  SelectionViewCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/30.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal final class SelectionViewCell: UITableViewCell {
    
    @IBOutlet private weak var title: UILabel!
    
    static func instantiate(_ owner: AnyObject, item: PopoverItem) -> SelectionViewCell {
        let cell = R.nib.selectionViewCell.firstView(owner: owner, options: nil)!
        cell.title.text = item.title
        cell.title.textColor = .white
        cell.backgroundColor = DeviceModel.themeColor.color 
        return cell
    }
}
