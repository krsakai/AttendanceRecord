//
//  EventListTableCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/09.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import RealmSwift
import SWTableViewCell

internal class EventListTableCell: SWTableViewCell {
    
    @IBOutlet private weak var eventTitleLabel: UILabel!
    @IBOutlet private weak var eventDateLabel: UILabel!
    
    private var event: Event!
    
    override var entity: Object? {
        return event as Object
    }
    
    static func instantiate(_ owner: SWTableViewCellDelegate, event: Event) -> EventListTableCell {
        let cell = R.nib.eventListTableCell.firstView(owner: owner, options: nil)!
        cell.eventTitleLabel.text = event.eventTitle
        cell.eventDateLabel.text = event.eventDate.stringToDisplayedFormat
        cell.event = event
        
        let utilityButtons = NSMutableArray()
        utilityButtons.sw_addUtilityButton(with: AttendanceRecordColor.Cell.red, title: "削除")
        cell.rightUtilityButtons = utilityButtons as [AnyObject]
        cell.delegate = owner
        return cell
    }
}
