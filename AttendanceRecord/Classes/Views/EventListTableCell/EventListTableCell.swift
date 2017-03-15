//
//  EventListTableCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/09.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal class EventListTableCell: UITableViewCell {
    
    @IBOutlet private weak var eventTitleLabel: UILabel!
    @IBOutlet private weak var eventDateLabel: UILabel!
    
    private var event: Event!
    
    static func instantiate(_ owner: AnyObject, event: Event) -> EventListTableCell {
        let cell = R.nib.eventListTableCell.firstView(owner: owner, options: nil)!
        cell.eventTitleLabel.text = event.eventTitle
        cell.eventDateLabel.text = event.eventDate.stringToDisplayedFormat
        cell.event = event
        return cell
    }
}
