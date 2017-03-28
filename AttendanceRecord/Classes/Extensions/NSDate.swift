
//  NSDate.swift
//  AttendanceRecord
//
//  Created by 酒井 邦也 on 2017/02/26.
//  Copyright © 2017年 酒井 邦也. All rights reserved.
//

import Foundation
import SwiftDate

internal let NSDateZero = Date(timeIntervalSince1970: 0)

internal enum AttendaceRecordFormat: String {
    // ラベルなどで主に使われるフォーマット
    // 年から始まる場合、月日時はゼロパディング
    case yearToDay    = "yyyy/MM/dd"
    case yearToMinute = "yyyy/MM/dd HH:mm"
    case yearToSymbol = "yyyy/MM/dd (EEE)"
    // それ以外場合、月日時はゼロサプレス
    case monthToDay   = "M/d"
    case hourToMinute = "H:mm"
    case twoDigitsHourToMinute = "HH:mm"
    
    // APIとの日付の受け渡し用フォーマット
    case noSeparatorYearToDay    = "yyyyMMdd"
    case noSeparatorYearToMinute = "yyyyMMddHHmm"
    case noSeparatorYearToSecond = "yyyyMMddHHmmss"
    case noSeparatorYearToMillisecond = "yyyyMMddHHmmssSSS"
    case noSeparatorHourToMinute = "HHmm"
    case noSeparatorHour         = "HH"
    case noSeparatorMinute       = "mm"
    case yearToSecond            = "yyyy-MM-dd HH:mm:ss"
    /// ISO8601 + タイムゾーンを「+09:00」の形式で表示
    case iSO8601Plus             = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    
    case slashSeparatorYearToSecond = "yyyy/MM/dd HH:mm:ss"
    
    case displayedYearToDay = "yyyy年 M月d日"
    case displayedYearToMin = "yyyy年 M月d日 H時mm分"
    case displayMonthToDay   = "M月d日"
}

// MARK: NSDate／String 変換

internal extension String {
    /// 表示用文字からのNSDate変換
    var dateFromDisplayedFormat: Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = AttendaceRecordFormat.displayedYearToMin.rawValue
        return dateFormatter.date(from: self) ?? NSDateZero
    }
    
    /// 表示用文字からのNSDate変換
    func dateFromDisplayedFormat(format: AttendaceRecordFormat) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.date(from: self) ?? NSDateZero
    }
}

internal extension Date {
    
    /// 形式指定のNSDate変換
    static func dateFromString(string: String, format: AttendaceRecordFormat) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.date(from: string)!
    }
    
    /// 形式指定のString変換
    func stringFromDate(format: AttendaceRecordFormat) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = format.rawValue
        return dateFormatter.string(from: self)
    }
    
    /// 表示用文字へのString変換
    var stringToDisplayedFormat: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ja_JP")
        dateFormatter.dateFormat = AttendaceRecordFormat.displayedYearToMin.rawValue
        return dateFormatter.string(from: self)
    }
    
    var startOfDay: Date {
        return NSCalendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date? {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return NSCalendar.current.date(byAdding: components, to: startOfDay)
    }
}

internal typealias Time = TimeInterval

internal extension String {
    /// "HHmm"形式の文字列をその日からの経過秒数へ変換したもの
    var time: Time? {
        let times = self.components(separatedBy: ":").enumerated().flatMap { index, element -> Int? in
            guard let e = Int(element) else {
                return nil
            }
            return e * Int(pow(Double(60), Double(2 - index)))
        }
        guard times.count > 0 else {
            return nil
        }
        return times.reduce(TimeInterval(0), { $0 + TimeInterval($1) })
    }
}

