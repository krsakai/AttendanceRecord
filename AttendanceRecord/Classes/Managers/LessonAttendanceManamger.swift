////
////  LessonAttendanceManager.swift
////  AttendanceRecord
////
////  Created by 酒井邦也 on 2017/04/01.
////  Copyright © 2017年 酒井邦也. All rights reserved.
////
//
//import Foundation
//
//internal final class LessonAttendanceManager {
//    
//    /// シングルトンインスタンス
//    static let shared = LessonAttendanceManager()
//    
//    func csvData() {
//        
//    }
//    
//    func test() {
//        
//    }
//    
//    /// 個人出欠一覧ビューのモデルを取得
//    func lessonAttendanceList(member: Member?, lesson: Lesson?) -> [[LessonAttendanceModel]] {
//        guard let member = member, let lesson = lesson else {
//            return [[LessonAttendanceModel]()]
//        }
//        let attendanceList = attendanceListDataFromRealm(predicate: Attendance.predicate(lessonId: lesson.lessonId, memberId: member.memberId))
//        var viewModels = [AttendanceViewModel]()
//        attendanceList.forEach { attendance in
//            let event = EventManager.shared.eventListDataFromRealm(predicate: Event.predicate(eventId: attendance.eventId)).first ?? Event()
//            viewModels.append(AttendanceViewModel(event: event, member: member, attendance: attendance))
//        }
//        return viewModels.sorted { viewModelX, viewModelY in
//            return viewModelX.event.eventDate < viewModelY.event.eventDate
//        }
//    }
//}
