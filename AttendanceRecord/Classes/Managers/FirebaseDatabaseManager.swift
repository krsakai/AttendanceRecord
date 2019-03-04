//
//  FirebaseDatabaseManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2019/03/04.
//  Copyright © 2019年 酒井邦也. All rights reserved.
//

import Foundation
import FirebaseDatabase

internal final class FirebaseDatabaseManager {
    
    static let shared = FirebaseDatabaseManager()
    
    var ref = Database.database().reference()
    
    func update() {
        
    }
}
