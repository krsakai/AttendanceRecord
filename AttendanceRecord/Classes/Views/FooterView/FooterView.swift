//
//  FooterView.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/26.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import SnapKit

/// ヘッダービュー
internal final class FooterView: UIView {
    
    fileprivate var contentView: UIView!

    // MARK: - Initializer
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView = R.nib.footerView.firstView(owner: self, options: nil)!
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.right.left.bottom.top.equalTo(0)
        }
        contentView.backgroundColor = DeviceModel.themeColor.color
    }
}

extension FooterView: LayoutUpdable {
    func refreshLayout() {
        contentView.backgroundColor = DeviceModel.themeColor.color
    }
}
