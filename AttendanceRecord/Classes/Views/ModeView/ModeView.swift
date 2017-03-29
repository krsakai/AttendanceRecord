//
//  ModeView.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/09.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import SwiftTask

protocol ModeVariety {
    var mode: Mode { get set }
}

internal enum Mode: Int {
    case organizer  = 1
    case member     = 2
    
    var buttonText: String {
        switch self {
        case .member: return R.string.localizable.modeButtonLabelMember()
        case .organizer: return R.string.localizable.modeButtonLabelOrganizer()
        }
    }
}

typealias ModeSelectTask = Task<Void, Void, Void>

internal final class ModeView: UIView {
    
    @IBOutlet private var modeButton: UIButton!
    
    private var mode: Mode!
    
    // MARK: - Initializer
    
    static func instantiate(owner: AnyObject, mode: Mode) -> ModeView {
        let contentView = R.nib.modeView.firstView(owner: owner, options: nil)! 
        contentView.mode = mode
        contentView.modeButton.setTitle(mode.buttonText, for: .normal)
        contentView.modeButton.setTitle(mode.buttonText, for: .highlighted)
        contentView.modeButton.titleLabel?.adjustsFontSizeToFitWidth = true
        return contentView
    }
    
    
    @IBAction func didTap(modeButton: UIButton) {
        
        ModeSelectTask {  _, fulfill, _, _ in
            if self.mode == .member, DeviceModel.currentMember == nil {
                let viewController = EntryViewController.instantiate(entryModel: EntryModel(entryType: .member, entryCompletion: { member in
                    DeviceModel.setCurrentMember(member: member as! Member)
                    fulfill()
                }))
                AppDelegate.navigation?.present(viewController, animated: true)
            } else {
                fulfill()
            }
        }.success { _ in
            DeviceModel.mode = self.mode
            AppDelegate.reloadScreen()
            AppDelegate.sideMenu?.changeContentViewController()
        }
    }
}
