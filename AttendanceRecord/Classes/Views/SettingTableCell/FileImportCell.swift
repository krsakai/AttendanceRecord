//
//  FileImportCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/07.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal final class FileImportCell: UITableViewCell {
    
    // MARK: - IBOutlet
    
    @IBOutlet private weak var importButton: UIButton!
    
    // MARK: - Initializer
    
    static func instantiate(owner: AnyObject) -> FileImportCell {
        let cell = R.nib.fileImportCell.firstView(owner: owner, options: nil)!
        cell.importButton.setTitleColor(DeviceModel.themeColor.color, for: .normal)
        cell.importButton.setTitleColor(DeviceModel.themeColor.color, for: .highlighted)
        return cell
    }
    
    @IBAction func tappedButton(_ sender: Any) {
        let viewController = FileManagementViewController.instantiate()
        UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
    }
}
