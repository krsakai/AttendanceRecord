//
//  InputView.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/11.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import SnapKit
import SwiftCop

internal enum InputType {
    case lessonTitle
    case eventTitle
    case eventDate
    case memberNameKana
    case memberNameJp
    case memberEmail
    
    var titleLabel: String {
        switch self {
        case .lessonTitle: return R.string.localizable.inputViewLabelLessonTitle()
        case .eventTitle: return R.string.localizable.inputViewLabelEventTitle()
        case .eventDate: return R.string.localizable.inputViewLabelEventDate()
        case .memberNameKana: return R.string.localizable.inputViewLabelMemberNameKana()
        case .memberNameJp: return R.string.localizable.inputViewLabelMemberNameJp()
        case .memberEmail: return R.string.localizable.inputViewLabelMemberEmail()
        }
    }
    
    var validations: [EntryTrial] {
        switch self {
        case .memberEmail: return [.space, .lengthMin(1), .lengthMax(100), .email]
        case .memberNameJp: return [.space, .lengthMin(1), .lengthMax(20)]
        case .memberNameKana: return [.space, .lengthMin(1), .lengthMax(20), .hiragana]
        case .lessonTitle, .eventTitle: return [.space, .lengthMin(1), .lengthMax(100)]
        case .eventDate: return [.format(format: "^([0-9]{4}[年][.* ].*[0-9][月].*[0-9][日][.* ].*[0-9][時].*[0-9][分])$", alert: AttendaceRecordFormat.displayedYearToMin.rawValue)]
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
    @IBOutlet fileprivate weak var underLineView: UnderLineView!
    
    let swiftCop = SwiftCop()
    
    private var datePicker: UIDatePicker!
    private var toolBar: UIToolbar!
    
    var inputString: String {
        return textField.text ?? ""
    }
    
    var inputType: InputType!
    
    static func instantiate(owner: UITextFieldDelegate, inputType: InputType, defalut: String? = nil) -> InputView {
        let inputView = R.nib.inputView.firstView(owner: owner, options: nil)!
        inputView.titleLabel.adjustsFontSizeToFitWidth = true
        inputView.titleLabel.text = inputType.titleLabel
        inputView.textField.text = defalut
        inputView.textField.delegate = owner
        inputView.textField.keyboardType = inputType.keyboardType
        inputView.textField.returnKeyType = inputType.returnKeyType
        inputView.inputType = inputType
        
        inputType.validations.forEach { validation in
            inputView.swiftCop.addSuspect(Suspect(view: inputView.textField, sentence: validation.message, trial: validation))
        }
        
        guard inputType.isDate else {
            return inputView
        }
        
        inputView.datePicker = UIDatePicker()
        inputView.datePicker.addTarget(inputView, action: #selector(InputView.changedDate), for: UIControlEvents.valueChanged)
        inputView.datePicker.datePickerMode = UIDatePickerMode.dateAndTime
        inputView.datePicker.minuteInterval = 15
        inputView.datePicker.date = Calendar(identifier: .gregorian).startOfDay(for: Date()).addingTimeInterval(19 * 60 * 60)
        inputView.textField.inputView = inputView.datePicker
        inputView.toolBar = UIToolbar()
        inputView.toolBar.tintColor = UIColor.darkGray
        inputView.toolBar.backgroundColor = UIColor.gray
        
        let toolBarBtn      = UIBarButtonItem(title: R.string.localizable.inpurtViewButtonToolbarDone(),
                                              style: .plain, target: inputView, action: #selector(InputView.tappedDone))
        inputView.toolBar.items = [toolBarBtn]
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
}

extension InputView: LayoutUpdable {
    func refreshLayout() {
        underLineView.backgroundColor = DeviceModel.themeColor.color
    }
}
