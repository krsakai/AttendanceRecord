//
//  LessonTableViewCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/09.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import RealmSwift
import SWTableViewCell

internal final class LessonTableViewCell: SWTableViewCell {
    
    @IBOutlet private weak var lessonTitleLabel: UILabel!
    
    private var lesson: Lesson!
    
    override var entity: Object? {
        return lesson as Object
    }
    
    static func instantiate(_ owner: SWTableViewCellDelegate, lesson: Lesson, listType: ListType) -> LessonTableViewCell {
        let cell = R.nib.lessonTableViewCell.firstView(owner: owner, options: nil)!
        cell.lessonTitleLabel.text = lesson.lessonTitle
        cell.lesson = lesson
        
        if DeviceModel.mode == .member, case .attendance = listType {
            return cell
        }
        
        let utilityButtons = NSMutableArray()
        utilityButtons.sw_addUtilityButton(with: AttendanceRecordColor.Cell.red, title: "削除")
        cell.rightUtilityButtons = utilityButtons as [AnyObject]
        cell.delegate = owner
        return cell
    }
}
