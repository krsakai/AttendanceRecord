//
//  AttendanceManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/28.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

internal final class AttendanceManager {
    
    /// シングルトンインスタンス
    static let shared = AttendanceManager()
    
    /** 出欠一覧情報をRealmに保存
     - parameter attendanceList: 出欠一覧情報  **/
    func saveAttendanceListToRealm(_ attendanceList: [Attendance]) {
        let realm = try! Realm()
        try! realm.write {
            for attendance in attendanceList {
                realm.add(attendance, update: true)
            }
        }
    }
    
    /// 出欠の削除
    func removeAttendanceToRealm(_ attendance: Attendance) {
        let realm = try! Realm()
        try! realm.write {
            if let _ = realm.object(ofType: Attendance.self, forPrimaryKey: attendance.attendanceId) {
                realm.delete(attendance)
            }
        }
    }
    
    /// 出欠一覧情報をRealmから取得
    func attendanceListDataFromRealm(predicate: NSPredicate, realm: Realm = try! Realm()) -> [Attendance] {
        let array = Array(realm.objects(Attendance.self).filter(predicate))
        return array.sorted { $0.memberName < $1.memberName }
    }
    
    /// 出欠Realmを更新
    func updateAttendanceToRealm(attendance: Attendance, block: (Attendance) -> Void ) -> Void {
        let realm = try! Realm()
        try! realm.write {
            block( attendance )
        }
    }
    
    /// イベント毎出欠一覧ビューモデルを取得
    func eventAttendanceViewModels(event: Event?, filterHidden: Bool = true) -> [AttendanceViewModel] {
        guard let event = event else {
            return [AttendanceViewModel]()
        }
        let attendanceList = attendanceListDataFromRealm(predicate: Attendance.predicate(lessonId: event.lessonId, eventId: event.eventId, filterHidden: filterHidden))
        var viewModels = [AttendanceViewModel]()
        attendanceList.forEach { attendance in
            let event = EventManager.shared.eventListDataFromRealm(predicate: Event.predicate(eventId: attendance.eventId)).first ?? Event()
            let member = MemberManager.shared.memberListDataFromRealm(predicate: Member.predicate(memberId: attendance.memberId)).first ?? Member()
            viewModels.append(AttendanceViewModel(event: event, member: member, attendance: attendance))
        }
        return viewModels
    }
}
