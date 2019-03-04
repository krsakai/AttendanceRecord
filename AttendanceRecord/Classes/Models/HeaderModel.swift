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
    
    let selectionAction: HeaderView.SelectionAction
    
    let displayInfo: String
    
    let entryModel: EntryModel?
    
    let editMode: Bool
    
    init(displayInfo: String = "", entryModel: EntryModel? = nil,
         selectionAction: HeaderView.SelectionAction = nil, editMode: Bool = false, action: HeaderView.Action = nil) {
        self.action = action
        self.selectionAction = selectionAction
        self.displayInfo = displayInfo
        self.entryModel = entryModel
        self.editMode = editMode
    }
}
