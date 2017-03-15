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
    
    fileprivate var requestType: UIWebView.LoadRequestType!
    
    // MARK: - Initializer
    
    static func instantiate(requestType: UIWebView.LoadRequestType) -> CommonWebViewController {
        let viewController = R.storyboard.commonWebViewController.commonWebViewController()!
        viewController.requestType = requestType
        return viewController
    }
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView(requestType.title, buttonTypes: requestType.buttonTypes)
        webView.loadRequest(requestType: requestType)
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
            case .attendanceList, .backNumber: return [[.sideMenu],[]]
            case .none: return [[.close],[]]
            }
        }
        
        var loadHtmlString: String {
            switch self  {
            case .attendanceList: return UIWebView.attendanceListString
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
    
    func loadRequest(requestType: LoadRequestType) {
        switch requestType {
        case .attendanceList, .none:
            loadHTMLString(requestType.loadHtmlString, baseURL: nil)
        case .backNumber:
            loadRequest(requestType.loadRequest!)
        }
        
    }
    
    // FIXME: せめてFactory作る
    private static var noneString: String {
        return "<html><body><div style=display:flex; alignItems:center;><p><span style=font-size : medium>To be implement</span></p></body></html>"
    }
    
    private static var attendanceListString: String {
        let memberList = MemberManager.shared.memberListDataFromRealm()
        let viewModels = AttendanceManager.shared.memberAttendanceViewModels(member: memberList.first)
        var htmlString = "<html><body><table border=1 cellspacing=0 cellpadding=0><tr bgcolor=#BCC8DB><td></td>"
        viewModels.forEach { viewModel in
            htmlString.append("<td align=center valign=center> \(viewModel.event.eventDate.stringFromDate(format: .displayMonthToDay)) </td>")
        }
        htmlString.append("</tr>")
        _ = memberList.enumerated().map { (index, member) in
            let viewModels = AttendanceManager.shared.memberAttendanceViewModels(member: member)
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
