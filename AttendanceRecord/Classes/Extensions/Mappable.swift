//
//  Mappable.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/28.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation

import ObjectMapper
import SwiftDate

extension Mappable {
    
    /**
     *  「TransformOf」を使用した型変換
     *  fromJSON : String型 → NSDate型へ変換
     *  toJSON   : NSDate型 → String型へ変換
     */
    func stringToDateTransform(format: AttendaceRecordFormat = .iSO8601Plus) -> TransformOf<Date, String>{
        
        return TransformOf<Date, String>(
            fromJSON: { dateString in
                if let value: String = dateString {
                    return Date.dateFromString(string: value, format: format)
                }
                return nil
        },
            toJSON: { date in
                if let date: Date = date {
                    return date.stringFromDate(format: format)
                }
                return nil
        }
        )
    }
    
    /**
     *  「TransformOf」を使用した型変換
     *  fromJSON : String型 → Int型へ変換
     *  toJSON   : Int型 → String型へ変換
     */
    func stringToIntTransform() -> TransformOf<Int, String> {
        return TransformOf<Int, String>(
            fromJSON: { value in
                if let value = value {
                    return Int(value)
                }
                return nil
        },
            toJSON: { number in
                if let number = number {
                    return String(number)
                }
                return nil
        }
        )
    }
    
    /**
     *  「TransformOf」を使用した型変換
     *  fromJSON : String型 → Bool型へ変換
     *  toJSON   : Bool型 → String型へ変換
     */
    func stringToBoolTransform() -> TransformOf<Bool, String> {
        return TransformOf<Bool, String>(
            fromJSON: { value in
                guard let value = value else {
                    return nil
                }
                
                var result: Bool?
                switch value {
                case "0": result = false
                case "1": result = true
                default: break
                }
                return result
        },
            toJSON: { flag in
                guard let flag = flag else {
                    return nil
                }
                return flag ? "1" : "0"
        })
    }
}
