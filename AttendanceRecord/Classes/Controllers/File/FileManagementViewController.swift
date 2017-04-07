//
//  FileManagementViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/07.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal final class FileManagementViewController: UIViewController, HeaderViewDisplayable {
    
    // MARK: - IBOutlet
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    // MARK: - Property
    let documentPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    var fileList: [String] {
        do {
            let allFileList = try FileManager.default.contentsOfDirectory(atPath: documentPath)
            return (allFileList.filter { fileName in
                (fileName.pathExtension == "csv" || fileName.pathExtension == "json") ? true : false
            }).map { $0.deletingPathExtension }
        } catch {
            return []
        }
    }
    
//    var test: AnyObject? {
//        return fileList.flatMap { fileName in
//            do {
//                var texts: [String] = try String(contentsOfFile: documentPath + "/" + fileName, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue)).lines
//                texts = texts.deleteSpaceOnly(texts: texts)
//                return texts
//            } catch {
//                return nil
//            }
//        }
//    }
    
    // MARK: - Initializer
    
    static func instantiate() -> FileManagementViewController {
        let viewController = R.storyboard.fileManagementViewController.fileManagementViewController()!
        return viewController
    }
    
    // MARK: - View Life Cycle
    
    
}

extension FileManagementViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = fileList[indexPath.row]
        return cell
    }
}

extension FileManagementViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
}
