//
//  AlertController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/07.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal class AlertController {
    
    static func showAlert(title: String? = "", message: String = "", enableCancel: Bool = true, ok: (() -> Void)? = nil, cancel: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: R.string.localizable.commonLabelOK(), style: .default) { _ in ok?() })
        if enableCancel { alert.addAction(UIAlertAction(title: R.string.localizable.commonLabelCancel(), style: .default) { _ in cancel?() }) }
        UIApplication.topViewController()?.present(alert, animated: true)
    }
}
