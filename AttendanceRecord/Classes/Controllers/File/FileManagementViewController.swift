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
    
    struct ManagementItem {
        var title: String
        var filePath: String = ""
        var action: (() -> Void)
    }
    
    var fileList: [[ManagementItem]] {
        var fileList = [[ManagementItem(title: R.string.localizable.fileSettingSettingTitleHowToUse(), filePath: "") {
                let viewController = R.storyboard.howToUseViewController.howToUseViewController()!
                self.present(viewController, animated: true, completion: nil)
            }, ManagementItem(title: R.string.localizable.fileSettingSettingTitleTemplateSend(), filePath: "") {
                let viewController = MailSendViewController.instantiate()
                self.present(viewController, animated: true, completion: nil)
            }],[ManagementItem]()
        ]
        do {
            let allFileList = try FileManager.default.contentsOfDirectory(atPath: FilesManager.documentPath)
            fileList[1] = ((allFileList.filter { fileName in
                (fileName.pathExtension == FilePath.FileType.csv) ? true : false
            }).map { filePath in
                ManagementItem(title: filePath.deletingPathExtension, filePath: filePath) {
                    let fileDetail = FilesManager.fileType(fileName: filePath.deletingPathExtension)
                    if let errorString = fileDetail.error {
                        AlertController.showAlert(title: R.string.localizable.commonLabelError(), message: errorString, enableCancel: false)
                        return
                    }
                    AlertController.showAlert(title: R.string.localizable.fileSettingErrorTitleReadData(),
                                              message: R.string.localizable.fileSettingErrorMessageReadData(fileDetail.count, fileDetail.fileType.title), enableCancel: true, positiveAction: {
                        let validation = FilesManager.isValid(fileName: filePath.deletingPathExtension, fileDetail: fileDetail)
                        if !validation.isValid {
                            AlertController.showAlert(title: R.string.localizable.commonLabelError(), message: validation.error ?? "", enableCancel: false)
                            return
                        }
                        if fileDetail.fileType == .member {
                            MemberManager.shared.importFileData(filePath: filePath)
                        } else if fileDetail.fileType == .event {
                            LessonManager.shared.importFileData(filePath: filePath)
                        }
                                               
                        AlertController.showAlert(title: "データを登録しました", message: "", enableCancel: false)
                    })
            }})
        } catch {
            return fileList
        }
        
        return fileList
    }
    
    // MARK: - Initializer
    
    static func instantiate() -> FileManagementViewController {
        let viewController = R.storyboard.fileManagementViewController.fileManagementViewController()!
        return viewController
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHeaderView(R.string.localizable.fileSettingHeaderTitleFileRead(), buttonTypes: [[.close(nil)],[]])
    }
    
}

extension FileManagementViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return fileList.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? R.string.localizable.fileSettingSettingTitleHowToUse() : R.string.localizable.fileSettingSettingTitleFileList()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fileList[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = fileList[indexPath.section][indexPath.row].title
        return cell
    }
}

extension FileManagementViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        fileList[indexPath.section][indexPath.row].action()
        tableView.deselectRow(at: indexPath, animated: false)
    }
}
