//
//  LessonAttendanceModel.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/01.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation

internal final class LessonAttendanceModel {
    
    var lesson: Lesson!
    
    var memberList: [Member] = []
    
    var attendanceList: [[Attendance]] = [[Attendance]]()
    
    var eventList: [Event] = []
    
    static func instantiate(lesson: Lesson) -> LessonAttendanceModel {
        let model = LessonAttendanceModel()
        model.lesson = lesson
        model.eventList = EventManager.shared.eventListDataFromRealm(predicate: Event.predicate(lessonId: lesson.lessonId))
        
        LessonManager.shared.lessonMemberListDataFromRealm(predicate: LessonMember.predicate(lessonId: lesson.lessonId)).forEach { lessonMember in
            var attendances = [Attendance]()
            model.memberList.append(MemberManager.shared.memberListDataFromRealm(predicate: Member.predicate(memberId: lessonMember.memberId)).first!)
            _ = model.eventList.enumerated().map { (index, event) in
                attendances.append(AttendanceManager.shared.attendanceListDataFromRealm(predicate: Attendance.predicate(lessonId: lesson.lessonId, eventId: event.eventId, memberId: lessonMember.memberId)).first!)
            }
            model.attendanceList.append(attendances)
        }
        
        return model
    }
    
    var csvData: Data {
        var rows = [[String]]()
        rows.append([""] + self.eventList.map { $0.eventTitle })
        
        var memberAttendanceRow = [String]()
        _ = memberList.enumerated().map { (index, member) in
            memberAttendanceRow.append(member.nameJp)
            attendanceList[index].forEach { attendance in
                memberAttendanceRow.append(attendance.attendanceStatusRawValue)
            }
        }
        rows.append(memberAttendanceRow)
        
        return rows.map { $0.map { "\"\($0)\"" }.joined(separator: ",")}.joined(separator: "\n").utf8StringData
    }
    
    var htmlString: String {
        
        guard !eventList.isEmpty else { return "1件もイベントが登録されていません" }
        
        // HTML文字列
        var htmlString = ""
        htmlString = htmlString.html().body().table(colspan: eventList.count).tr(row: -1).td().td(.close)
        
        // イベント(横欄)追加
        eventList.forEach { event in
            htmlString = htmlString.td() + event.eventTitle.td(.close)
        }
        
        htmlString = htmlString.td(.close)
        
        _ = memberList.enumerated().map { (index, member) in
    
            htmlString = htmlString.tr(row: index).td() + member.nameJp.td(.close)
            attendanceList[index].forEach { attendance in
                htmlString = htmlString.td() + attendance.attendanceStatusRawValue.td(.close)
            }
            htmlString = htmlString.tr(.close)
        }
        return htmlString.table(.close).body(.close).html(.close)
    }
}

private extension Array where Element: Equatable {
    
    var commaSplitString: String {
        return self.map { "\"\($0)\"" }.joined(separator: ",")
    }
    
    var lineSplitString: String {
        return self.map { "\"\($0)\"" }.joined(separator: "\n")
    }
}

private extension String {
    
    var utf8StringData: Data {
        return self.data(using: String.Encoding.utf8, allowLossyConversion: false)!
    }
}
