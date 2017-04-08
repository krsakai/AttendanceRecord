//
//  LessonManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/09.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

internal final class LessonManager {
    
    /// シングルトンインスタンス
    static let shared = LessonManager()
    
    // MARK: Lesson
    
    /** レッスン一覧情報をRealmに保存
     - parameter lessonList: レッスン一覧情報  **/
    func saveLessonListToRealm(_ lessonList: [Lesson]) {
        let realm = try! Realm()
        try! realm.write {
            for lesson in lessonList {
                realm.add(lesson, update: true)
            }
        }
    }
    
    /// レッスンの削除
    func removeLessonToRealm(_ lesson: Lesson) {
        let realm = try! Realm()
        try! realm.write {
            if let _ = realm.object(ofType: Lesson.self, forPrimaryKey: lesson.lessonId) {
                LessonManager.shared.lessonMemberListDataFromRealm(predicate: LessonMember.predicate(lessonId: lesson.lessonId)).forEach { lessonMember in
                    // レッスンが紐づく受講メンバーも削除
                    realm.delete(lessonMember)
                }
                
                // レッスンにひもづく出欠/イベントもまとめて削除する
                EventManager.shared.eventListDataFromRealm(predicate: Event.predicate(lessonId: lesson.lessonId)).forEach { event in
                    AttendanceManager.shared.attendanceListDataFromRealm(predicate: Attendance.predicate(lessonId: lesson.lessonId, eventId: event.eventId)).forEach { attendance in
                        // レッスンが紐づく出欠を削除
                        realm.delete(attendance)
                    }
                    // レッスンが紐づくイベントを削除
                    realm.delete(event)
                }
                
                realm.delete(lesson)
            }
        }
    }
    
    /// レッスン一覧情報をRealmから取得
    func lessonListDataFromRealm(predicate: NSPredicate? = nil, realm: Realm = try! Realm()) -> [Lesson] {
        let sortParameters = [SortDescriptor(keyPath: "updateTime", ascending: true)]
        guard let predicate = predicate else {
            return Array(realm.objects(Lesson.self).sorted(by: sortParameters))
        }
        return Array(realm.objects(Lesson.self).filter(predicate).sorted(by: sortParameters))
    }
    
    /// レッスンマスタを保存
    func saveDefaultlessonList() {
        let plistPath = Bundle.main.path(forResource: "LessonList", ofType: "plist")!
        let lessonListJson = NSArray(contentsOfFile: plistPath) as! [[String : Any]]
        let lessonList: [Lesson] = Mapper<Lesson>().mapArray(JSONArray: lessonListJson)!
        saveLessonListToRealm(lessonList)
    }
    
    // MARK: LessonMember (とあるメンバーの受講リスト)
    
    /** レッスンメンバー情報をRealmに保存
     - parameter lessonList: レッスン一覧情報  **/
    func saveLessonMemberListToRealm(_ lessonMemberList: [LessonMember]) {
        let realm = try! Realm()
        try! realm.write {
            for lessonMember in lessonMemberList {
                if realm.object(ofType: LessonMember.self, forPrimaryKey: lessonMember.primaryKeyForRealm) == nil {
                    let eventList = EventManager.shared.eventListDataFromRealm(predicate: Event.predicate(lessonId: lessonMember.lessonId))
                    eventList.forEach { event in
                        let attendance = Attendance(lessonId: lessonMember.lessonId, eventId: event.eventId, memberId: lessonMember.memberId, attendanceStatus: .noEntry)
                        // レッスンに紐づくイベントの出欠も登録
                        realm.add(attendance, update: true)
                    }
                    realm.add(lessonMember, update: true)
                }
            }
        }
    }

    /// レッスンメンバーの削除
    func removeLessonMemberToRealm(_ lessonMember: LessonMember) {
        let realm = try! Realm()
        try! realm.write {
            if let _ = realm.object(ofType: LessonMember.self, forPrimaryKey: lessonMember.primaryKeyForRealm) {
                realm.delete(lessonMember)
            }
        }
    }
    
    /// レッスンメンバー一覧情報をRealmから取得
    func lessonMemberListDataFromRealm(predicate: NSPredicate? = nil, realm: Realm = try! Realm()) -> [LessonMember] {
        guard let predicate = predicate else {
            return Array(realm.objects(LessonMember.self))
        }
        return Array(realm.objects(LessonMember.self).filter(predicate))
    }
    
    /// ファイルからレッスンとイベントを保存する
    func importFileData(filePath: String) {
        guard let dataList = FilesManager.list(fileName: filePath.deletingPathExtension, resourceType: .documents) else {
            return
        }
        let lesson = Lesson(lessonTitle: dataList[0][1])
        var eventList = [Event]()
        for index in 2...dataList.indexCount {
            eventList.append(Event(lessonId: lesson.lessonId, eventDate: dataList[index][2].dateFromFileFormat, eventTitle: dataList[index][1]))
        }
        saveLessonListToRealm([lesson])
        EventManager.shared.saveEventListToRealm(eventList)
    }
}

