//
//  MemberManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/26.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

internal final class MemberManager {
    
    /// シングルトンインスタンス
    static let shared = MemberManager()
    
    /** メンバー一覧情報をRealmに保存
     - parameter memberList: メンバー一覧情報  **/
    func saveMemberListToRealm(_ memberList: [Member]) {
        let realm = try! Realm()
        try! realm.write {
            for member in memberList {
                if let _ = realm.object(ofType: Member.self, forPrimaryKey: member.primaryKeyForRealm) {
                    realm.add(member, update: true)
                } else {
                    realm.add(member, update: true)
                    
                    // FIXME: 他講義を考慮する
                    let eventList = EventManager.shared.eventListDataFromRealm()
                    eventList.forEach { event in
                        realm.add(Attendance(eventId: event.eventId, memberId: member.memberId, attendanceStatus: .noEntry))
                    }
                }
            }
        }
    }
    
    /// メンバーの削除
    func removeMemberToRealm(_ member: Member) {
        let realm = try! Realm()
        try! realm.write {
            if let _ = realm.object(ofType: Member.self, forPrimaryKey: member.primaryKeyForRealm) {
                realm.delete(member)
            }
        }
    }
    
    /// メンバー一覧情報をRealmから取得
    func memberListDataFromRealm(predicate: NSPredicate? = nil, realm: Realm = try! Realm()) -> [Member] {
        let sortParameters = [SortDescriptor(keyPath: "nameRoma", ascending: false)]
        guard let predicate = predicate else {
            return Array(realm.objects(Member.self).sorted(by: sortParameters))
        }
        return Array(realm.objects(Member.self).filter(predicate).sorted(by: sortParameters))
    }
    
    /// メンバーRealmを更新
    func updateMemberToRealm(member: Member, block: (Member) -> Void ) -> Void {
        let realm = try! Realm()
        try! realm.write {
            block( member )
        }
    }
    
    /// メンバーマスタを保存
    func saveDefaultMemberList() {
        let plistPath = Bundle.main.path(forResource: "MemberList", ofType: "plist")!
        let memberListJson = NSArray(contentsOfFile: plistPath) as! [[String : Any]]
        let memberList: [Member] = Mapper<Member>().mapArray(JSONArray: memberListJson)!
        saveMemberListToRealm(memberList)
    }
}
