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
    
    static func instantiate(lesson: Lesson) -> MailSendViewController {
        let viewController = MailSendViewController()
        let dataModel = LessonAttendanceModel.instantiate(lesson: lesson)
        viewController.setToRecipients([DeviceModel.memberEmail])
        viewController.setSubject(lesson.lessonTitle)
        viewController.setMessageBody(dataModel.htmlString, isHTML: true)
        viewController.mailComposeDelegate = viewController
        viewController.addAttachmentData(dataModel.csvData, mimeType: "text/csv", fileName: "\(lesson.lessonTitle).csv")
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
