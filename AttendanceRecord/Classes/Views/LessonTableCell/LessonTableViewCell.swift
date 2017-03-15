//
//  LessonTableViewCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/09.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal final class LessonTableViewCell: UITableViewCell {
    
    @IBOutlet private weak var lessonTitleLabel: UILabel!
    
    private var lesson: Lesson!
    
    static func instantiate(_ owner: AnyObject, lesson: Lesson) -> LessonTableViewCell {
        let cell = R.nib.lessonTableViewCell.firstView(owner: owner, options: nil)!
        cell.lessonTitleLabel.text = lesson.lessonTitle
        cell.lesson = lesson
        return cell
    }
}
