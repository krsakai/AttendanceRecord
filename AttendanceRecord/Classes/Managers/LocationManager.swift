//
//  LocationManager.swift
//  AttendanceRecord
//
//  Created by 酒井邦也 on 2017/03/04.
//  Copyright © 2017年 酒井邦也. All rights reserved.
//

import Foundation
import CoreLocation

internal final class LocationManager: NSObject {
    
    fileprivate lazy var locationManater: CLLocationManager! = {
        let locationManater = CLLocationManager()
        locationManater.delegate = self
        let status = CLLocationManager.authorizationStatus()
        locationManater.desiredAccuracy = kCLLocationAccuracyBest
        
        // 取得頻度の設定.(1mごとに位置情報取得)
        locationManater.distanceFilter = 1
        
        if(status != CLAuthorizationStatus.authorizedAlways) {
            locationManater.requestAlwaysAuthorization()
        }
        return locationManater
    }()
    
    fileprivate lazy var beaconRegion: CLBeaconRegion! = {
        let beaconRegion = DeviceModel.beaconRegion
        beaconRegion.notifyEntryStateOnDisplay = false
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        return beaconRegion
    }()
    
    static let shard = LocationManager()
}

extension LocationManager: CLLocationManagerDelegate {
    
    func start() {
        
        locationManater.startMonitoring(for: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch (status) {
        case .notDetermined:
            fallthrough
        case .restricted:
            fallthrough
        case .denied:
            fallthrough
        case .authorizedAlways:
            fallthrough
        case .authorizedWhenInUse:
            break
        }
        manager.startMonitoring(for: beaconRegion)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        manager.requestState(for: region);
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        
        switch (state) {
        case .inside:
            manager.startRangingBeacons(in: region as! CLBeaconRegion)
        case .outside, .unknown:
            break
        }
    }
    
    /*
     STEP6(Delegate): ビーコンがリージョン内に入り、その中のビーコンをNSArrayで渡される.
     */
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        

        if(beacons.count > 0){
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        manager.startRangingBeacons(in: region as! CLBeaconRegion)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        manager.stopRangingBeacons(in: region as! CLBeaconRegion)
    }
    
}
