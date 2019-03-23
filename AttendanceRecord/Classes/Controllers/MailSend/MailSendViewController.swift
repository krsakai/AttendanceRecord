//
//  MailSendViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/01.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import MessageUI

internal class MailSendViewController: MFMailComposeViewController, MFMailComposeViewControllerDelegate{
    
    // MARK: - Initializer
    
    static func instantiate(lesson: Lesson, mode: AggregateMode) -> MailSendViewController {
        let viewController = MailSendViewController()
        let dataModel = LessonAttendanceModel.instantiate(lesson: lesson)
        viewController.setToRecipients([DeviceModel.mailAddress])
        viewController.setSubject(lesson.lessonTitle)
        viewController.setMessageBody(mode.htmlString(dataModel), isHTML: true)
        viewController.mailComposeDelegate = viewController
        viewController.addAttachmentData(mode.csvData(dataModel), mimeType: FilePath.MineType.csv, fileName: "\(lesson.lessonTitle)\(FilePath.Extension.csv)")
        return viewController
    }
    
    static func instantiate() -> MailSendViewController {
        let viewController = MailSendViewController()
        viewController.setToRecipients([DeviceModel.mailAddress])
        viewController.setSubject(R.string.localizable.mailSendLabelSubjectSendTemplate())
        viewController.mailComposeDelegate = viewController
        do {
            let encodingString = try String(contentsOfFile:ResourceType.bundle.path(fileName: FilePath.templateMember) ?? "", encoding: String.Encoding.utf8)
            viewController.addAttachmentData(encodingString.shiftJISStringData, mimeType: FilePath.MineType.csv, fileName: FilePath.templateMember + FilePath.Extension.csv)
        } catch { }
        do {
            let encodingString = try String(contentsOfFile:ResourceType.bundle.path(fileName: FilePath.templateEvent) ?? "", encoding: String.Encoding.utf8)
            viewController.addAttachmentData(encodingString.shiftJISStringData, mimeType: FilePath.MineType.csv, fileName: FilePath.templateEvent + FilePath.Extension.csv)
        } catch { }
       
        return viewController
    }
    
    // MARK: - Convinienve Method
    
    static var isEnabledSendMail: Bool {
        if MFMailComposeViewController.canSendMail() == false {
            return false
        }
        return true
    }
    
    // MARK: - MFMailComposeViewControllerDelegate
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        switch result {
        case .cancelled:
            break
        case .saved:
            break
        case .sent:
            break
        case .failed:
            break
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
}
