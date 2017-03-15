//
//  MemberEntryViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/03.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import RealmSwift

internal enum EntryType: HeaderButtonModel {
    case lesson
    case event
    case member
    
    var inputTypes: [InputType] {
        switch self {
        case .lesson: return [.lessonTitle]
        case .event:  return [.eventTitle, .eventDate]
        case .member: return [.memberNameRoma, .memberNameJp, .memberEmail]
        }
    }
    
    var headerTitle: String {
        switch self {
        case .lesson: return R.string.localizable.sideMenuLabelLessonList()
        case .event:  return R.string.localizable.headerTitleLabelEventList()
        case .member: return R.string.localizable.sideMenuLabelMemberList()
        }
    }
    
    func headerButtonItems(actions: [String: HeaderView.Action]? = nil) -> [[HeaderView.ButtonType]] {
        switch self {
        case .lesson:
            let action = actions?[ActionKyes.lessonEntry] ?? {}
            return [[.close],[.regist(action)]]
        case .event:
            let action = actions?[ActionKyes.eventEntry] ?? {}
            return [[.close],[.regist(action)]]
        case .member:
            let action = actions?[ActionKyes.memberEntry] ?? {}
            return [[.close],[.regist(action)]]
        }
    }
}

typealias EntryCompletion = ((Object?) -> Void)

internal final class EntryViewController: UIViewController, HeaderViewDisplayable {
    
    @IBOutlet weak var headerView: HeaderView!
    
    @IBOutlet fileprivate weak var scrollView: UIScrollView!
    @IBOutlet weak var stackView: UIStackView!
    
    fileprivate var targetTextField: UITextField?
    
    fileprivate var sourceViewModel: DisplayModel?
    
    fileprivate lazy var inputViews: [InputView] = {
        switch self.entryType {
        case .lesson:
            return [InputView.instantiate(owner: self, inputType: .lessonTitle)]
        case .event:
            return [InputView.instantiate(owner: self, inputType: .eventTitle),
                    InputView.instantiate(owner: self, inputType: .eventDate)]
        case .member:
            return [InputView.instantiate(owner: self, inputType: .memberNameRoma),
                    InputView.instantiate(owner: self, inputType: .memberNameJp),
                    InputView.instantiate(owner: self, inputType: .memberEmail)]
        }
    }()
    
    
    fileprivate var entryType: EntryType = .lesson
    
    var entryCompletion: EntryCompletion?
    
    private var actions: [String: HeaderView.Action] {
        switch entryType {
        case .lesson:
            return [ActionKyes.lessonEntry: {
                let title = self.inputViews.filter { $0.inputType == .lessonTitle }.first!
                let lesson = Lesson(lessonTitle: title.inputString)
                LessonManager.shared.saveLessonListToRealm([lesson])
                self.entryCompletion?(lesson) ?? {}()
                }]
        case .event:
            return [ActionKyes.eventEntry: {
                let title = self.inputViews.filter { $0.inputType == .eventTitle }.first!
                let date = self.inputViews.filter { $0.inputType == .eventDate }.first!
                let event = Event(lessonId: self.sourceViewModel?.id ?? "", eventDate: date.inputString.dateFromDisplayedFormat,  eventTitle: title.inputString)
                EventManager.shared.saveEventListToRealm([event])
                self.entryCompletion?(event) ?? {}()
                }]
        case .member:
            return [ActionKyes.memberEntry: {
                let roma = self.inputViews.filter { $0.inputType == .memberNameRoma }.first!
                let jp = self.inputViews.filter { $0.inputType == .memberNameJp }.first!
                let email = self.inputViews.filter { $0.inputType == .memberEmail }.first!
                let member = Member(nameJp: jp.inputString, nameRoma: roma.inputString, email: email.inputString)
                MemberManager.shared.saveMemberListToRealm([member])
                self.entryCompletion?(member) ?? {}()
                }]
        }
    }
    
    fileprivate var textFields: [UITextField] {
        return inputViews.map { $0.textField }
    }
    
    // MARK: - Initializer
    
    static func instantiate(entryType: EntryType, sourceViewModel: DisplayModel? = nil, completion: EntryCompletion? = nil) -> EntryViewController {
        let viewController = R.storyboard.entryViewController.entryViewController()!
        viewController.entryCompletion = completion
        viewController.sourceViewModel = sourceViewModel
        viewController.entryType = entryType
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
        refreshHeaderView(enabled: (textFields.filter { $0.text?.characters.count == 0 }.isEmpty), buttonTypes: [[],[.regist(nil)]])
    }
    
    func updateScrollViewSize(moveSize: CGFloat, duration: TimeInterval) {
        UIView.beginAnimations("Animation ID", context: nil)
        UIView.setAnimationDuration(duration)
        
        let contentInsets = UIEdgeInsetsMake(0, 0, moveSize, 0)
        scrollView.contentInset = contentInsets
        scrollView.scrollIndicatorInsets = contentInsets
        scrollView.contentOffset = CGPoint(x: 0, y: moveSize)
        
        UIView.commitAnimations()
    }
    
    func restoreScrollViewSize() {
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

extension UIScrollView {
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        superview?.touchesBegan(touches, with: event)
    }
}
