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

extension String {
    
    private var ns: NSString {
        return (self as NSString)
    }
    
    public func substring(from index: Int) -> String {
        return ns.substring(from: index)
    }
    
    public func substring(to index: Int) -> String {
        return ns.substring(to: index)
    }
    
    public func substring(with range: NSRange) -> String {
        return ns.substring(with: range)
    }
    
    public var lastPathComponent: String {
        return ns.lastPathComponent
    }
    
    public var pathExtension: String {
        return ns.pathExtension
    }
    
    public var deletingLastPathComponent: String {
        return ns.deletingLastPathComponent
    }
    
    public var deletingPathExtension: String {
        return ns.deletingPathExtension
    }
    
    public var pathComponents: [String] {
        return ns.pathComponents
    }
    
    public func appendingPathComponent(_ str: String) -> String {
        return ns.appendingPathComponent(str)
    }
    
    public func appendingPathExtension(_ str: String) -> String? {
        return ns.appendingPathExtension(str)
    }
}

extension String {
    
    var changeKana: String {
        
        let inputText = self as NSString
        
        let outputText = NSMutableString()
        
        var range: CFRange = CFRangeMake(0, inputText.length)
        let locale: CFLocale = CFLocaleCopyCurrent()
        
        let tokenizer: CFStringTokenizer = CFStringTokenizerCreate(kCFAllocatorDefault, inputText as CFString, range, kCFStringTokenizerUnitWordBoundary, locale)
        
        var tokenType: CFStringTokenizerTokenType = CFStringTokenizerGoToTokenAtIndex(tokenizer, 0)
        
        while tokenType.rawValue != 0 {
            dump(tokenType)
            range = CFStringTokenizerGetCurrentTokenRange(tokenizer)
            
            guard tokenType.rawValue != 1 else {
                tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
                continue
            }
            
            let latin: CFTypeRef = CFStringTokenizerCopyCurrentTokenAttribute(tokenizer, kCFStringTokenizerAttributeLatinTranscription)
            
            let romaji = latin as! NSString
            
            let furigana: NSMutableString = romaji.mutableCopy() as! NSMutableString
            CFStringTransform(furigana as CFMutableString, nil, kCFStringTransformLatinKatakana, false)
            
            outputText.append(furigana as String)
            tokenType = CFStringTokenizerAdvanceToNextToken(tokenizer)
        }
        
        return outputText as String
    }
}

extension String {
    
    static var encodingTypes: [String.Encoding] {
        return [String.Encoding.shiftJIS ,String.Encoding.utf8]
    }
    
    static func encodingFile(filePath: String, separator: String = "\n") -> [[String]]? {
        var encodingString: String? = nil
        for index in 0...encodingTypes.count {
            if let _ = encodingString {
                break
            }
            do {
                encodingString = try String(contentsOfFile:filePath, encoding: encodingTypes[index])
            } catch { }
        }
        var colspanList = encodingString?.replacingOccurrences(of: "\r", with: "").components(separatedBy: separator)
        if colspanList?.last?.characters.count == 0 {
            colspanList?.removeLast()
        }
        return colspanList?.map { $0.components(separatedBy: ",") }
    }
}
