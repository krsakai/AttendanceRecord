//
//  AppDelegate.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/25.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import DrawerController
import GoogleMobileAds
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        setupMasterData()
        window?.rootViewController = instantiateRootViewController
        GADMobileAds.configure(withApplicationID: "ca-app-pub-7419271952519725~6218919453")
        FirebaseApp.configure()
        return true
    }
}

extension AppDelegate {
    
    fileprivate func setupMasterData() {
        if !DeviceModel.isFirstReadMasterData {
            let eventListData = FilesManager.list(fileName: FilePath.FileName.event, fileType: FilePath.FileType.csv, resourceType: .bundle)
            let memberListData = FilesManager.list(fileName: FilePath.FileName.member, fileType: FilePath.FileType.csv, resourceType: .bundle)
            
            guard let eventList = eventListData , let memberList = memberListData else {
                NSLog("ファイルがありません")
                return
            }
            
            FilesManager.save(fileName: FilePath.sampleFileEvent, dataList: eventList)
            FilesManager.save(fileName: FilePath.sampleFileMember, dataList: memberList)
        }
    }
}

extension AppDelegate {
    
    static var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    static var drawer: DrawerController? {
        return AppDelegate.shared.window?.rootViewController as? DrawerController
    }
    
    static var navigation: UINavigationController? {
        return drawer?.centerViewController as? UINavigationController
    }
    
    static var sideMenu: SideMenuViewController? {
        return drawer?.leftDrawerViewController as? SideMenuViewController
    }
    
    static func reloadScreen() {
        AppDelegate.sideMenu?.reloadScreen()
        
        if let viewController = AppDelegate.navigation?.topViewController as? ScreenReloadable {
            viewController.reloadScreen()
        }
        
        if let viewController = UIApplication.topViewController() as? ScreenReloadable {
            viewController.reloadScreen()
        }
    }
}

extension AppDelegate {
    
    private static let showShadows = false
    private static let animationVelocity = CGFloat(550.0)
    private static let maximumLeftDrawerWidth = CGFloat(250.0)
    
    /// メイン画面のコントローラー生成
    fileprivate var instantiateRootViewController: DrawerController {
        
        let mainNaivigationController = R.storyboard.main.instantiateInitialViewController()!
        let drawerController = DrawerController(centerViewController: mainNaivigationController,
                                                leftDrawerViewController: SideMenuViewController.instantiate(),
                                                rightDrawerViewController: nil)
        drawerController.showsShadows = AppDelegate.showShadows
        drawerController.animationVelocity = AppDelegate.animationVelocity
        drawerController.maximumLeftDrawerWidth = AppDelegate.maximumLeftDrawerWidth
        drawerController.closeDrawerGestureModeMask = [.bezelPanningCenterView, .tapNavigationBar, .tapCenterView]
        
        let blurView = UIView(frame: UIScreen.main.bounds)
        blurView.backgroundColor = .black
        blurView.alpha = 0.2
        drawerController.drawerVisualStateBlock = { _, _, percentVisible in
            if percentVisible > 0 && blurView.superview == nil {
                drawerController.centerViewController?.view.addSubview(blurView)
            } else if percentVisible == 0 {
                blurView.removeFromSuperview()
            }
        }
        return drawerController
    }
}

extension UIApplication {
    class func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let base = base ?? UIApplication.shared.keyWindow?.rootViewController
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
}

internal protocol LayoutUpdable {
    func refreshLayout()
}

extension LayoutUpdable where Self: UIView {
    func refreshLayout() {}
}

internal protocol ScreenReloadable {
    func reloadScreen()
}

extension ScreenReloadable where Self: UIViewController {
    func reloadScreen() {}
}
