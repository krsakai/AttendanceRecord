//
//  LoadingController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/09.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import SwiftSpinner

internal enum Loading {
    case memberEntry
    case attendanceReception
}

internal class LoadingController: AnyObject {
    
    typealias LoadingCompletion = (() -> Void)?
    private var loadingCompletion: LoadingCompletion = nil
    
    static let shared = LoadingController()
    
    func show(completion: LoadingCompletion = nil) {
        // MARK: - Reason Fontが元に戻るのでshowする時に必ず設定している
        SwiftSpinner.setTitleFont(AttendanceRecordFont.loading.title)
        SwiftSpinner.useContainerView(AppDelegate.navigation?.view)
        loadingCompletion = completion ?? loadingCompletion
        SwiftSpinner.show(R.string.localizable.loadingTitleLabelMemberSearch()).addTapHandler(
        { self.hide() }, subtitle: R.string.localizable.loadingSubTitleLabelTapCancel())
    }
    
    func update(title: String) {
        SwiftSpinner.setTitleFont(AttendanceRecordFont.loading.title)
        SwiftSpinner.show(title)
        Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(updateTimer(_:)), userInfo: nil, repeats: false)
    }
    
    func hide() {
        SwiftSpinner.hide(loadingCompletion)
        loadingCompletion = nil
    }
    
    @objc func updateTimer(_ timer: Timer) {
        show()
    }
}
