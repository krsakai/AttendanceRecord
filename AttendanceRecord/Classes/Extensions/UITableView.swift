//
//  UITableView.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2018/02/08.
//  Copyright © 2018年 酒井邦也. All rights reserved.
//

import UIKit

protocol Registrable: class {
    static var reuseIdentifier: String { get }
}

extension Registrable {
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}

protocol ClassRegistrable: Registrable { }

protocol NibRegistrable: Registrable {
    static var nib: UINib { get }
}

extension NibRegistrable {
    static var nib: UINib {
        let nibName = String(describing: self)
        return UINib(nibName: nibName, bundle: Bundle(for: self))
    }
}

extension UITableView {
    func register<T: Registrable>(_ registrableType: T.Type) where T: UITableViewCell {
        switch registrableType {
        case let nibRegistrableType as NibRegistrable.Type:
            register(nibRegistrableType.nib, forCellReuseIdentifier: nibRegistrableType.reuseIdentifier)
        case let classRegistrableType as ClassRegistrable.Type:
            register(classRegistrableType, forCellReuseIdentifier: classRegistrableType.reuseIdentifier)
        default:
            assertionFailure("\(registrableType) is unknown type")
        }
    }
    
    func dequeueReusableCell<T: Registrable>(for indexPath: IndexPath) -> T where T: UITableViewCell {
        guard let cell = dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as? T else {
            fatalError("Could not dequeue cell with type \(T.self)")
        }
        return cell
    }
}

