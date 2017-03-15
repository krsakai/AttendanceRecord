//
//  InputView.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/11.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import SnapKit

internal enum InputType {
    case lessonTitle
    case eventTitle
    case eventDate
    case memberNameRoma
    case memberNameJp
    case memberEmail
    
    var titleLabel: String {
        switch self {
        case .lessonTitle: return R.string.localizable.inputViewLabelLessonTitle()
        case .eventTitle: return R.string.localizable.inputViewLabelEventTitle()
        case .eventDate: return R.string.localizable.inputViewLabelEventDate()
        case .memberNameRoma: return R.string.localizable.inputViewLabelMemberNameRoma()
        case .memberNameJp: return R.string.localizable.inputViewLabelMemberNameJp()
        case .memberEmail: return R.string.localizable.inputViewLabelMemberEmail()
        }
    }
    
    var isDate: Bool {
        if case .eventDate = self { return true }
        return false
    }
    
    var keyboardType: UIKeyboardType {
        return .emailAddress
    }
    
    var returnKeyType: UIReturnKeyType {
        return .done
    }
}

internal final class InputView: UIView {
    
    @IBOutlet fileprivate(set) weak var textField: UITextField!
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    private var datePicker: UIDatePicker!
    private var toolBar: UIToolbar!
    
    var inputString: String {
        return textField.text ?? ""
    }
    
    var inputType: InputType!
    
    static func instantiate(owner: UITextFieldDelegate, inputType: InputType) -> InputView {
        let inputView = R.nib.inputView.firstView(owner: owner, options: nil)!
        inputView.titleLabel.adjustsFontSizeToFitWidth = true
        inputView.titleLabel.text = inputType.titleLabel
        inputView.textField.delegate = owner
        inputView.textField.keyboardType = inputType.keyboardType
        inputView.textField.returnKeyType = inputType.returnKeyType
        inputView.inputType = inputType
        
        guard inputType.isDate else {
            return inputView
        }
        
        inputView.datePicker = UIDatePicker()
        inputView.datePicker.addTarget(inputView, action: #selector(InputView.changedDate), for: UIControlEvents.valueChanged)
        inputView.datePicker.datePickerMode = UIDatePickerMode.date
        inputView.textField.inputView = inputView.datePicker
        inputView.toolBar = UIToolbar()
        inputView.toolBar.tintColor = UIColor.darkGray
        inputView.toolBar.backgroundColor = UIColor.gray
        
        let toolBarBtn      = UIBarButtonItem(title: R.string.localizable.inpurtViewButtonToolbarDone(),
                                              style: .plain, target: inputView, action: #selector(InputView.tappedDone))
        let toolBarBtnToday = UIBarButtonItem(title: R.string.localizable.inputViewButtonToolbarToday(),
                                              style: .plain, target: inputView, action: #selector(InputView.tappedToday))
        inputView.toolBar.items = [toolBarBtn, toolBarBtnToday]
        inputView.textField.inputAccessoryView = inputView.toolBar
        inputView.toolBar.snp.makeConstraints { make in
            make.height.equalTo(40)
        }
        return inputView
    }
    
    func changedDate(_ datePicker: UIDatePicker) {
        textField.text = self.datePicker.date.stringToDisplayedFormat
        NotificationCenter.default.post(name: .UITextFieldTextDidChange, object: nil)
    }
    
    func tappedDone(_ barButtonItem: UIBarButtonItem) {
        textField.text = self.datePicker.date.stringToDisplayedFormat
        NotificationCenter.default.post(name: .UITextFieldTextDidChange, object: nil)
        textField.resignFirstResponder()
    }
    
    func tappedToday(_ barButtonItem: UIBarButtonItem) {
        datePicker.date = Date()
        textField.text = datePicker.date.stringToDisplayedFormat
    }
}
