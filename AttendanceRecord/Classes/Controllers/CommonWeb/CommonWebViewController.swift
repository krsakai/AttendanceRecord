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
        setupHeaderView(requestType.title, buttonTypes: [[.back],[.send(HeaderModel() { _ in
            if !MailSendViewController.isEnabledSendMail {
                AlertController.showAlert(title: "メール機能が利用できません", message: "設定よりメールの設定をお確かめ下さい")
                return
            }
            let viewController = MailSendViewController.instantiate(lesson: self.lesson!)
            self.present(viewController, animated: true, completion: nil)
        })]])
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
        
        func loadHtmlString(lesson: Lesson) -> String {
            switch self  {
            case .attendanceList: return LessonAttendanceModel.instantiate(lesson: lesson).htmlString
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
}
