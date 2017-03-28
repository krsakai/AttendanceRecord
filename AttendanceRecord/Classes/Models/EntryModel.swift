//
//  EntryModel.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/27.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import RealmSwift

typealias EntryCompletion = ((Object?) -> Void)

internal struct EntryModel {
    
    let entryCompletion: EntryCompletion?
    
    let entryReject: EntryCompletion?
    
    let entryType: EntryType
    
    let displayModel: DisplayModel?
    
    init(entryType: EntryType = .event, displayModel: DisplayModel? = nil,
         entryCompletion: EntryCompletion? = nil, entryReject: EntryCompletion? = nil) {
        self.entryType = entryType
        self.displayModel = displayModel
        self.entryCompletion = entryCompletion
        self.entryReject = entryReject
    }
}
