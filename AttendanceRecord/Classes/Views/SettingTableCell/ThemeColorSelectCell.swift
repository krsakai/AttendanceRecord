//
//  ThemeColorSelectCell.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/28.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import HSegmentControl

internal class ThemeColorSelectCell: UITableViewCell {
    
    @IBOutlet private weak var segmentControl: HSegmentControl!
    
    fileprivate var themeColorList: [ThemeColor] {
        return [ThemeColor.red, ThemeColor.blue, ThemeColor.green, ThemeColor.water]
    }
    
    static func instantiate(_ owner: AnyObject) -> ThemeColorSelectCell {
        let cell = R.nib.themeColorSelectCell.firstView(owner: owner, options: nil)!
        cell.segmentControl.dataSource = cell
        cell.segmentControl.numberOfDisplayedSegments = cell.themeColorList.count
        cell.segmentControl.selectedTitleFont = UIFont.systemFont(ofSize: 17)
        cell.segmentControl.selectedTitleColor = UIColor.white
        cell.segmentControl.unselectedTitleFont = UIFont.systemFont(ofSize: 17)
        cell.segmentControl.unselectedTitleColor = UIColor.gray
        cell.segmentControl.segmentIndicatorView.backgroundColor = DeviceModel.themeColor.color
        cell.segmentControl.selectedIndex = cell.themeColorList.index(of: DeviceModel.themeColor)!
        return cell
    }
    
    @IBAction func valueChanged(segmentControl: HSegmentControl) {
        DeviceModel.themeColor = themeColorList[segmentControl.selectedIndex]
        AppDelegate.reloadScreen()
    }
}

extension ThemeColorSelectCell: HSegmentControlDataSource {
    
    func numberOfSegments(_ segmentControl: HSegmentControl) -> Int {
        return themeColorList.count
    }
    
    func segmentControl(_ segmentControl: HSegmentControl, titleOfIndex index: Int) -> String {
        return themeColorList[index].title
    }
}
