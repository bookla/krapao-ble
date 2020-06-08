//
//  MainViewController.swift
//  Krapao Tracker
//
//  Created by Book Lailert on 22/10/18.
//  Copyright © 2018 Book Lailert. All rights reserved.
//

import UIKit
import CoreBluetooth
import UserNotifications
import CoreLocation
import MapKit
import Photos

class MainViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate {
    
    var centralManager: CBCentralManager?
    var BLEService = ""
    var bagTracker:CBPeripheral?
    let BLEChar = CBUUID(string: "0x2A3D")
    var locationManager = CLLocationManager()
    var connected = false
    var saveLocation = false
    var firstUpdate = true
    var backgroundLocationUpdateTimer = Timer()
    let imagePicker = UIImagePickerController()
    var playingSound = false
    var unpair = false
    var RSSIlist = [Int]()
    
    
    
    
    
    
    
    
    
    //SET UP     SET UP     SET UP     SET UP
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLocation()
        startLocationUpdate()
        setupBluetooth()
        
        // Do any additional setup after loading the view.
    }
    
    
    func setupUI() {
        loadImage()
        distanceDisplay.isHidden = false
        signalProgress.transform = signalProgress.transform.scaledBy(x: 1, y: 15)
        bagPicture.imageView?.contentMode = .scaleAspectFit
        imagePicker.delegate = self
        settingsView.isHidden = true
        centerPosition.layer.cornerRadius = 10
        Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (nil) in
            self.checkStatusText()
        }
    }
    
    func setupBluetooth() {
        BLEService = UserDefaults().string(forKey: "deviceUUID")!
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.Book-Lailert.centralQueueName", attributes: .concurrent)
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
    }
    
    func setupLocation() {
        locationManager.delegate = self
        initializeLocation()
        mapView.showsUserLocation = true
    }
    
    
    
    
    //SET UP     SET UP     SET UP     SET UP
    
    
    
    
    
    
    
    
    
    //OUTLETS     OUTLETS     OUTLETS    OUTLETS
    
    
    
    
    @IBOutlet var signalProgress: UIProgressView!
    @IBOutlet var status: UINavigationItem!
    @IBOutlet var RSSIText: UILabel!
    @IBOutlet var trackerName: UIButton!
    @IBOutlet var bagPicture: UIButton!
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var soundStatus: UIButton!
    @IBOutlet var settingsButton: UIButton!
    @IBOutlet var centerPosition: UIView!
    @IBOutlet var settingsView: UIView!
    
    
    
    
    
    //OUTLETS     OUTLETS     OUTLETS    OUTLETS
    
    
    
    
    
    
    //LOCATION     LOCATION     LOCATION     LOCATION
    
    
    
    
    
    
    
    func initializeLocation() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways {
            locationManager.allowsBackgroundLocationUpdates = true
            locationManager.pausesLocationUpdatesAutomatically = false
            locationManager.startMonitoringSignificantLocationChanges()
        } else {
            locationManager.requestAlwaysAuthorization()
        }
    }
    
    
    
    
    
    
    func handleMap() {
        let mapMode = UserDefaults().integer(forKey: "mapMode")
        if mapMode == 1 {
            mapView.mapType = MKMapType.satellite
        } else {
            mapView.mapType = MKMapType.standard
        }
        mapView.showsUserLocation = true
        if !connected {
            if let latitude = UserDefaults().string(forKey: "lastLat") {
                if let longitude = UserDefaults().string(forKey: "lastLong") {
                    let annotation = MKPointAnnotation()
                    let noLocation = CLLocationCoordinate2D(latitude: CLLocationDegrees(Double(latitude)!), longitude: CLLocationDegrees(Double(longitude)!))
                    print(noLocation)
                    annotation.coordinate = noLocation
                    annotation.title = "Last seen location"
                    let viewRegion = MKCoordinateRegion(center: noLocation, latitudinalMeters: 200, longitudinalMeters: 200)
                    mapView.addAnnotation(annotation)
                    mapView.setRegion(viewRegion, animated: false)
                }
            }
        } else {
            DispatchQueue.main.async {
                self.mapView.removeAnnotations(self.mapView.annotations)
            }
        }
    }
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if !(centralManager?.isScanning)! && !connected {
            centralManager?.scanForPeripherals(withServices: [CBUUID(string: BLEService)], options: nil)
        }
        if saveLocation {
            UserDefaults().set(String(describing: locations.last!.coordinate.latitude), forKey: "lastLat")
            UserDefaults().set(String(describing: locations.last!.coordinate.longitude), forKey: "lastLong")
            saveLocation = false
            locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
            handleMap()
        }
        if connected && firstUpdate {
            let noLocation = locations.last?.coordinate
            let viewRegion = MKCoordinateRegion(center: noLocation!, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: false)
            firstUpdate = false
            locationManager.stopUpdatingLocation()
        }
    }
    
    
    func startLocationUpdate() {
        updateLocation()
    }
    
    
    func updateLocation() {
        backgroundLocationUpdateTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { (nil) in
            self.locationManager.startUpdatingLocation()
            self.locationManager.stopUpdatingLocation()
        }
    }
    
    @objc func stopLocationUpdate() {
        if backgroundLocationUpdateTimer.isValid{
            backgroundLocationUpdateTimer.invalidate()
        }
        self.centralManager?.scanForPeripherals(withServices: [CBUUID(string: self.BLEService)])
    }
    
    @IBAction func centerCurrentLocation(_ sender: Any) {
        if let userLocation = locationManager.location?.coordinate {
            let viewRegion = MKCoordinateRegion(center: userLocation, latitudinalMeters: 200, longitudinalMeters: 200)
            mapView.setRegion(viewRegion, animated: true)
        }
    }
    
    
    
    
    
    
//LOCATION     LOCATION     LOCATION     LOCATION
    
    
    
    
    
    
    
    
    
    
    
    
// Image Picker     Image Picker     Image Picker
    
    
    
    
    
    
    
    
    func imageFromCamera() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .camera
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imageFromCameraRoll() {
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .photoLibrary
        
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    func loadImage() {
        if let image = getSavedImage(named: "bagimage") {
            bagPicture.imageView?.contentMode = .scaleAspectFit
            bagPicture.setImage(image, for: .normal)
        }
    }
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            bagPicture.imageView?.contentMode = .scaleAspectFit
            bagPicture.setImage(pickedImage, for: .normal)
            
            if saveImage(image: pickedImage) {
                print("Saved succesfully")
            } else {
                print("Unable to save image")
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    
    func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
            self.showOption()
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    /* do stuff here */
                    print("success")
                    self.showOption()
                }
            })
            print("It is not determined until now")
        case .restricted:
            // same same
            print("User do not have access to photo album.")
        case .denied:
            // same same
            print("User has denied the permission.")
        }
    }
    
    func saveImage(image: UIImage) -> Bool {
        guard let data = image.jpegData(compressionQuality: 1.0) ?? image.pngData() else {
            return false
        }
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) as NSURL else {
            return false
        }
        do {
            try data.write(to: directory.appendingPathComponent("bagimage.png")!)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    func getSavedImage(named: String) -> UIImage? {
        if let dir = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false) {
            return UIImage(contentsOfFile: URL(fileURLWithPath: dir.absoluteString).appendingPathComponent(named).path)
        }
        return nil
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    func showOption() {
        let alert = UIAlertController(title: "Change tracker image", message: "", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Camera", style: .default , handler:{ (UIAlertAction)in
            self.imageFromCamera()
        }))
        
        alert.addAction(UIAlertAction(title: "Camera Roll", style: .default , handler:{ (UIAlertAction)in
            self.imageFromCameraRoll()
        }))
        
        alert.addAction(UIAlertAction(title: "Reset to Default", style: .default , handler:{ (UIAlertAction)in
            
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(alert, animated: true, completion: {
            print("completion block")
        })
    }
    
    
    @IBAction func changeImage(_ sender: Any) {
        checkPermission()
    }
    
    
    
    
    
    
    // Image Picker     Image Picker     Image Picker
    
    
    
    
    
    
    
    
    
    // Change Name     Change Name     Change Name
    
    
    
    
    
    
    
    @IBAction func nameChange(_ sender: Any) {
        let alert = UIAlertController(title: "Rename tracker", message: "Enter new name", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.text = UserDefaults().string(forKey: "deviceName")!
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert!.textFields![0]
            UserDefaults().set(textField.text, forKey: "deviceName")
            self.trackerName.setTitle(textField.text, for: .normal)
        }))

        self.present(alert, animated: true, completion: nil)
    }
    

    
    
    
    
    // Change Name     Change Name     Change Name
    
    
    
    
    
    
    
    // Play Sound     Play Sound     Play Sound
    
    
    
    
    
    @IBAction func playSoundNow(_ sender: Any) {
        if !playingSound {
            let messageText = "Play Sound"
            let data = messageText.data(using: .utf8)
            playingSound = true
            soundStatus.setTitleColor(UIColor.gray, for: .normal)
            soundStatus.setTitle("Requested Sound", for: .normal)
            self.bagTracker!.writeValue(data!, for: (self.bagTracker?.services?.first?.characteristics?.first)!, type: CBCharacteristicWriteType.withoutResponse)
            var count = 0
            if connected {
                Timer.scheduledTimer(withTimeInterval: 10, repeats: true) { (myTimer) in
                    count += 1
                    if !self.playingSound {
                        myTimer.invalidate()
                    }
                    if count > 3 {
                        self.alertUser(title: "Play Sound Failed", subtitle: "Please try again later.", options: ["OK" : UIAlertAction.Style.cancel])
                        self.soundStatus.setTitleColor(self.view.tintColor, for: .normal)
                        self.soundStatus.setTitle("Play Sound", for: .normal)
                        myTimer.invalidate()
                    }
                    
                    self.bagTracker!.writeValue(data!, for: (self.bagTracker?.services?.first?.characteristics?.first)!, type: CBCharacteristicWriteType.withoutResponse)
                }
            }
        } else {
            soundStatus.setTitleColor(view.tintColor, for: .normal)
            soundStatus.setTitle("Play Sound", for: .normal)
        }
    }
    
    
    
    
    
    
    // Play Sound     Play Sound     Play Sound
    
    
    
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        status.title = "Searching..."
        self.soundStatus.setTitleColor(UIColor.gray, for: .normal)
        self.soundStatus.isEnabled = false
        handleMap()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        trackerName.setTitle(UserDefaults().string(forKey: "deviceName")!, for: .normal)
        print(BLEService)
        checkBluetoothStatus(central: centralManager!) { (state) in
            if state {
                self.centralManager?.scanForPeripherals(withServices: [CBUUID(string: BLEService)])
            } else {
                self.status.title = "Bluetooth Unavailable"
            }
        }
        
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    
    
    //BLUETOOTH     BLUETOOTH     BLUETOOTH
    
    
    @IBAction func retry(_ sender: Any) {
        checkBluetoothStatus(central: centralManager!) { (state) in
            if state {
                if (self.centralManager?.isScanning)! {
                    self.centralManager?.stopScan()
                    self.status.title = "Disconnected"
                    Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (nil) in
                        (self.centralManager?.scanForPeripherals(withServices: [CBUUID(string: self.BLEService)], options: nil))!
                        self.status.title = "Searching...."
                    }
                } else if !connected {
                    (self.centralManager?.scanForPeripherals(withServices: [CBUUID(string: self.BLEService)], options: nil))!
                    self.status.title = "Searching...."
                } else if connected {
                    self.centralManager?.cancelPeripheralConnection(self.bagTracker!)
                    self.status.title = "Searching...."
                    (self.centralManager?.scanForPeripherals(withServices: [CBUUID(string: self.BLEService)], options: nil))!
                    
                }
            } else {
                self.alertUser(title: "Bluetooth Not Available!", subtitle: "Please turn on Bluetooth to proceed", options: ["OK" : UIAlertAction.Style.cancel])
            }
        }
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        DispatchQueue.main.async {
            self.status.title = "Connecting..."
        }
        if UserDefaults().bool(forKey: "devicePaired") {
            print(peripheral)
            bagTracker = peripheral
            bagTracker?.delegate = self
            centralManager?.stopScan()
            centralManager?.connect(self.bagTracker!)
        }
    }
    
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connected = true
        DispatchQueue.main.async {
            self.soundStatus.setTitleColor(self.view.tintColor, for: .normal)
            self.soundStatus.isEnabled = true
            self.status.title = "Connected"
            Timer.scheduledTimer(withTimeInterval: 2, repeats: true) { (nil) in
                if self.connected {
                    peripheral.readRSSI()
                    DispatchQueue.main.async {
                        self.checkStatusText()
                    }
                }
            }
        }
        handleMap()
        self.notifyUser(titleText: "Tracker Connected", bodyText: "Tracker is now in range")
        peripheral.discoverServices([CBUUID(string: self.BLEService)])
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        peripheral.discoverCharacteristics([BLEChar], for: (peripheral.services?.first)!)
        bagTracker = peripheral
        bagTracker?.delegate = self
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if playingSound && error == nil{
            guard characteristic.value != nil else {
                return
            }
            let dataString = String(data: characteristic.value!, encoding: String.Encoding.ascii)
            if dataString!.range(of: "Playing sound") != nil {
                print("Sound Playing")
                DispatchQueue.main.async {
                    self.soundStatus.setTitle("Sound Playing", for: .normal)
                    self.soundStatus.setTitleColor(UIColor.black, for: .normal)
                    self.soundStatus.isEnabled = false
                }
                playingSound = false
            }
        } else if error == nil{
            guard characteristic.value != nil else {
                return
            }
            let dataString = String(data: characteristic.value!, encoding: String.Encoding.ascii)
            if dataString == "Play Sound successfu" {
                print("Played Sound")
                DispatchQueue.main.async {
                    self.soundStatus.setTitle("Play Sound", for: .normal)
                    self.soundStatus.setTitleColor(self.view.tintColor, for: .normal)
                    self.soundStatus.isEnabled = true
                }
            }
        } else {
            print(error as Any)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print(service.characteristics as Any)
        if let e = error {
            print(e)
        } else {
            bagTracker = peripheral
            bagTracker?.delegate = self
            peripheral.setNotifyValue(true, for: (service.characteristics?.first)!)
        }
    }
    
    
    func levelFromRSSI(RSSI:NSNumber) -> Float {
        var level = Float(truncating: RSSI) + Float(35)
        level = level/100
        level = level * -1
        level = 1 - (Float(level) * 1.1)
        return level
    }
    
    

    
    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        checkBluetoothStatus(central: centralManager!) { (state) in
            if state && error == nil {
                RSSIlist.append(Int(truncating: RSSI))
                var myRSSI = 0
                if RSSIlist.count == 10 {
                    myRSSI = Int(truncating: NSNumber(integerLiteral: Int(RSSIlist.average)))
                    RSSIlist.removeFirst()
                }
                DispatchQueue.main.async {
                    let distance:Double = Double(truncating: myRSSI.calculateDistance())
                    if myRSSI != 0 {
                        if distance < 1 || distance.isNaN {
                            self.distanceDisplay.text = "Distance : <1 m"
                        } else {
                            self.distanceDisplay.text = "Distance : " + String(describing: distance) + "m"
                        }
                        self.RSSIText.text = "Signal Strength : " + String(describing: myRSSI) + "dB"
                    } else {
                        self.RSSIText.text = "Signal Strength : Measuring..."
                        self.distanceDisplay.text = "Distance : Calculating..."
                    }
                    self.signalProgress.progress = self.levelFromRSSI(RSSI: NSNumber(integerLiteral: myRSSI))
                }
            } else {
                print(error as Any)
                self.alertUser(title: "Bluetooth Not Available!", subtitle: "Please turn on Bluetooth to proceed", options: ["OK" : UIAlertAction.Style.cancel])
            }
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if !unpair {
            handleDisconnection(bluetoothActive: true)
        } else {
            unpair = false
        }
    }
    
    
    func handleDisconnection(bluetoothActive: Bool) {
        connected = false
        DispatchQueue.main.async {
            self.signalProgress.progress = 0.0
            if bluetoothActive {
                self.status.title = "Disconnected"
            } else {
                self.status.title = "Bluetooth Unavailable"
                self.alertUser(title: "Bluetooth Not Available!", subtitle: "Please turn on Bluetooth to stay connected to the tracker!", options: ["OK" : UIAlertAction.Style.cancel])
            }
            self.RSSIText.text = "Signal Strength: N/A"
            self.distanceDisplay.text = "Distance: N/A"
        }
        if bluetoothActive {
            self.notifyUser(titleText: "Tracker Disconnected", bodyText: "Tracker is now out of range")
        }
        saveLocation = true
        locationManager.startUpdatingLocation()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.centralManager?.scanForPeripherals(withServices: [CBUUID(string: self.BLEService)])
    }
    
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        checkBluetoothStatus(central: central) { (status2) in
            if status2 {
                print("Bluetooth ON")
                if !central.isScanning {
                    self.status.title = "Searching..."
                    self.centralManager?.scanForPeripherals(withServices: [CBUUID(string: BLEService)])
                }
            } else {
                print("Bluetooth OFF")
                handleDisconnection(bluetoothActive: false)
                self.status.title = "Bluetooth Unavailable"
                if connected {
                    notifyUser(titleText: "Bluetooth turned off", bodyText: "Turn on Bluetooth to be notified when the device goes out of range!")
                } else {
                    notifyUser(titleText: "Bluetooth turned off", bodyText: "Turn on Bluetooth to be notified when the device comes in range!")
                }
            }
        }
        
    }
    
    @IBOutlet var distanceDisplay: UILabel!
    
    func checkBluetoothStatus(central: CBCentralManager, completion: (Bool) -> ()) {
        switch central.state {
            
        case .unknown:
            print("Bluetooth status is UNKNOWN")
            completion(false)
        case .resetting:
            print("Bluetooth status is RESETTING")
            completion(false)
        case .unsupported:
            print("Bluetooth status is UNSUPPORTED")
            completion(false)
        case .unauthorized:
            print("Bluetooth status is UNAUTHORIZED")
            completion(false)
        case .poweredOff:
            print("Bluetooth status is POWERED OFF")
            completion(false)
        case .poweredOn:
            print("Bluetooth status is POWERED ON")
            completion(true)
        }
    }
    
    
    
    
    
    
    
    //BLUETOOTH     BLUETOOTH     BLUETOOTH
    
    
    
    
    
    
    
    //USER NOTIFICATION      USER NOTIFICATION
    
    
    
    
    
    
    
    func notifyUser(titleText: String, bodyText: String) {
        let notificationOn = UserDefaults().bool(forKey: "notification")
        if notificationOn {
            let content = UNMutableNotificationContent()
            content.title = titleText
            content.body = bodyText
            content.sound = UNNotificationSound.default
            var dateComponents = DateComponents()
            dateComponents.calendar = Calendar.current
            let date = Date()
            let calendar = Calendar.current
            if calendar.component(.second, from: date) + 10 >= 60 {
                dateComponents.hour = calendar.component(.hour, from: date)
                dateComponents.minute = calendar.component(.minute, from: date) + 1
                dateComponents.second = 4
            } else {
                dateComponents.hour = calendar.component(.hour, from: date)
                dateComponents.minute = calendar.component(.minute, from: date)
                dateComponents.second = calendar.component(.second, from: date) + 4
            }
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
            print(dateComponents)
            let notificationCenter = UNUserNotificationCenter.current()
            notificationCenter.add(request) { (error) in
                if error != nil {
                    print(error as Any)
                }
            }
        }
    }
    
    
    
    
    
    
    
    //USER NOTIFICATION      USER NOTIFICATION
    
    
    
    
    
    
    
    
    //UNPAIR     UNPAIR     UNPAIR    UNPAIR   UNPAIR
    
    
    
    
    
    
    func unpairStart() {
        UserDefaults().set(false, forKey: "devicePaired")
        if connected {
            let messageText = "disconnect"
            let data = messageText.data(using: .utf8)
            bagTracker?.writeValue(data!, for: (bagTracker?.services?.first?.characteristics?.first)!, type: CBCharacteristicWriteType.withoutResponse)
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (nil) in
                self.centralManager?.cancelPeripheralConnection(self.bagTracker!)
                self.bagTracker = nil
            }
        }
        self.performSegue(withIdentifier: "restart2", sender: nil)
    }
    
    
    
    
    
    
    
    //UNPAIR     UNPAIR     UNPAIR    UNPAIR   UNPAIR
    
    
    
    
    
    
    
    
    
    //SETTINGS TABLE
    
    
    @IBAction func openSettings(_ sender: Any) {
        
        if settingsView.isHidden {
            settingsView.isHidden = false
            settingsButton.setTitle("Close", for: .normal)
            
        } else {
            settingsView.isHidden = true
            settingsButton.setTitle("Settings", for: .normal)
        }
        
    }
    
    

    // SETTINGS TABLE
    
    
    
    
    
    //USER INTERFACE
    

    
    
    
    
    
    func checkStatusText() {
        if (self.centralManager?.isScanning)! && self.status.title != "Searching..." && !connected {
            self.status.title = "Searching..."
        } else if !(self.centralManager?.isScanning)! && self.status.title != "Disconnected" {
            if self.status.title != "Bluetooth Unavailable" && self.status.title != "Connected" {
                self.status.title = "Disconnected"
            }
        } else if (self.centralManager?.isScanning)! && connected {
            self.centralManager?.stopScan()
            self.status.title = "Connected"
        }
        let stateChange = UserDefaults().bool(forKey: "stateChange")
        if stateChange {
            self.handleMap()
            UserDefaults().set(false, forKey: "stateChange")
            let unpair = UserDefaults().bool(forKey: "unpair")
            if unpair {
                UserDefaults().set(false, forKey: "unpair")
                self.unpairStart()
            }
        }
    }
    
    
    func alertUser(title: String, subtitle: String, options: [String:UIAlertAction.Style]) {
        let alert = UIAlertController(title: title, message: subtitle, preferredStyle: UIAlertController.Style.alert)
        for eachOption in options {
            alert.addAction(UIAlertAction(title: eachOption.key, style: eachOption.value, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
    
    
    
    
    
    
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
