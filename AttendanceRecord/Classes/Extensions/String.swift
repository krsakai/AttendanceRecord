//
//  String.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/01.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation

enum TagType: String {
    case open  = ""
    case close = "/"
}

extension String {
    
    func html(_ type: TagType = .open) -> String {
        return self + "<\(type.rawValue)html>"
    }
    
    func body(_ type: TagType = .open) -> String {
        return self + "<\(type.rawValue)body>"
    }
    
    func table(_ type: TagType = .open, colspan: Int = 0) -> String {
        if type == .close {
            return self + "</table>"
        }
        return self + "<table border=1 cellspacing=0 cellpadding=0 style=table-layout:fixed; width=\(colspan * 75)px>"
    }
    
    func tr(_ type: TagType = .open, row: Int = 0) -> String {
        if type == .close {
            return self + "</tr>"
        }
        
        var color = "#000"
        switch row % 2 {
        case 0: color = "whitesmoke"
        case 1: color = "#b0c4de"
        default: color = "#bcc8db"
        }
        
        return self + "<tr bgcolor=\(color)>"
    }
    
    func td(_ type: TagType = .open) -> String {
        if type == .close {
            return self + "</td>"
        }
        
        return self + "<td align=center valign=center>"
    }
    
}
