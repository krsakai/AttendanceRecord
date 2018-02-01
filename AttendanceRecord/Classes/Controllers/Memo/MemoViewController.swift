//
//  MemoViewController.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2018/02/01.
//  Copyright © 2018年 酒井邦也. All rights reserved.
//

import UIKit

internal final class MemoViewController: UIViewController, HeaderViewDisplayable {
    @IBOutlet weak var headerView: HeaderView!
    @IBOutlet weak var textView: CustomTextView!
    
    private var attendance: Attendance?
    
    static func instantiate(attendance: Attendance) -> MemoViewController {
        let viewController =  R.storyboard.memoViewController.memoViewController()!
        viewController.attendance = attendance
        return viewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = attendance?.reason
        setupHeaderView("出欠理由", buttonTypes: [[.back],[]])
        let hideTap : UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKyeoboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        let kbToolBar = UIToolbar(frame: CGRect(x: 0, y: 0, width: 320, height: 40))
        kbToolBar.barStyle = UIBarStyle.default
        kbToolBar.sizeToFit()
        let spacer = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: self, action: nil)
        let commitButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.save, target: self, action: #selector(MemoViewController.commitButtonTapped))
        kbToolBar.items = [spacer, commitButton]
        textView.inputAccessoryView = kbToolBar
        
    }
    
    // キーボード以外をタップするとキーボードが下がるメソッド
    func hideKyeoboardTap(recognizer : UITapGestureRecognizer){
        guard let cloneAttendance = attendance?.clone else {
            return
        }
        cloneAttendance.reason = textView.text
        AttendanceManager.shared.saveAttendanceListToRealm([cloneAttendance])
        self.view.endEditing(true)
    }
    
    func commitButtonTapped (){
        guard let cloneAttendance = attendance?.clone else {
            return
        }
        cloneAttendance.reason = textView.text
        AttendanceManager.shared.saveAttendanceListToRealm([cloneAttendance])
        view.endEditing(true)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        guard let cloneAttendance = attendance?.clone else {
            return
        }
        cloneAttendance.reason = textView.text
        AttendanceManager.shared.saveAttendanceListToRealm([cloneAttendance])
    }
}

internal final class CustomTextView: UITextView {
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.borderColor = UIColor.gray.cgColor
        layer.borderWidth = 2
        layer.cornerRadius = 5
    }
}
