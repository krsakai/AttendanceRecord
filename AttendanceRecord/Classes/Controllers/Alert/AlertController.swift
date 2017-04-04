//
//  AlertController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/07.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal class AlertController {
    
    static func showAlert(title: String? = "", message: String = "", enableCancel: Bool = true, positiveLabel: String = R.string.localizable.commonLabelOK(), negativeLabel: String = R.string.localizable.commonLabelCancel(), positiveAction: (() -> Void)? = nil, negativeAction: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: positiveLabel, style: .default) { _ in positiveAction?() })
        if enableCancel { alert.addAction(UIAlertAction(title: negativeLabel, style: .default) { _ in negativeAction?() }) }
        UIApplication.topViewController()?.present(alert, animated: true)
    }
}
