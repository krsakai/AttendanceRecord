//
//  FirebaseStorageManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2019/03/04.
//  Copyright © 2019年 酒井邦也. All rights reserved.
//

import Foundation
import FirebaseStorage
import RealmSwift

internal final class FirebaseStorageManager {
    
    static let shared = FirebaseStorageManager()

    func realmFileUpload() {
        let userId = UIDevice.current.identifierForVendor?.uuidString ?? ("temporary-" + DeviceModel.memberId)
        let storage = Storage.storage().reference(withPath: "realm/\(userId).realm")
        let metadata = StorageMetadata()
        metadata.contentType = "application/octet-stream"
        
        let fileURL = Realm.Configuration.defaultConfiguration.fileURL!
        storage.putFile(from: fileURL, metadata: metadata)
    }
    
}
