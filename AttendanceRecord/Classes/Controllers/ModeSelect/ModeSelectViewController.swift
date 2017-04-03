//
//  ModeSelectViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/09.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal final class ModeSelectViewController: UIViewController, HeaderViewDisplayable  {
    
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var stackView: UIStackView!
    
    private var modeList: [Mode] {
        return [.organizer, .member]
    }
    
    // MARK: - Initializer
    
    static func instantiate() -> ModeSelectViewController {
        let viewController = R.storyboard.main.modeSelectViewController()!
        return viewController
    }
    
    // MARK: - View LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupHeaderView(R.string.localizable.modeTitleLabelModeSelect())
        modeList.forEach { mode in
            stackView.addArrangedSubview(ModeView.instantiate(owner: self, mode: mode))
        }
    }
}
