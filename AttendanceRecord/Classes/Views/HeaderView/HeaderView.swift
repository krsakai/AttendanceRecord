//
//  HeaderView.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/25.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import SnapKit

internal protocol HeaderButtonModel {
    var headerTitle: String  { get }
}

/// ヘッダービュー表示適合用
internal protocol HeaderViewDisplayable {
    
    var headerView: HeaderView! { get }
    
    func setupHeaderView(_ title: String, buttonTypes: [[HeaderView.ButtonType]]?)
    
    func refreshHeaderView(enabled: Bool, buttonTypes: [[HeaderView.ButtonType]]?)
    
}

extension HeaderViewDisplayable {
    
    func setupHeaderView(_ title: String, buttonTypes: [[HeaderView.ButtonType]]? = nil) {
        
        headerView.title.text = title
        headerView.buttonTypes = buttonTypes
        
        guard let buttonTypes = buttonTypes else { return }
        
        // MARK: - refactor
        guard buttonTypes.count == 2 else { return }
        
        buttonTypes[0].forEach { buttonType in
            let buttonView = HeaderButtonView.instantiate(owner: self as AnyObject, buttonType: buttonType)
            headerView.leftStackView.addArrangedSubview(buttonView)
            buttonView.snp.makeConstraints { make in
                make.width.equalTo(40)
            }
            headerView.buttons.append(buttonView)
        }
        
        buttonTypes[1].forEach { buttonType in
            let buttonView = HeaderButtonView.instantiate(owner: self as AnyObject, buttonType: buttonType)
            headerView.rightStackView.addArrangedSubview(buttonView)
            buttonView.snp.makeConstraints { make in
                make.width.equalTo(40)
            }
            headerView.buttons.append(buttonView)
        }
    }
    
    func refreshHeaderView(enabled: Bool, buttonTypes: [[HeaderView.ButtonType]]?) {
        
        guard let buttonTypes = buttonTypes else { return }
        
        // MARK: - refactor
        guard buttonTypes.count == 2 else { return }
        
        buttonTypes.forEach { oneSideTypes in
            oneSideTypes.forEach { buttonType in
                _ = self.headerView.buttons.filter { headerView in
                    if buttonType.actionKey == headerView.buttonType.actionKey  {
                        headerView.headerButton.isEnabled = enabled
                    }
                    return true
                }
            }
        }
    }
}

/// ヘッダービュー
internal final class HeaderView: UIView {
    
    typealias Action = (() -> Void)?
    typealias SelectionAction = ((UIView) -> Void)?
    
    /// ボタン種別
    enum ButtonType {
        case sideMenu                               // サイドメニュー
        case close(HeaderModel?)                    // 閉じる
        case back                                   // 戻る
        case add(HeaderModel?)                      // 追加
        case regist(HeaderModel?)                   // 登録
        case delete(HeaderModel?)                   // 削除
        case reception(HeaderModel?)                // 受付
        case request(HeaderModel?)                  // リクエスト
        case selection(HeaderModel?)                // 選択
        case send(HeaderModel?)                     // 送る
        case bulk(HeaderModel?)                     // 一括
        
        var image: UIImage? {
            switch self {
            case .sideMenu: return R.image.universalGeneralSideMenuBarButton()
            case .close: return R.image.universalGeneralCloseButton()
            case .back: return R.image.universalGeneralLeftArrowWhite()
            default: return nil
            }
        }
        
        var selectedImage: UIImage? {
            switch self {
            case .sideMenu: return R.image.universalGeneralSideMenuBarButton_Selected()
            case .close: return R.image.universalGeneralCloseButton_Selected()
            case .back: return R.image.universalGeneralLeftArrowWhite_Selected()
            default:  return nil
            }
        }
        
        var title: String? {
            switch self {
            case .add   : return R.string.localizable.commonLabelPlus()
            case .delete: return R.string.localizable.commonLabelMinus()
            case .regist: return R.string.localizable.headerButtonLabelUserRegist()
            case .reception: return R.string.localizable.headerButtonLabelReception()
            case .request: return R.string.localizable.headerButtonLabelRequest()
            case .selection: return  R.string.localizable.headerButtonLabelSelection()
            case .send: return R.string.localizable.headerButtonLabelSend()
            case .bulk: return R.string.localizable.headerButtonLabelBuld()
            default: return nil
            }
        }
        
        var titleFont: UIFont {
            switch self {
            case .regist, .reception, .request, .selection, .send, .bulk:
                return AttendanceRecordFont.HeaderButton.regist
            default: return AttendanceRecordFont.HeaderButton.add
            }
        }
        
        var tintColor: UIColor {
            return AttendanceRecordColor.HeaderButton.add
        }
        
        var actionKey: String {
            switch self {
            case .sideMenu:     return "SideMenu"
            case .close:        return "Close"
            case .back:         return "Back"
            case .add:          return "Add"
            case .regist:       return "Regist"
            case .delete:       return "Delete"
            default: return ""
            }
        }
        
        func buttonAction(targetView: UIView) -> (() -> Void)? {
            switch self {
            case .sideMenu:
                return { _ in
                    AppDelegate.navigation?.evo_drawerController?.toggleDrawerSide(.left, animated: true, completion: nil)
                }
            case .back:
                return { _ in
                    _ = AppDelegate.navigation?.popViewController(animated: true)
                }
            case .delete(let model):
                return { _ in
                    AlertController.showAlert(title: R.string.localizable.alertTitleDeleteComfirm(), message: R.string.localizable.alertMessageDelete(model?.displayInfo ?? ""), positiveAction: { _ in
                        model?.action?()
                        _ = AppDelegate.navigation?.popViewController(animated: true)
                    })
                }
            case .regist(let model):
                return { _ in
                    AlertController.showAlert(title: R.string.localizable.alertTitleMemberRegistComfirm(),
                                              message: R.string.localizable.alertMessageAdd(), positiveAction: {
                        model?.action?()
                        UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
                    })
                }
            case .add(let model):
                return { _ in
                    let viewController = EntryViewController.instantiate(entryModel: model?.entryModel ?? EntryModel())
                    UIApplication.topViewController()?.present(viewController, animated: true, completion: nil)
                    model?.action?()
                }
            case .close(let model):
                return { _ in
                    model?.action?()
                    UIApplication.topViewController()?.dismiss(animated: true, completion: nil)
                }
            case .reception(let model):
                return { _ in
                    model?.action?()
                }
            case .request(let model):
                return { _ in
                    model?.action?()
                }
            case .selection(let model):
                return { _ in
                    model?.selectionAction?(targetView)
                    model?.action?()
                }
            case .send(let model):
                return { _ in
                    model?.action?()
                }
            case .bulk(let model):
                return { _ in
                    model?.action?()
                }
            }
        }
    }

    // ボタン種別ｓ
    fileprivate var buttonTypes: [[ButtonType]]?
    fileprivate var buttons: [HeaderButtonView] = []
    
    // MARK: IBOutlet

    @IBOutlet fileprivate weak var leftStackView: UIStackView!
    @IBOutlet fileprivate weak var rightStackView: UIStackView!
    @IBOutlet fileprivate weak var title: UILabel!
    
    fileprivate var contentView: UIView!
    
    // MARK: - Initializer
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        contentView = R.nib.headerView.firstView(owner: self, options: nil)!
        addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.right.left.bottom.top.equalTo(0)
        }
        contentView.backgroundColor = DeviceModel.themeColor.color
    }
}

extension HeaderView: LayoutUpdable {
    func refreshLayout() {
        contentView.backgroundColor = DeviceModel.themeColor.color
    }
}
