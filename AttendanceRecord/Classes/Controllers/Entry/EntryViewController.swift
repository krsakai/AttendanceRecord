//
//  MemberEntryViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/03.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import RealmSwift
import EasyTipView

internal enum EntryType: HeaderButtonModel {
    case group
    case lesson
    case event
    case lessonMember
    case groupMember
    
    var inputTypes: [InputType] {
        switch self {
        case .group: return [.groupTitle]
        case .lesson: return [.lessonTitle]
        case .event:  return [.eventTitle, .eventDate]
        case .lessonMember, .groupMember: return [.memberNameKana, .memberNameJp, .memberEmail]
        }
    }
    
    var headerTitle: String {
        switch self {
        case .group: return "グループ登録"
        case .lesson: return R.string.localizable.entryHeaderLabelLesson()
        case .event:  return R.string.localizable.entryHeaderLabelEvent()
        case .lessonMember, .groupMember: return R.string.localizable.entryHeaderLabelMember()
        }
    }
    
    func headerButtonItems(actions: [String: HeaderView.Action]? = nil) -> [[HeaderView.ButtonType]] {
        switch self {
        case .group:
            let entryCompletion = actions?[ActionKyes.groupEntryCompletion] ?? {}
            let entryReject = actions?[ActionKyes.groupEntryReject] ?? {}
            return [[.close(HeaderModel(action: entryReject))],[.regist(HeaderModel(action: entryCompletion))]]
        case .lesson:
            let entryCompletion = actions?[ActionKyes.lessonEntryCompletion] ?? {}
            let entryReject = actions?[ActionKyes.lessonEntryReject] ?? {}
            return [[.close(HeaderModel(action: entryReject))],[.regist(HeaderModel(action: entryCompletion))]]
        case .event:
            let entryCompletion = actions?[ActionKyes.eventEntryCompletion] ?? {}
            let entryReject = actions?[ActionKyes.eventEntryReject] ?? {}
            return [[.close(HeaderModel(action: entryReject))],[.regist(HeaderModel(action: entryCompletion))]]
        case .lessonMember, .groupMember:
            let entryCompletion = actions?[ActionKyes.memberEntryCompletion] ?? {}
            let entryReject = actions?[ActionKyes.memberEntryReject] ?? {}
            return [[.close(HeaderModel(action: entryReject))],[.regist(HeaderModel(action: entryCompletion))]]
        }
    }
}

internal final class EntryViewController: UIViewController, HeaderViewDisplayable {
    
    @IBOutlet weak var headerView: HeaderView!
    
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    fileprivate var targetTextField: UITextField?
    
    fileprivate var sourceViewModel: DisplayModel?
    
    fileprivate var editMember: Member?
    
    fileprivate lazy var inputViews: [InputView] = {
        switch self.entryType {
        case .group:
            return [InputView.instantiate(owner: self, inputType: .groupTitle)]
        case .lesson:
            return [InputView.instantiate(owner: self, inputType: .lessonTitle)]
        case .event:
            return [InputView.instantiate(owner: self, inputType: .eventTitle),
                    InputView.instantiate(owner: self, inputType: .eventDate)]
        case .lessonMember, .groupMember:
            var inputViews = [InputView]()
            if DeviceModel.isRequireMemberName {
                inputViews.append(InputView.instantiate(owner: self, inputType: .memberNameKana, defalut: self.editMember?.nameKana))
            }
            inputViews.append(InputView.instantiate(owner: self, inputType: .memberNameJp, defalut: self.editMember?.nameJp))
            if DeviceModel.isRequireEmail {
                inputViews.append(InputView.instantiate(owner: self, inputType: .memberEmail, defalut: self.editMember?.email))
            }
            return inputViews
        }
    }()
    
    fileprivate var toolTipViewList = [(tipView: EasyTipView, sourceView: UIView)]()
    
    fileprivate static let toolTipPreferences: EasyTipView.Preferences = {
        var preferences = EasyTipView.Preferences()
        preferences.drawing.arrowPosition = .bottom
        preferences.drawing.backgroundColor = .black
        return preferences
    }()
    
    fileprivate var entryType: EntryType = .lesson
    
    var entryCompletion: EntryCompletion?
    var entryReject: EntryCompletion?
    
    private var actions: [String: HeaderView.Action] {
        switch entryType {
        case .group:
            return [ActionKyes.groupEntryCompletion: {
                let title = self.inputViews.filter { $0.inputType == .groupTitle }.first!
                let group = Group(groupTitle: title.inputString)
                GroupManager.shared.saveGroupListToRealm([group])
                self.entryCompletion?(group) ?? {}()
                }, ActionKyes.groupEntryReject: {
                    self.entryReject?(nil)
                }]
        case .lesson:
            return [ActionKyes.lessonEntryCompletion: {
                let title = self.inputViews.filter { $0.inputType == .lessonTitle }.first!
                let lesson = Lesson(lessonTitle: title.inputString)
                LessonManager.shared.saveLessonListToRealm([lesson])
                self.entryCompletion?(lesson) ?? {}()
                }, ActionKyes.lessonEntryReject: {
                    self.entryReject?(nil)
                }]
        case .event:
            return [ActionKyes.eventEntryCompletion: {
                let title = self.inputViews.filter { $0.inputType == .eventTitle }.first!
                let date = self.inputViews.filter { $0.inputType == .eventDate }.first!
                let event = Event(lessonId: self.sourceViewModel?.id ?? "", eventDate: date.inputString.dateFromDisplayedFormat,  eventTitle: title.inputString)
                EventManager.shared.saveEventListToRealm([event])
                self.entryCompletion?(event) ?? {}()
                }, ActionKyes.eventEntryReject: {
                    self.entryReject?(nil)
                }]
        case .groupMember:
            return [ActionKyes.memberEntryCompletion: {
                let kana = self.inputViews.filter { $0.inputType == .memberNameKana }.first
                let jp = self.inputViews.filter { $0.inputType == .memberNameJp }.first
                let email = self.inputViews.filter { $0.inputType == .memberEmail }.first
                var member: Member
                if let cloneMember = self.editMember?.clone {
                    cloneMember.nameJp = jp?.inputString ?? ""
                    cloneMember.nameKana = kana?.inputString ?? ""
                    cloneMember.email = email?.inputString ?? ""
                    member = cloneMember
                } else {
                    member = Member(nameJp: jp?.inputString ?? "", nameKana: kana?.inputString ?? "", email: email?.inputString ?? "")
                }
                MemberManager.shared.saveMemberListToRealm([member])
                guard let groupId = self.sourceViewModel?.id, groupId != "" else {
                    self.entryCompletion?(member) ?? {}()
                    return
                }
                GroupManager.shared.saveGroupMemberListToRealm([GroupMember(groupId: groupId, memberId: member.memberId)])
                self.entryCompletion?(member) ?? {}()
                }, ActionKyes.memberEntryReject: {
                    self.entryReject?(nil)
                }]
        case .lessonMember:
            return [ActionKyes.memberEntryCompletion: {
                let kana = self.inputViews.filter { $0.inputType == .memberNameKana }.first
                let jp = self.inputViews.filter { $0.inputType == .memberNameJp }.first
                let email = self.inputViews.filter { $0.inputType == .memberEmail }.first
                var member: Member
                if let cloneMember = self.editMember?.clone {
                    cloneMember.nameJp = jp?.inputString ?? ""
                    cloneMember.nameKana = kana?.inputString ?? ""
                    cloneMember.email = email?.inputString ?? ""
                    member = cloneMember
                } else {
                    member = Member(nameJp: jp?.inputString ?? "", nameKana: kana?.inputString ?? "", email: email?.inputString ?? "")
                }
                MemberManager.shared.saveMemberListToRealm([member])
                guard let lessonId = self.sourceViewModel?.id, lessonId != "" else {
                    self.entryCompletion?(member) ?? {}()
                    return
                }
                LessonManager.shared.saveLessonMemberListToRealm([LessonMember(lessonId: lessonId, memberId: member.memberId)])
                self.entryCompletion?(member) ?? {}()
                }, ActionKyes.memberEntryReject: {
                    self.entryReject?(nil)
                }]
        }
    }
    
    fileprivate var textFields: [UITextField] {
        return inputViews.map { $0.textField }
    }
    
    fileprivate var isInputCompleted: Bool {
        return textFields.filter { $0.text?.characters.count == 0 }.isEmpty
    }
    
    fileprivate var isInputValid: Bool {
        guard let _ = (inputViews.filter { inputView in
            inputView.swiftCop.isGuilty(inputView.textField)?.verdict() != nil
        }).first else {
            return true
        }
        return false
    }
    
    // MARK: - Initializer
    
    static func instantiate(entryModel: EntryModel, member: Member? = nil) -> EntryViewController {
        let viewController = R.storyboard.entryViewController.entryViewController()!
        viewController.entryCompletion = entryModel.entryCompletion
        viewController.entryReject = entryModel.entryReject
        viewController.sourceViewModel = entryModel.displayModel
        viewController.entryType = entryModel.entryType
        viewController.editMember = member
        return viewController
    }
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupHeaderView(entryType.headerTitle, buttonTypes: entryType.headerButtonItems(actions: actions))
        refreshHeaderView(enabled: false, buttonTypes: [[],[.regist(nil)]])
        
        inputViews.forEach { inputView in
            self.stackView.addArrangedSubview(inputView)
            inputView.snp.makeConstraints { make in
                make.height.equalTo(100)
            }
        }
        self.stackView.addArrangedSubview(UIView())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeShown),
                                               name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden),
                                               name: .UIKeyboardWillHide,  object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange),
                                               name: .UITextFieldTextDidChange, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UITextFieldTextDidChange, object: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        targetTextField?.resignFirstResponder()
    }
    
    func keyboardWillBeShown(notification: NSNotification) {
        
        guard let textFiled = targetTextField else {
            return
        }
        
        if let userInfo = notification.userInfo {
            if let keyboardFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as AnyObject).cgRectValue,
               let animationDuration = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as AnyObject).doubleValue {
                restoreScrollViewSize()
                
                // FIXME: ロジック間違ってるので修正
                let keyboardConvertFrame = scrollView.convert(keyboardFrame, from: nil)
                let offsetY = textFiled.convert(textFiled.frame, to: scrollView).maxY - keyboardConvertFrame.minY
                if offsetY < 0 { return }
                updateScrollViewSize(moveSize: offsetY, duration: animationDuration)
            }
        }
    }
    
    func keyboardWillBeHidden(notification: NSNotification) {
        restoreScrollViewSize()
    }
    
    func textFieldDidChange(notification: NSNotification) {
        validate()
        refreshHeaderView(enabled: isInputCompleted && isInputValid, buttonTypes: [[],[.regist(nil)]])
    }
    
    // MARK: Private Method
    
    private func validate() {
        inputViews.forEach { inputView in
            inputValidationCheck(inputView: inputView)
        }
    }
    
    private func inputValidationCheck(inputView: InputView) {
        guard let textField = inputView.textField, let text = textField.text else {
            disableValidateAlert(inputView)
            return
        }
        
        guard !text.isEmpty else {
            disableValidateAlert(inputView)
            return
        }
        
        if let message = inputView.swiftCop.isGuilty(textField)?.verdict() {
            if (toolTipViewList.isEmpty || toolTipViewList.contains(where: {
                ($0.tipView.text != message || $0.sourceView != inputView.textField)
            })) {
                disableValidateAlert(inputView)
                displayValidateAlert(inputView.textField, message: message)
            }
        } else {
            disableValidateAlert(inputView)
        }
    }
    
    private func displayValidateAlert(_ sourceView: UIView, message: String) {
        let toolTipView = EasyTipView(text: message, preferences: type(of: self).toolTipPreferences)
        toolTipView.show(forView: sourceView, withinSuperview: view)
        toolTipViewList.append((toolTipView, sourceView))
    }
    
    private func disableValidateAlert(_ sourceView: InputView) {
        guard let index = toolTipViewList.index(where: { $0.1 == sourceView.textField! }) else {
            return
        }
        toolTipViewList[index].tipView.dismiss()
        toolTipViewList.remove(at: index)
    }
    
    private func updateScrollViewSize(moveSize: CGFloat, duration: TimeInterval) {
        UIView.beginAnimations("Animation ID", context: nil)
        UIView.setAnimationDuration(duration)
        
        let contentInsets = UIEdgeInsetsMake(0, 0, moveSize, 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        scrollView.contentOffset = CGPoint(x: 0, y: moveSize)
        
        UIView.commitAnimations()
    }
    
    private func restoreScrollViewSize() {
        scrollView.contentInset = UIEdgeInsets.zero
        scrollView.scrollIndicatorInsets = UIEdgeInsets.zero
    }
}

extension EntryViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        targetTextField = textField
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension EntryViewController: ScreenReloadable {
    func reloadScreen() {
        headerView.refreshLayout()
        inputViews.forEach { $0.refreshLayout() }
    }
}

extension UIScrollView {
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesBegan(touches, with: event)
    }
}
