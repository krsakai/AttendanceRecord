//
//  EventManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/28.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

internal final class EventManager {
    
    /// シングルトンインスタンス
    static let shared = EventManager()
    
    /** イベント一覧情報をRealmに保存
     - parameter eventList: イベント一覧情報  **/
    func saveEventListToRealm(_ eventList: [Event]) {
        let realm = try! Realm()
        try! realm.write {
            for event in eventList {
                realm.add(event, update: true)
            }
        }
    }
    
    /// イベントの削除
    func removeEventToRealm(_ event: Event) {
        let realm = try! Realm()
        try! realm.write {
            if let _ = realm.object(ofType: Event.self, forPrimaryKey: event.eventId) {
                realm.delete(event)
            }
        }
    }
    
    /// イベント一覧情報をRealmから取得
    func eventListDataFromRealm(predicate: NSPredicate? = nil, realm: Realm = try! Realm()) -> [Event] {
        let sortParameters = [SortDescriptor(keyPath: "eventDate", ascending: true)]
        guard let predicate = predicate else {
            return Array(realm.objects(Event.self).sorted(by: sortParameters))
        }
        return Array(realm.objects(Event.self).filter(predicate).sorted(by: sortParameters))
    }
    
    /// イベントRealmを更新
    func updateMemberToRealm(member: Member, block: (Member) -> Void ) -> Void {
        let realm = try! Realm()
        try! realm.write {
            block( member )
        }
    }
    
    /// イベントマスタを保存
    func saveDefaultEventList() {
        let plistPath = Bundle.main.path(forResource: "EventList", ofType: "plist")!
        let eventListJson = NSArray(contentsOfFile: plistPath) as! [[String : Any]]
        let eventList: [Event] = Mapper<Event>().mapArray(JSONArray: eventListJson)!
        saveEventListToRealm(eventList)
    }
    
    /// メンバーが出欠するイベント一覧を取得する
    func eventList(member: Member) -> [Event] {
        let eventList = eventListDataFromRealm(predicate: Event.predicate(lessonId: DeviceModel.lessonId))
        let attendanceList = AttendanceManager.shared.attendanceListDataFromRealm(predicate: Attendance.predicate(lessonId: DeviceModel.lessonId, memberId: member.memberId))
        return eventList.filter { event in
            // FIXME: いい感じで書き直す
            (attendanceList.filter { $0.eventId == event.eventId }.first != nil)
        }
    }
}

