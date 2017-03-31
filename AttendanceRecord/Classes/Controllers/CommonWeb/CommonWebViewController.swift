//
//  CommonWebViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/02.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal final class CommonWebViewController: UIViewController, HeaderViewDisplayable {
    
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet fileprivate weak var webView: UIWebView!
    
    fileprivate var lesson: Lesson?
    
    fileprivate var requestType: UIWebView.LoadRequestType!
    
    // MARK: - Initializer
    
    static func instantiate(requestType: UIWebView.LoadRequestType, lesson: Lesson? = nil) -> CommonWebViewController {
        let viewController = R.storyboard.commonWebViewController.commonWebViewController()!
        viewController.requestType = requestType
        viewController.lesson = lesson
        return viewController
    }
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView(requestType.title, buttonTypes: requestType.buttonTypes)
        webView.loadRequest(requestType: requestType, lesson: lesson ?? Lesson())
    }
}

extension UIWebView {
    
    enum LoadRequestType {
        case attendanceList
        case backNumber
        case none
        
        var title: String {
            switch self {
            case .attendanceList: return R.string.localizable.sideMenuLabelAttendanceTable()
            case .backNumber: return R.string.localizable.sideMenuLabelBackNumber()
            case .none: return R.string.localizable.sideMenuLabelSetting()
            }
        }
        
        var buttonTypes: [[HeaderView.ButtonType]] {
            switch self {
            case .attendanceList, .backNumber: return [[.back],[]]
            case .none: return [[.close(nil)],[]]
            }
        }
        
        func loadHtmlString(lesson: Lesson) -> String {
            switch self  {
            case .attendanceList: return UIWebView.attendanceListString(lesson: lesson)
            case .backNumber: return ""
            case .none: return UIWebView.noneString
            }
        }
        
        var loadRequest: URLRequest? {
            switch self  {
            case .attendanceList: return URLRequest(url: URL(string: "")!)
            // TODO: URLの静的定義ファイル作る
            case .backNumber: return URLRequest(url: URL(string: "https://github.com/krsakai/StudyiOS")!)
            case .none: return URLRequest(url: URL(string: "")!)
            }
        }
    }
    
    func loadRequest(requestType: LoadRequestType, lesson: Lesson) {
        switch requestType {
        case .attendanceList, .none:
            loadHTMLString(requestType.loadHtmlString(lesson: lesson), baseURL: nil)
        case .backNumber:
            loadRequest(requestType.loadRequest!)
        }
        
    }
    
    // FIXME: せめてFactory作る
    private static var noneString: String {
        return "<html><body><div style=display:flex; alignItems:center;><p><span style=font-size : medium>To be implement</span></p></body></html>"
    }
    
    private static func attendanceListString(lesson: Lesson) -> String {
        
        // イベント一覧取得
        let eventList = EventManager.shared.eventListDataFromRealm(predicate: Event.predicate(lessonId: lesson.lessonId))
        
        guard !eventList.isEmpty else {
            return "1件もイベントが登録されていません"
        }
        
        // HTML文字列
        var htmlString = "<html><body><table border=1 cellspacing=0 cellpadding=0><tr bgcolor=#BCC8DB><td></td>"
        
        // イベント(横欄)追加
        eventList.forEach { event in
            htmlString.append("<td align=center valign=center> \(event.eventTitle) </td>")
        }
        
        // 縦(メンバー名) + 出席追加
        let lessonMemberList = LessonManager.shared.lessonMemberListDataFromRealm(predicate: LessonMember.predicate(lessonId: lesson.lessonId))
        
        htmlString.append("</tr>")
        
        _ = lessonMemberList.enumerated().map { (index, lessonMember) in
            guard let member = (MemberManager.shared.memberListDataFromRealm(predicate: Member.predicate(memberId: lessonMember.memberId)).first) else {
                return
            }
            let viewModels = AttendanceManager.shared.memberAttendanceViewModels(member: member, lesson: lesson)
            let color = index % 2 == 0 ? "whitesmoke" : "#b0c4de"
            htmlString.append("<tr bgcolor=\(color)><td align=center valign=center>\(member.nameJp)</td>")
            viewModels.forEach { viewModel in
                htmlString.append("<td align=center valign=center>\(viewModel.attendance.attendanceStatusRawValue)</td>")
            }
            htmlString.append("</tr>")
        }
        
        htmlString.append("</body></table>")
        return htmlString
    }
}
