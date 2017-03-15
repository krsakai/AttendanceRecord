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
    
    /// レッスンRealmを更新
    func updateMemberToRealm(member: Member, block: (Member) -> Void ) -> Void {
        let realm = try! Realm()
        try! realm.write {
            block( member )
        }
    }
    
    /// レッスンマスタを保存
    func saveDefaultlessonList() {
        let plistPath = Bundle.main.path(forResource: "LessonList", ofType: "plist")!
        let lessonListJson = NSArray(contentsOfFile: plistPath) as! [[String : Any]]
        let lessonList: [Lesson] = Mapper<Lesson>().mapArray(JSONArray: lessonListJson)!
        saveLessonListToRealm(lessonList)
    }
}

