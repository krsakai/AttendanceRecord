//
//  FilePath.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/09.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation

internal struct FilePath {
    
    static let appStorePath = "https://itunes.apple.com/"
    static let appPath = "app/app/id1222696326"
    
    static let templateMember = "template_member"
    static let templateEvent = "template_event"
    
    static let sampleFileMember = "メンバーサンプル"
    static let sampleFileEvent = "イベントサンプル"
    
    struct Extension {
        static let csv = ".csv"
        static let json = ".json"
    }
    
    struct MineType {
        static let csv = "text/csv"
    }
    
    struct FileName {
        static let member = "member"
        static let event = "event"
    }
    
    struct FileType {
        static let csv = "csv"
        static let json = "json"
    }
}
