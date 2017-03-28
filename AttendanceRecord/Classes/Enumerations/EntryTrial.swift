//
//  EntryTrial.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/27.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import SwiftCop

// SwiftCop[https://github.com/andresinaka/SwiftCop]用のバリデーションクラス
public enum EntryTrial: TrialProtocol {
    case required
    case hiragana
    case space
    case email
    case format(format: String, alert: String)
    case lengthMin(Int)
    case lengthMax(Int)
    
    var message: String {
        switch self {
        case .hiragana: return "ひらがなで入力してください"
        case .space: return "先頭・末尾には空白は利用できません"
        case .email: return "ユーザー名@ドメイン名.識別子の形で入力してください"
        case .format(let format): return "\(format.alert)の形で入力してください"
        case .lengthMin(let min): return "\(min)文字以上の文字数で入力してください"
        case .lengthMax(let max): return "\(max)文字以下の文字数で入力してください"
        case .required: return ""
        }
    }
    
    public func trial() -> ((_ evidence: String) -> Bool){
        switch self {
        case .hiragana:
            return { (evidence: String) -> Bool in
                // 全角ひらがな(スペース以外)かどうか
                let hiraganaRegEx = "^[ぁ-ゞ| |　]+$"
                let hiraganaTest = NSPredicate(format:"SELF MATCHES %@", hiraganaRegEx)
                return hiraganaTest.evaluate(with: evidence)
            }
        case .space:
            return { (evidence: String) -> Bool in
                // 行頭/行末がスペース以外かどうか
                let spaceRegEx = "^(?! |　)(?!.* $).*$"
                let spaceTest = NSPredicate(format:"SELF MATCHES %@", spaceRegEx)
                return spaceTest.evaluate(with: evidence)
            }
        case .email: return Trial.email.trial()
        case .lengthMin(let min): return Trial.length(.minimum, min).trial()
        case .lengthMax(let max): return Trial.length(.maximum, max).trial()
        case .format(let format): return Trial.format(format.format).trial()
        default:
            return { (evidence: String) -> Bool in
                return false
            }
        }
    }
}
