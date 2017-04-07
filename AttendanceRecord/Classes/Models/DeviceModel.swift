//
//  DeviceModel.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/02/25.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import UIKit
import CoreLocation
import CoreBluetooth
import KeychainAccess

internal enum ThemeColor: Int {
    case red    = 1
    case green  = 2
    case blue   = 3
    case water  = 4
    
    var title: String {
        switch self {
        case .red:   return "赤"
        case .green: return "緑"
        case .blue:  return "青"
        case .water: return "水色"
        }
    }
    
    var color: UIColor {
        switch self {
        case .red: return AttendanceRecordColor.Common.red
        case .green: return AttendanceRecordColor.Common.green
        case .blue: return AttendanceRecordColor.Common.blue
        case .water: return AttendanceRecordColor.Common.water
        }
    }
}


internal final class DeviceModel {

    static let sharedModel = DeviceModel()
    
    static let proximityUUID = UUID(uuidString: "ADAEE580-9167-46C7-B6C4-E9AB299A62DD")!
    
    static let beaconIdentifier = "attendance"
    
    static let beaconValue = (major: CLBeaconMajorValue(1), minor: CLBeaconMajorValue(1))
    
    static let beaconRegion = CLBeaconRegion(proximityUUID: proximityUUID, major: beaconValue.major,
                                             minor: beaconValue.minor, identifier: beaconIdentifier)
    
    static let advertisementData = NSDictionary(dictionary: beaconRegion.peripheralData(withMeasuredPower: nil)) as? [String : Any]
    
    static var serviceUUID = CBUUID(string: "022DD1C2-E416-4703-8CA7-1E67E33FF30A")
    
    static var characteristicUUID = CBUUID(string: "F3D31BE0-EAD5-48AB-9E4B-F0D60047A476")
    
    /// NSUserDefaultsのアクセスで使用するキー
    private enum UserDefaultsKey: String {
        case isFirstReadMasterData   = "IsFirstReadMasterData"
        case mode                    = "Mode"
        case serviceUUID             = "ServiceUUID"
        case characteristicUUID      = "CharacteristicUUID"
        case themeColor              = "ThemeColor"
        case isRequireMemberName     = "IsRequireMemberName"
        case isRequireMemberEmail    = "IsRequireMemberEmail"
        case mailAddress             = "MailAddress"
    }
    
    static var isFirstReadMasterData: Bool {
        if UserDefaults.standard.bool(forKey: UserDefaultsKey.isFirstReadMasterData.rawValue) {
            return true
        } else {
            UserDefaults.standard.set(true, forKey: UserDefaultsKey.isFirstReadMasterData.rawValue)
            return false
        }
    }
    
    static var mode: Mode {
        get {
            return Mode.organizer
//            return Mode(rawValue: UserDefaults.standard.integer(forKey: UserDefaultsKey.mode.rawValue)) ??  Mode.member
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaultsKey.mode.rawValue)
        }
    }
    
    static var themeColor: ThemeColor {
        get {
            return ThemeColor(rawValue: UserDefaults.standard.integer(forKey: UserDefaultsKey.themeColor.rawValue)) ??  ThemeColor.blue
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: UserDefaultsKey.themeColor.rawValue)
        }
    }
    
    static var isRequireMemberName: Bool {
        get {
            return  UserDefaults.standard.bool(forKey: UserDefaultsKey.isRequireMemberName.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.isRequireMemberName.rawValue)
        }
    }
    
    static var isRequireEmail: Bool {
        get {
            return  UserDefaults.standard.bool(forKey: UserDefaultsKey.isRequireMemberEmail.rawValue)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.isRequireMemberEmail.rawValue)
        }
    }
    
    static var mailAddress: String {
        get {
            return  UserDefaults.standard.string(forKey: UserDefaultsKey.mailAddress.rawValue) ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: UserDefaultsKey.mailAddress.rawValue)
        }
    }
    
    /// KeyChainのアクセスで使用するキー
    enum KeychainKey: String {
        case MemberId       = "MemberId"
        case MemberNameJp   = "MemberNameJp"
        case MemberNameKana = "MemberNameKana"
        case MemberEmail    = "MemberEmail"
    }
    
    // MARK: KeyChain Prame
    
    static var memberId: String {
        let keychain = Keychain()
        let key = KeychainKey.MemberId.rawValue
        if let memberId = keychain[string: key] {
            return memberId
        }
        let memberId = UUID().uuidString.replacingOccurrences(of: "-", with: "")
        keychain[string: key] = memberId
        return memberId
    }

    static var memberNameJp: String {
        get {
            return Keychain()[string: KeychainKey.MemberNameJp.rawValue] ?? ""
        }
        set {
            Keychain()[string: KeychainKey.MemberNameJp.rawValue] = newValue
        }
    }
    
    static var memberNameKana: String {
        get {
            return Keychain()[string: KeychainKey.MemberNameKana.rawValue] ?? ""
        }
        set {
            Keychain()[string: KeychainKey.MemberNameKana.rawValue] = newValue
        }
    }
    
    static var memberEmail: String {
        get {
            return Keychain()[string: KeychainKey.MemberEmail.rawValue] ?? ""
        }
        set {
            Keychain()[string: KeychainKey.MemberEmail.rawValue] = newValue
        }
    }
    
    static var currentMember: Member? {
        let memberInfoList = [memberNameJp, memberNameKana, memberEmail]
        guard let _ = (memberInfoList.filter { $0 == "" }.first) else {
            return Member(memberId: memberId, nameJp: memberNameJp, nameKana: memberNameKana, email: memberEmail, memberType: MemberType.normal)
        }
        return nil
    }
    
    static func setCurrentMember(member: Member) {
        memberNameJp = member.nameJp
        memberNameKana = member.nameKana
        memberEmail = member.email
    }
    
    static func removeKeychainAll() {
        try! Keychain().removeAll()
    }
}
