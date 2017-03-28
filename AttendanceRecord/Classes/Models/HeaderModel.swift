//
//  HeaderActionModel.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/25.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation

internal struct HeaderModel {
    
    let action: HeaderView.Action
    
    let displayInfo: String
    
    let entryModel: EntryModel?
    
    init(displayInfo: String = "", entryModel: EntryModel? = nil, action: HeaderView.Action = nil) {
        self.action = action
        self.displayInfo = displayInfo
        self.entryModel = entryModel
    }
}
