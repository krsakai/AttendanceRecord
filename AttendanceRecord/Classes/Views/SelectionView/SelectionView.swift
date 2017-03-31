//
//  SelectionView.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/30.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit

struct PopoverItem {
    
    var title: String
    
    var action: (() -> Void)?
}

internal final class SelectionView: UIView {
    
    static let width = 200
    static let height = 50
    
    @IBOutlet private var tableView: UITableView!
    
    fileprivate var popoverItems: [PopoverItem]!
    
    static func instantiate(owner: AnyObject, items: [PopoverItem]) -> SelectionView {
        let selectionView = R.nib.selectionView.firstView(owner: owner, options: nil)!
        selectionView.popoverItems = items
        selectionView.tableView.delegate = selectionView
        selectionView.tableView.dataSource = selectionView
        selectionView.frame = CGRect(x: 0, y: 0, width: width, height: height * items.count)
        selectionView.tableView.frame = selectionView.frame
        selectionView.tableView.separatorColor = .white
        return selectionView
    }
    
}

extension SelectionView: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return popoverItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return SelectionViewCell.instantiate(tableView, item: popoverItems[indexPath.row])
    }
}

extension SelectionView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        popoverItems[indexPath.row].action?()
    }
}
