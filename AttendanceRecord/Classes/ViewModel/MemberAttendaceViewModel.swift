//
//  AttendaceViewModel.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/01.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation

internal struct AttendanceViewModel {
    
    let event: Event
    
    let member: Member
    
    let attendance: Attendance
    
    init(event: Event, member: Member, attendance: Attendance) {
        self.event = event
        self.member = member
        self.attendance = attendance
    }
}
