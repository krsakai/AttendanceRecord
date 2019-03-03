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

internal final class LessonTableViewCell: SWTableViewCell, NibRegistrable {
    
    @IBOutlet private weak var lessonTitleLabel: UILabel!
    
    private var lesson: Lesson!
    
    override var entity: Object? {
        return lesson as Object
    }
    
    func setup(_ owner: SWTableViewCellDelegate, lesson: Lesson, listType: ListType) {
        lessonTitleLabel.text = lesson.lessonTitle
        self.lesson = lesson
        
        if DeviceModel.mode == .member, case .attendance = listType {
            return
        }
        
        let utilityButtons = NSMutableArray()
        utilityButtons.sw_addUtilityButton(with: AttendanceRecordColor.Cell.red, title: "削除")
        rightUtilityButtons = utilityButtons as [AnyObject]
        delegate = owner
    }
}
