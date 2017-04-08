//
//  SplashViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/04/03.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import SwiftTask

internal final class SplashViewController: UIViewController {
    
    // MARK: IBOutlet
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    // MARK: Property
    
    // MARK: Initilizer
    
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        sleep(1)
        Task<Void, Void, Void> { _, fulfill,_, _ in
            self.titleLabel.changeScale(duration: 0.3, scale: CGPoint(x: 1.3, y: 1.3), completion: fulfill)
        }.success { _ in
            return Task<Void, Void, Void> { _, fulfill,_, _ in
                self.titleLabel.changeScale(duration: 0.3, scale: CGPoint(x: 1.0, y:1.0), completion: fulfill)
            }
        }.success {
            AppDelegate.sideMenu?.changeContentViewController()
        }
    }
}

extension UIView {
    
    func changeScale(duration: TimeInterval, scale: CGPoint, completion: (() -> Void)?) {
        UIView.animate(withDuration: duration, animations: {
            self.transform = CGAffineTransform(scaleX: scale.x, y: scale.y)
        }, completion: { _ in
            completion?()
        })
    }
    
}
