//
//  FirebaseAnalyticsManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2019/03/04.
//  Copyright © 2019年 酒井邦也. All rights reserved.
//

import Foundation
import FirebaseAnalytics

internal final class FirebaseAnalyticsManager {
    
    static let shared = FirebaseAnalyticsManager()
    
    func recordLesson(lessonName: String) {
        Analytics.logEvent("regist-lesson", parameters: [
            "name": lessonName as NSObject
        ])
    }
    
    func recordEvent(eventName: String) {
        Analytics.logEvent("regist-event", parameters: [
            "name": eventName as NSObject
        ])
    }
    
    func setUserProperty(userId: String) {
        Analytics.setUserID(userId)
    }
}

