//
//  GroupManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2019/03/04.
//  Copyright © 2019年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

internal final class GroupManager {
    
    /// シングルトンインスタンス
    static let shared = GroupManager()
    
    // MARK: Group
    
    /** グループ一覧情報をRealmに保存
     - parameter groupList: グループ一覧情報  **/
    func saveGroupListToRealm(_ groupList: [Group]) {
        let realm = try! Realm()
        try! realm.write {
            for group in groupList {
                realm.add(group, update: true)
            }
        }
    }
    
    /// グループの削除
    func removeGroupToRealm(_ group: Group) {
        let realm = try! Realm()
        try! realm.write {
            if let _ = realm.object(ofType: Group.self, forPrimaryKey: group.groupId) {
                GroupManager.shared.groupMemberListDataFromRealm(predicate: GroupMember.predicate(groupId: group.groupId)).forEach { groupMember in
                    // グループが紐づく受講メンバーも削除
                    realm.delete(groupMember)
                }
                
                realm.delete(group)
            }
        }
    }
    
    /// グループ一覧情報をRealmから取得
    func groupListDataFromRealm(predicate: NSPredicate? = nil, realm: Realm = try! Realm()) -> [Group] {
        let sortParameters = [SortDescriptor(keyPath: "updateTime", ascending: true)]
        guard let predicate = predicate else {
            return Array(realm.objects(Group.self).sorted(by: sortParameters))
        }
        return Array(realm.objects(Group.self).filter(predicate).sorted(by: sortParameters))
    }
    
    // MARK: GroupMember (とあるメンバーの受講リスト)
    
    /** グループメンバー情報をRealmに保存
     - parameter groupList: グループ一覧情報  **/
    func saveGroupMemberListToRealm(_ groupMemberList: [GroupMember]) {
        let realm = try! Realm()
        try! realm.write {
            for groupMember in groupMemberList {
                if realm.object(ofType: GroupMember.self, forPrimaryKey: groupMember.primaryKeyForRealm) == nil {
                    realm.add(groupMember, update: true)
                }
            }
        }
    }
    
    /// グループメンバーの削除
    func removeGroupMemberToRealm(_ groupMember: GroupMember) {
        let realm = try! Realm()
        try! realm.write {
            if let _ = realm.object(ofType: GroupMember.self, forPrimaryKey: groupMember.primaryKeyForRealm) {
                realm.delete(groupMember)
            }
        }
    }
    
    /// グループメンバー一覧情報をRealmから取得
    func groupMemberListDataFromRealm(predicate: NSPredicate? = nil, realm: Realm = try! Realm()) -> [GroupMember] {
        guard let predicate = predicate else {
            return Array(realm.objects(GroupMember.self))
        }
        return Array(realm.objects(GroupMember.self).filter(predicate))
    }
}


