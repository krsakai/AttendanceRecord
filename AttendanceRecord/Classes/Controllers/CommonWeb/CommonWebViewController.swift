//
//  CommonWebViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/02.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal enum AggregateMode {
    case member
    case status
    
    func csvData(_ model: LessonAttendanceModel) -> Data {
        switch self {
        case .member: return model.csvData
        case .status: return model.distributionCsvData
        }
    }
    
    func htmlString(_ model: LessonAttendanceModel) -> String {
        switch self {
        case .member: return model.htmlString
        case .status: return model.distributionHtmlString
        }
    }
}

internal final class CommonWebViewController: UIViewController, HeaderViewDisplayable {
    
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet fileprivate weak var webView: UIWebView!
    
    fileprivate var lesson: Lesson?
    
    fileprivate var requestType: UIWebView.LoadRequestType!
    
    fileprivate var mode: AggregateMode = .member
    
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
        setupHeaderView(requestType.title, buttonTypes: [[.back], [
            .mode(HeaderModel() { _ in
                let alert = UIAlertController(
                    title: "表示設定切り替え",
                    message: "表示する内容を選択してください",
                    preferredStyle: .actionSheet
                )
                let attendanceAction = UIAlertAction(title: "出欠一覧", style: UIAlertActionStyle.default) { _ in
                    self.mode = .member
                    self.webView.loadRequest(requestType: .attendanceList, lesson: self.lesson ?? Lesson(), mode: self.mode)
                }
                let aggregateAction = UIAlertAction(title: "出欠分布",  style: UIAlertActionStyle.default) { _ in
                    self.mode = .status
                    self.webView.loadRequest(requestType: .attendanceList, lesson: self.lesson ?? Lesson(), mode: self.mode)
                }
                let cancelAction = UIAlertAction(title: R.string.localizable.commonLabelCancel(),
                                                 style: UIAlertActionStyle.cancel)
                alert.addAction(attendanceAction)
                alert.addAction(aggregateAction)
                alert.addAction(cancelAction)
                AppDelegate.navigation?.present(alert, animated: true, completion: nil)
            }),
            .send(HeaderModel() { _ in
                if !MailSendViewController.isEnabledSendMail {
                    AlertController.showAlert(title: "メール機能が利用できません", message: "設定よりメールの設定をお確かめ下さい")
                    return
                }
                let viewController = MailSendViewController.instantiate(lesson: self.lesson!, mode: self.mode)
                self.present(viewController, animated: true, completion: nil)
            })
        ]])
        webView.loadRequest(requestType: requestType, lesson: lesson ?? Lesson(), mode: mode)
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
        
        func loadHtmlString(lesson: Lesson, mode: AggregateMode) -> String {
            switch self  {
            case .attendanceList: return mode.htmlString(LessonAttendanceModel.instantiate(lesson: lesson))
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
    
    func loadRequest(requestType: LoadRequestType, lesson: Lesson, mode: AggregateMode = .member) {
        switch requestType {
        case .attendanceList, .none:
            loadHTMLString(requestType.loadHtmlString(lesson: lesson, mode: mode), baseURL: nil)
        case .backNumber:
            loadRequest(requestType.loadRequest!)
        }
        
    }
    
    // FIXME: せめてFactory作る
    private static var noneString: String {
        return "<html><body><div style=display:flex; alignItems:center;><p><span style=font-size : medium>To be implement</span></p></body></html>"
    }
}
