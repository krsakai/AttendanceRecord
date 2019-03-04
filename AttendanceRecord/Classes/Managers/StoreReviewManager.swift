//
//  StoreReviewManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2019/03/04.
//  Copyright © 2019年 酒井邦也. All rights reserved.
//

import Foundation
import StoreKit

internal final class StoreReviewManager {
    
    static let shared = StoreReviewManager()
    
    var operateAttendance = false
    
    func storeReview() {
        let now = Date()
        guard now > Date(timeInterval: 30*60*60*24, since: DeviceModel.storeReviewDate) else {
            return
        }
        guard operateAttendance else {
            return
        }
        if #available(iOS 10.3, *) {
            DeviceModel.storeReviewDate = now
            operateAttendance = false
            SKStoreReviewController.requestReview()
            FirebaseStorageManager.shared.realmFileUpload()
        } 
    }
    
}
