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

internal class EventListTableCell: SWTableViewCell, NibRegistrable {
    
    @IBOutlet private weak var eventTitleLabel: UILabel!
    @IBOutlet private weak var eventDateLabel: UILabel!
    
    private var event: Event!
    
    override var entity: Object? {
        return event as Object
    }
    
    func setup(_ owner: SWTableViewCellDelegate, event: Event) {
        eventTitleLabel.text = event.eventTitle
        eventDateLabel.text = event.eventDate.stringToDisplayedFormat
        self.event = event
        
        guard DeviceModel.mode == .organizer else {
            return
        }
        
        let utilityButtons = NSMutableArray()
        utilityButtons.sw_addUtilityButton(with: AttendanceRecordColor.Cell.red, title: "削除")
        rightUtilityButtons = utilityButtons as [AnyObject]
        delegate = owner
    }
}
