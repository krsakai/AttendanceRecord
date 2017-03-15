//
//  MemberAttendaceViewModel.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/01.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation

internal struct MemberAttendanceViewModel {
    
    let event: Event
    
    let attendance: Attendance
    
    init(event: Event, attendance: Attendance) {
        self.event = event
        self.attendance = attendance
    }
}
