//
//  FileManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/08.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation

enum FileType: String {
    case member = "Member"
    case event  = "Lesson"
    case none   = "Nome"
    
    var title: String {
        return ""
    }
}

enum ResourceType {
    case bundle
    case documents
    
    func path(fileName: String, fileType: String = "csv") -> String? {
        switch self {
        case .bundle: return Bundle.main.path(forResource: fileName, ofType: fileType)
        case .documents: return FilesManager.documentPath + "/\(fileName).\(fileType)"
        }
    }
}


struct FileDetail {
    var fileType: FileType
    var count: String
    var error: String?
}

internal final class FilesManager {
    
    static var documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    static func list(fileName: String, fileType: String = "csv", resourceType: ResourceType = .bundle) -> [[String]]? {
        
        guard let filePath = resourceType.path(fileName: fileName, fileType: fileType) else {
            return nil
        }
        
        return String.encodingFile(filePath: filePath)
    }
    
    static func save(fileName: String, dataList: [[String]]) {
        
        do {
            guard !FileManager.default.fileExists(atPath: FilesManager.documentPath + "/" + fileName) else {
                NSLog("ファイルが既に存在します")
                return
            }
            try dataList.map { $0.map { $0 }.joined(separator: ",")}.joined(separator: "\n").write(toFile: FilesManager.documentPath + "/" + fileName + ".csv", atomically: false, encoding: String.Encoding.shiftJIS )
        } catch {
            NSLog("ファイルの保存に失敗")
        }
    }
    
    static func fileType(fileName: String) -> FileDetail {
        guard let dataList = FilesManager.list(fileName: fileName, resourceType: .documents) else {
            return FileDetail(fileType: .none, count: String(0), error: "ファイルにデータが存在しません")
        }
        if dataList.count > 0 && dataList[0].count > 0 {
            switch dataList[0][0] {
            case FileType.member.rawValue:
                return FileDetail(fileType: .member, count: String(dataList.count - 1), error: nil)
            case FileType.event.rawValue:
                return FileDetail(fileType: .event, count: String(dataList.count - 2), error: nil)
            default:
                return FileDetail(fileType: .none, count: String(0),
                                  error: "データ識別子が有効ではありません。「Member」または「Lesson」を指定してください。")
            }
        } else {
            return FileDetail(fileType: .none, count: String(0), error: "ファイルにデータが存在しません")
        }
    }
    
    static func isValid(fileName: String, fileDetail: FileDetail) -> (isValid: Bool, error: String?) {
        guard let dataList = FilesManager.list(fileName: fileName, resourceType: .documents) else {
            return (false, "ファイルにデータが存在しません")
        }
        
        if fileDetail.fileType == .member {
            if dataList.count < 2 {
                return (false, "メンバーデータが存在しません")
            }
            for index in 1...dataList.indexCount {
                if dataList[index].count < 2 {
                    return (false, "データが存在しない行があります")
                }
            }
            return (true, nil)
        } else if fileDetail.fileType == .event {
            if dataList[0].count < 2 {
                return (false, "講義タイトルが存在しません")
            }
            
            if dataList.count < 3 {
                return (false, "イベントデータが存在しません")
            }
            for index in 2...dataList.indexCount {
                if dataList[index].count < 3 {
                    return (false, "データが存在しない行があります。(\(index)行目)")
                }
            }
            for index in 2...dataList.indexCount {
                if dataList[index][2].dateFromFileFormat == NSDateZero {
                    return (false, "開催日時のフォーマットが違います。(\(index)行目)。yyyy/MM/dd/HH:mm")
                }
            }
            return (true, nil)
        } else {
            return (false, "データ識別子が有効ではありません。「Member」または「Lesson」を指定してください。")
        }
    }
}
