//
//  ViewController.swift
//  StayHomeBattler
//
//  Created by Riku Yamamoto on 2020/04/25.
//  Copyright © 2020 Riku Yamamoto. All rights reserved.
//

import UIKit
// CoreLocation: location library
import CoreLocation

//
class ViewController: UIViewController, CLLocationManagerDelegate, UITabBarDelegate {
    
    // LocationManager: GPS
    var locationManager: CLLocationManager!
    var latitude: Double! = 0.0
    var longitude: Double! = 0.0
    var radius: Double! = 100.0
    var setNotification: Bool = false
    
    @IBOutlet weak var houseButton: UIButton!
    @IBOutlet weak var DBGField: UITextView!
    
    // UserDefaults: app parameter
    let userDefaults = UserDefaults.standard
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        dbg("\n")
        // Do any additional setup after loading the view.
    }
    
    // request permission
    func setupLocationManager() {
        locationManager = CLLocationManager()
        
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            locationManager.delegate = self
            locationManager.distanceFilter = 10
            locationManager.startUpdatingLocation()
        } else if status == .denied {
            self.alert(title:"位置情報取得が許可されていません", message: "設定アプリから位置情報を許可してください")
            self.showOSSettingView()
        }
        
    }
    
    func getLoationInfo() {
        let status = CLLocationManager.authorizationStatus()
        if status == .denied {
            self.alert(title:"位置情報取得が許可されていません", message: "設定アプリから位置情報を許可してください")
            self.showOSSettingView()
        } else if status == .authorizedWhenInUse {
            userDefaults.set(self.latitude, forKey: "latitude")
            userDefaults.set(self.longitude, forKey: "longitude")
            userDefaults.synchronize()
        }

    }
    
    func alert(title: String, message: String){
        let alert: UIAlertController = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertController.Style.alert
        )
        let defaultAction: UIAlertAction = UIAlertAction(
            title: "OK",
            style: UIAlertAction.Style.default,
            handler: nil
        )
        alert.addAction(defaultAction)
        present(alert, animated:true, completion: nil)
    }
    
    func showOSSettingView(){
        if let url = NSURL(string:UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url as URL)
        }
    }
    
    // location delegate
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        
        self.latitude = latitude
        self.longitude = longitude
    }
    
    // delte all notification
    func deleteAllNotification(){
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        center.removeAllPendingNotificationRequests()
        self.setNotification = false
    }
    
    func showAllNotification(){
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests{
            (requests: [UNNotificationRequest]) in
            for request in requests {
                self.dbg("idnetifier:\(request.identifier)")
                self.dbg("title:\(request.content.title)")
            }
        }
    }
    
    func setHousePoint(latitude: Double, longitude: Double){
        // generate trigger
        let center = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let region = CLCircularRegion(center: center, radius: self.radius, identifier: "House")
        region.notifyOnEntry = false
        region.notifyOnExit = true
        let trigger = UNLocationNotificationTrigger(region: region, repeats: false)
        
        // set request
        let content = generateNotificationContent()
        let request = UNNotificationRequest(identifier: "immediately", content:content, trigger: trigger)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        
        self.setNotification = true
    }
    
    // 外出検知の通知作成
    func generateNotificationContent() -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "外出検知"
        content.body = "外出を検知しました。観念してアプリを起動してください。"
        content.sound = UNNotificationSound.default
        return content
    }
    
    @IBAction func setNotification(_ sender: Any){
        // 位置情報更新
        if setNotification {
            deleteAllNotification()
            print("Delete All Notification")
        }
        
        getLoationInfo()

        let latitude = userDefaults.object(forKey: "latitude") as? Double ?? 0.0
        let longitude = userDefaults.object(forKey: "longitude") as? Double ?? 0.0
        
        if latitude == 0.0 && longitude == 0.0 {
            dbg("[setNotification]現在地取得失敗")
            return
        }
        
        //
        setHousePoint(latitude: latitude, longitude: longitude)
        showAllNotification()
        localPush()
    }
    
    // Notification push sample
    func localPush() {
        let content = UNMutableNotificationContent()
        content.title = "GeoFenceを張りました"
        content.body = "監視を開始しました。家から\(String(Int(radius)))m離れると通知が発生します。"
        content.sound = UNNotificationSound.default
        
        // visible
        let request = UNNotificationRequest(identifier: "immediately", content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
    
    func dbg(_ text: String){
        print(text)
        DispatchQueue.main.async {
            self.DBGField.text += text + "\n"
        }
    }

}

