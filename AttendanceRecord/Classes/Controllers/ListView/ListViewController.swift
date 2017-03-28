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

protocol DisplayModel {
    var id: String { get }
    var titleName: String { get }
}

extension Object: DisplayModel {
    var id: String { return "" }
    var titleName: String { return "" }
}

internal enum ListType: HeaderButtonModel {
    case lesson(DisplayModel?)
    case event(DisplayModel?)
    case member(DisplayModel?)
    
    var headerTitle: String {
        switch self {
        case .lesson(let model): return model?.titleName ?? R.string.localizable.sideMenuLabelLessonList()
        case .event(let model): return model?.titleName ?? R.string.localizable.headerTitleLabelEventList()
        case .member(let model): return model?.titleName ?? R.string.localizable.sideMenuLabelAttendanceMemberList()
        }
    }
    
    var entryType: EntryType {
        switch self {
        case .lesson: return .lesson
        case .event: return .event
        case .member: return .member
        }
    }
    
    var actionKey: String {
        switch self {
        case .lesson: return ActionKyes.lessonAdd
        case .event: return ActionKyes.eventAdd
        case .member: return ActionKyes.memberAdd
        }
    }
    
    var displayModel: DisplayModel? {
        switch self {
        case .lesson(let model): return model
        case .event(let model): return model
        case .member(let model): return model
        }
    }
    
    func cell(owner: SWTableViewCellDelegate, model: Object) -> UITableViewCell {
        switch self {
        case .lesson: return LessonTableViewCell.instantiate(owner, lesson: model as! Lesson)
        case .event: return EventListTableCell.instantiate(owner, event: model as! Event)
        case .member: return MemberListTableCell.instantiate(owner, member: model as! Member)
        }
    }
    
    func list(sourceViewModel: DisplayModel? = nil) -> [Object] {
        switch self {
        case .lesson: return LessonManager.shared.lessonListDataFromRealm()
        case .event: return EventManager.shared.eventListDataFromRealm(predicate: Event.predicate(lessonId: sourceViewModel?.id ?? ""))
        case .member: return MemberManager.shared.memberListDataFromRealm()
        }
    }
    
    func destination(sourceViewModel: DisplayModel) -> UIViewController? {
        switch self {
        case .lesson:
            return ListViewController.instantiate(type: .event(sourceViewModel))
        case .event:
            return MemberAttendanceViewController.instantiate(event: sourceViewModel as! Event)
        case .member: return nil
        }
    }
}

internal final class ListViewController: UIViewController, HeaderViewDisplayable {
    
    @IBOutlet weak var headerView: HeaderView!
    
    @IBOutlet fileprivate weak var footerView: FooterView!
    @IBOutlet fileprivate weak var tableView: UITableView!
    
    fileprivate var type: ListType = .lesson(nil)
    
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
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    private var headerButtons: [[HeaderView.ButtonType]] {
        
        switch type {
        case .lesson(let model):
            return [[.sideMenu],
                    [.add(HeaderModel(entryModel: EntryModel(entryType: self.type.entryType, displayModel: model)))]]
        case .event(let model):
            return [[.back],
                    [.memberReception(HeaderModel() {
                        MemberEntryCentralManager.shared.searchMember()
                    }),
                     .add(HeaderModel(entryModel: EntryModel(entryType: self.type.entryType, displayModel: model)))]]
        case .member(let model):
            return [[.sideMenu],
                    [.add(HeaderModel(entryModel: EntryModel(entryType: self.type.entryType, displayModel: model)))]]
        }
    }
}

extension ListViewController: UITableViewDataSource {
    
    static let defalutCellRowHeight = CGFloat(80)
    
    fileprivate var list: [Object] {
        return type.list(sourceViewModel: type.displayModel)
    }
    
    // MARK: - UITableView DataSource
    
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
        return type.cell(owner: self, model: list[indexPath.row])
    }
}

extension ListViewController: UITableViewDelegate {
    
    // MARK: - UITableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        guard let viewController = type.destination(sourceViewModel: list[indexPath.row]) else {
            return
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
}

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
            }
        }
        
        AlertController.showAlert(title: R.string.localizable.alertTitleDeleteComfirm(),
                                  message: R.string.localizable.alertMessageDelete(entity.titleName), ok: { _ in
            action()
            self.tableView.reloadData()
        })
    }
}

extension ListViewController: ScreenReloadable {
    func reloadScreen() {
        // Xibからビュー生成前に呼ばれる対策
        guard headerView != nil else { return }
        headerView.refreshLayout()
        footerView.refreshLayout()
        tableView.reloadData()
    }
}
