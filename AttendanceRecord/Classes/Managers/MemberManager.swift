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
                realm.add(member, update: true)
                
                let attendanceList = AttendanceManager.shared.attendanceListDataFromRealm(
                    predicate: Attendance.predicate(memberId: member.memberId)
                ).map { record -> Attendance in
                    let attendance = record.clone
                    attendance.memberNameKana = member.nameJpKana
                    return attendance
                }
                
                let lessonMemberList = LessonManager.shared.lessonMemberListDataFromRealm(
                    predicate: LessonMember.predicate(memberId: member.memberId)
                ).map { record -> LessonMember in
                    let lessonMember = record.clone
                    lessonMember.memberNameKana = member.nameJpKana
                    return lessonMember
                }
                
                realm.add(attendanceList, update: true)
                realm.add(lessonMemberList, update: true)
            }
        }
    }
    
    /// メンバーの削除
    func removeMemberToRealm(_ member: Member) {
        let realm = try! Realm()
        try! realm.write {
            if let _ = realm.object(ofType: Member.self, forPrimaryKey: member.memberId) {
                LessonManager.shared.lessonMemberListDataFromRealm(predicate: LessonMember.predicate(memberId: member.memberId)).forEach { lessonMember in
                    // メンバーに紐づく受講メンバーも削除
                    realm.delete(lessonMember)
                }
                
                AttendanceManager.shared.attendanceListDataFromRealm(predicate: Attendance.predicate(memberId: member.memberId)).forEach { attendance in
                    // メンバーに紐づく出欠も削除
                    realm.delete(attendance)
                }
                realm.delete(member)
            }
        }
    }
    
    /// メンバー一覧情報をRealmから取得
    func memberListDataFromRealm(predicate: NSPredicate? = nil, realm: Realm = try! Realm()) -> [Member] {
        let sortParameters = [
            DeviceModel.isFullNameSort ? SortDescriptor(keyPath: "nameJpKana", ascending: true) : nil,
            SortDescriptor(keyPath: "nameKana", ascending: true)
        ].flatMap { $0 }
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
        let memberList: [Member] = Mapper<Member>().mapArray(JSONArray: memberListJson)
        saveMemberListToRealm(memberList)
    }
    
    /// ファイルからレッスンとイベントを保存する
    func importFileData(filePath: String) {
        guard let dataList = FilesManager.list(fileName: filePath.deletingPathExtension, resourceType: .documents) else {
            return
        }
        var memberList = [Member]()
        for index in 1...dataList.indexCount {
            let member = Member()
            member.nameJp = dataList[index].count > 1 ? dataList[index][1] : ""
            member.nameKana = dataList[index].count > 2 ? dataList[index][2] : ""
            member.email = dataList[index].count > 3 ? dataList[index][3] : ""
            memberList.append(member)
        }
        saveMemberListToRealm(memberList)
    }
}
