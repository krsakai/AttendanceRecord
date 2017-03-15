//
//  UnderLineView.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/12.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

internal final class UnderLineView: UIView {
    
    // MARK: - Initializer
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        let contentView = R.nib.underLineView.firstView(owner: self, options: nil)!
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.right.left.bottom.top.equalTo(0)
        }
        contentView.backgroundColor = DeviceModel.themeColor.color
    }

}
