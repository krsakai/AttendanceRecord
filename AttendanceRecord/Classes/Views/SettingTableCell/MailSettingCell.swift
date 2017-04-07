//
//  MailSettingCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/06.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import SwiftCop
import EasyTipView

internal class MailSettingCell: UITableViewCell {

    // MARK: - IBOutlet
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    
    // MARK: - Property
    
    private let swiftCop = SwiftCop()
    private var parentView: UITableView?
    private var toolTipView: EasyTipView?
    
    fileprivate static let toolTipPreferences: EasyTipView.Preferences = {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.arrowPosition = .bottom
        preferences.drawing.backgroundColor = .black
        return preferences
    }()
    
    // MARK: Initializer
    
    static func instantiate(owner: AnyObject) -> MailSettingCell {
        let cell = R.nib.mailSettingCell.firstView(owner: owner, options: nil)!
        cell.parentView = owner as? UITableView
        cell.mailAddressTextField.delegate = cell
        cell.mailAddressTextField.text = DeviceModel.mailAddress
        [.space, .lengthMin(1), .lengthMax(100), EntryTrial.email].forEach { validation in
            cell.swiftCop.addSuspect(Suspect(view: cell.mailAddressTextField, sentence: validation.message, trial: validation))
        }
        NotificationCenter.default.addObserver(cell, selector: #selector(textFieldDidChange),
                                               name: .UITextFieldTextDidChange, object: nil)
        return cell
    }
    
    deinit{
        NotificationCenter.default.removeObserver(self, name: .UITextFieldTextDidChange, object: nil)
    }
    
    func textFieldDidChange(notification: NSNotification) {
        validate()
    }
    
    private func validate() {
        DeviceModel.mailAddress = mailAddressTextField.text ?? ""
        guard let textField = mailAddressTextField, let text = mailAddressTextField.text else {
            disableValidateAlert(self)
            return
        }
        
        guard !text.isEmpty else {
            disableValidateAlert(self)
            return
        }
        
        if let message = swiftCop.isGuilty(textField)?.verdict() {
            disableValidateAlert(self)
            displayValidateAlert(mailAddressTextField, message: message)
        } else {
            disableValidateAlert(self)
        }
    }
    
    private func displayValidateAlert(_ sourceView: UIView, message: String) {
        toolTipView = EasyTipView(text: message, preferences: type(of: self).toolTipPreferences)
        toolTipView?.show(forView: sourceView, withinSuperview: parentView)
    }
    
    private func disableValidateAlert(_ sourceView: UIView) {
        toolTipView?.dismiss()
    }
}

extension MailSettingCell: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        mailAddressTextField.resignFirstResponder()
        return true
    }
}
