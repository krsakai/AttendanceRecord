//
//  AddressManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2019/03/04.
//  Copyright © 2019年 酒井邦也. All rights reserved.
//

import Foundation
import Contacts

typealias AuthorizationCompletion = () -> Void

internal enum AuthorizationStatus {
    case granted
    case denied
}

internal final class AddressManager {
    
    /// シングルトンインスタンス
    static let shared = AddressManager()
    
    func contactStoreAuthorization(completion: @escaping AuthorizationCompletion) {
        let status = CNContactStore.authorizationStatus(for: CNEntityType.contacts)
        switch status {
        case CNAuthorizationStatus.denied:
            break
        case CNAuthorizationStatus.notDetermined, CNAuthorizationStatus.restricted:
            CNContactStore.init().requestAccess(for: CNEntityType.contacts) { (granted, Error) in
                if granted {
                    completion()
                }
            }
        case CNAuthorizationStatus.authorized:
            completion()
        }
    }
    
    func selectableAddressList() -> [Member] {
        let store = CNContactStore.init()
        var addressMemberList = [Member]()
        let memberNameList = MemberManager.shared.memberListDataFromRealm().map { $0.nameJp }
        let memberMailList = MemberManager.shared.memberListDataFromRealm().map { $0.email }
        do {
            let keysToFetch = [
                CNContactPhoneticGivenNameKey as CNKeyDescriptor,
                CNContactPhoneticFamilyNameKey as CNKeyDescriptor,
                CNContactGivenNameKey as CNKeyDescriptor,
                CNContactFamilyNameKey as CNKeyDescriptor,
                CNContactEmailAddressesKey as CNKeyDescriptor
            ]
            let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
            try store.enumerateContacts(with: fetchRequest) { (contact, cursor) -> Void in
                if !contact.familyName.isEmpty || !contact.givenName.isEmpty {
                    let name = contact.familyName.isEmpty ?
                        contact.givenName : contact.familyName + (contact.givenName.isEmpty ? "" : " \(contact.givenName)")
                    let nameJa = contact.phoneticFamilyName.isEmpty ?
                        contact.phoneticGivenName : contact.phoneticFamilyName + (contact.phoneticGivenName.isEmpty ? "" : " \(contact.phoneticGivenName)")
                    let email = (contact.emailAddresses.first?.value ?? "") as String
                    addressMemberList.append(Member(nameJp: name, nameKana: nameJa, email: email))
                }
            }
        } catch{
            print("連絡先データの取得に失敗しました")
        }
        return addressMemberList.filter { member in
            !memberNameList.contains(member.nameJp) && !memberMailList.contains(member.email)
        }
    }
}
