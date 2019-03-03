//
//  ListViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/25.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import SWTableViewCell
import RealmSwift
import ObjectMapper
import Popover
import SnapKit

// MARK: - Display Model Extension

protocol DisplayModel {
    var id: String { get }
    var titleName: String { get }
}

extension Object: DisplayModel {
    var id: String { return "" }
    var titleName: String { return "" }
}

// MARK: - List Type Enum

internal enum ListType: HeaderButtonModel {
    case lesson(DisplayModel?)
    case event(DisplayModel?)
    case member(DisplayModel?)
    case attendance(DisplayModel?)
    
    var headerTitle: String {
        switch (self, DeviceModel.mode) {
        case (.lesson, .organizer): return R.string.localizable.sideMenuLabelLessonList()
        case (.lesson, .member): return R.string.localizable.sideMenuLabelAttendanceLessonList()
        case (.event(let model), _): return model?.titleName ?? R.string.localizable.headerTitleLabelEventList()
        case (.member(let model), _): return model?.titleName ?? R.string.localizable.sideMenuLabelAttendanceMemberList()
        case (.attendance, _): return R.string.localizable.sideMenuLabelAttendanceTable()
        default: return ""
        }
    }
    
    var entryType: EntryType {
        switch self {
        case .lesson: return .lesson
        case .event: return .event
        case .member: return .member
        case .attendance: return .lesson
        }
    }
    
    var actionKey: String {
        switch self {
        case .lesson: return ActionKyes.lessonAdd
        case .event: return ActionKyes.eventAdd
        case .member: return ActionKyes.memberAdd
        case .attendance: return ""
        }
    }
    
    var displayModel: DisplayModel? {
        switch self {
        case .lesson(let model): return model
        case .event(let model): return model
        case .member(let model): return model
        case .attendance(let model): return model
        }
    }
    
    func list(sourceViewModel: DisplayModel? = nil) -> [Object] {
        switch (self, DeviceModel.mode) {
        case (.lesson, .organizer):
            return LessonManager.shared.lessonListDataFromRealm()
        case (.lesson, .member):
            return LessonManager.shared.lessonMemberListDataFromRealm(predicate: LessonMember.predicate(memberId: sourceViewModel?.id ?? ""))
        case (.event, _): return EventManager.shared.eventListDataFromRealm(predicate: Event.predicate(lessonId: sourceViewModel?.id ?? ""))
        case (.member, _): return MemberManager.shared.memberListDataFromRealm()
        case (.attendance, _): return LessonManager.shared.lessonListDataFromRealm()
        default: return [Object()]
        }
    }
    
    func destination(sourceViewModel: DisplayModel) -> UIViewController? {
        switch (self, DeviceModel.mode) {
        case (.lesson, _):
            return ListViewController.instantiate(type: .event(sourceViewModel))
        case (.event, .organizer):
            return MemberAttendanceViewController.instantiate(event: sourceViewModel as! Event)
        case (.event, .member):
            return nil
        case (.member, _): return nil
        case (.attendance, _): return CommonWebViewController.instantiate(requestType: .attendanceList, lesson: sourceViewModel as? Lesson)
        }
    }
}

// MARK: - ListViewController

internal final class ListViewController: UIViewController, HeaderViewDisplayable {
    
    // MARK: - IBOutlet
    
    @IBOutlet weak var headerView: HeaderView!
    
    @IBOutlet fileprivate weak var footerView: FooterView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    // MARK: - Properties
    
    fileprivate var type: ListType = .lesson(nil)
    
    fileprivate lazy var popover: Popover = {
        let popover = Popover(options: self.popoverOptions)
        return Popover(options: self.popoverOptions)
    }()
    
    fileprivate var popoverOptions: [PopoverOption] = [
        .cornerRadius(0),
        .type(.down),
        .blackOverlayColor(UIColor(white: 0.0, alpha: 0.3)),
        PopoverOption.animationOut(0),
        .color(DeviceModel.themeColor.color)
    ]
    
    private var headerButtons: [[HeaderView.ButtonType]] {
        
        switch (type, DeviceModel.mode) {
        case (.lesson(let model), .organizer):
            return [[.sideMenu],
                    [.add(HeaderModel(entryModel: EntryModel(entryType: self.type.entryType, displayModel: model)))]]
        case (.lesson, .member):
            return [[.sideMenu],
                    [.request(HeaderModel() {
                        PeripheralManager.shared.start()
                    })]]
        case (.event(let model), .organizer):
            return [[.back],
                    [.selection(HeaderModel(selectionAction: { targetView in
                        // メンバー選択
                        let selection = PopoverItem(title: R.string.localizable.headerTitleLabelMemberSelect()) { _ in
                            self.popover.dismiss()
                            let viewController = MemberSelectViewController.instantiate(lesson: LessonManager.shared.lessonListDataFromRealm(predicate: Lesson.predicate(lessonId: model?.id ?? "")).first ?? Lesson())
                            self.present(viewController, animated: true, completion: nil)
                        }
                        
                        // メンバー登録
                        let entry = PopoverItem(title: R.string.localizable.memberSelectionAlertTitleMemberRegister()) { _ in
                            self.popover.dismiss()
                            let viewController = EntryViewController.instantiate(entryModel: EntryModel(entryType: .member, displayModel: model))
                            UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
                        }
                        
                        let selectionView = SelectionView.instantiate(owner: self, items: [selection, entry])
                        self.popover.show(selectionView, fromView: targetView)
                    })),
                     .add(HeaderModel(entryModel: EntryModel(entryType: self.type.entryType, displayModel: model)))]]
        case (.event, .member):
            return [[.back],[]]
        case (.member, .organizer):
            return [[.sideMenu],
                    [.add(HeaderModel(entryModel: EntryModel(entryType: self.type.entryType, displayModel: nil)))]]
        default: return [[.sideMenu],[]]
        }
    }
    
    // MARK: - Initializer
    
    static func instantiate(type: ListType) -> ListViewController {
        let viewController = R.storyboard.listViewController.listViewController()!
        viewController.type = type
        return viewController
    }
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = ListViewController.defalutCellRowHeight
        tableView.separatorColor = DeviceModel.themeColor.color
        
        setupHeaderView(type.headerTitle, buttonTypes: headerButtons)
        
        switch type {
        case .lesson, .attendance: tableView.register(LessonTableViewCell.self)
        case .event: tableView.register(EventListTableCell.self)
        case .member: tableView.register(MemberListTableCell.self)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
}

// MARK: - UITableViewDataSource

extension ListViewController: UITableViewDataSource {
    
    static let defalutCellRowHeight = CGFloat(80)
    
    fileprivate var list: [Object] {
        return type.list(sourceViewModel: type.displayModel)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return ListViewController.defalutCellRowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch type {
        case .lesson, .attendance:
            let cell = tableView.dequeueReusableCell(for: indexPath) as LessonTableViewCell
            cell.setup(self, lesson: list[indexPath.row] as! Lesson, listType: type)
            return cell
        case .event:
            let cell = tableView.dequeueReusableCell(for: indexPath) as EventListTableCell
            cell.setup(self, event:  list[indexPath.row] as! Event)
            return cell
        case .member:
            let cell = tableView.dequeueReusableCell(for: indexPath) as MemberListTableCell
            cell.setup(self, member:  list[indexPath.row] as! Member)
            return cell
        }
    }
}

// MARK: - UITableViewDelegate

extension ListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let viewController = type.destination(sourceViewModel: list[indexPath.row]) {
            navigationController?.pushViewController(viewController, animated: true)
        }
        
        if case .member = type {
            let completion: EntryCompletion = { _ in
                self.tableView.reloadData()
            }
            let object = list[indexPath.row]
            if let member = MemberManager.shared.memberListDataFromRealm(predicate: Member.predicate(memberId: object.id)).first {
                let entryModel = EntryModel(entryType: .member, displayModel: member, entryCompletion: completion)
                let viewController = EntryViewController.instantiate(entryModel: entryModel, member: member)
                navigationController?.present(viewController, animated: true, completion: nil)
            }
            
        }
    }
}

// MARK: - SWTableViewCellDelegate

extension ListViewController: SWTableViewCellDelegate {
    
    func swipeableTableViewCell(_ cell: SWTableViewCell!, didTriggerRightUtilityButtonWith index: Int) {
        guard let entity = cell.entity, !entity.id.isEmpty else {
            return
        }
        
        let action = {
            switch self.type {
            case .lesson: LessonManager.shared.removeLessonToRealm(entity as! Lesson)
            case .event: EventManager.shared.removeEventToRealm(entity as! Event)
            case .member: MemberManager.shared.removeMemberToRealm(entity as! Member)
            case .attendance: ()
            }
        }
        
        AlertController.showAlert(title: R.string.localizable.alertTitleDeleteComfirm(),
                                  message: R.string.localizable.alertMessageDelete(entity.titleName),
                                  positiveAction: { _ in
            action()
            self.tableView.reloadData()
        })
    }
}

// MARK: - ScreenReloadable

extension ListViewController: ScreenReloadable {
    func reloadScreen() {
        // Xibからビュー生成前に呼ばれる対策
        guard headerView != nil else { return }
        headerView.refreshLayout()
        footerView.refreshLayout()
        tableView.reloadData()
    }
}

extension ListViewController: UIPopoverPresentationControllerDelegate {
    func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .none
    }
}

