//
//  pairViewController.swift
//  Krapao Tracker
//
//  Created by Book Lailert on 21/10/18.
//  Copyright © 2018 Book Lailert. All rights reserved.
//

import UIKit
import CoreBluetooth

class pairViewController: UIViewController, CBCentralManagerDelegate, CBPeripheralDelegate {

    var bluetoothStatus = false
    var centralManager: CBCentralManager?
    var recheckBT = Timer()
    let bleService = CBUUID(string: "0x1819")
    let bleCharacter = CBUUID(string: "0x2A07")
    var bagTracker:CBPeripheral?
    var paired = false
    
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
        default:
            print("UNKNOWN OPTION")
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        checkBluetoothStatus(central: central) { (status2) in
            if status2 {
                bluetoothStatus = true
            } else {
                bluetoothStatus = false
            }
        }
        
    }
    
    func bluetoothOffAlert() {
        let alert = UIAlertController(title: "Bluetooth Not Available", message: "Please turn on bluetooth on your mobile device", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    @IBOutlet var progress: UIProgressView!
    @IBOutlet var status: UILabel!
    @IBOutlet var activity: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.welcomeText.alpha = 0.0
            self.pleaseWait.alpha = 0.0
            self.activityFinish.alpha = 0.0
            self.cover.alpha = 0.0
        }
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.Book-Lailert.centralQueueName", attributes: .concurrent)
        self.statusView.transform = CGAffineTransform(translationX: 0, y: view.frame.height)
        self.statusView.layer.cornerRadius = 22
        self.statusView.clipsToBounds = true
        
        centralManager = CBCentralManager(delegate: self, queue: centralQueue)
        
        // Do any additional setup after loading the view.
    }
    
    
    func deactivateTimer(timer: Timer){
        timer.invalidate()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !paired {
            print(peripheral)
            bagTracker = peripheral
            bagTracker?.delegate = self
            centralManager?.stopScan()
            self.centralManager?.connect(self.bagTracker!)
            DispatchQueue.main.async {
                self.progress.progress = 0.4
                self.status.text = "Connecting"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changePage"), object: nil, userInfo: ["pageNumber": 3])
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (nil) in
                    
                }
            }
        } else {
            print(peripheral)
            bagTracker = peripheral
            bagTracker?.delegate = self
            centralManager?.stopScan()
            DispatchQueue.main.async {
                UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
                    self.statusView.transform = CGAffineTransform(translationX: 0, y: self.view.frame.height)
                }, completion: nil)
                UIView.animate(withDuration: 1.0) {
                    self.welcomeText.alpha = 1.0
                    self.pleaseWait.alpha = 1.0
                    self.activityFinish.alpha = 1.0
                    self.cover.alpha = 0.0
                }
                self.progress.progress = 1.0
                UserDefaults().set(true, forKey: "devicePaired")
                self.status.text = "Paired Successfully"
                self.activity.stopAnimating()
                Timer.scheduledTimer(withTimeInterval: 2, repeats: false) { (nil) in
                    self.centralManager?.connect(self.bagTracker!)
                }
                Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (nil) in
                    self.centralManager?.cancelPeripheralConnection(self.bagTracker!)
                    self.performSegue(withIdentifier: "pairedSuccessful", sender: nil)
                })
            }
        }
    }
    
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        DispatchQueue.main.async {
            print(self.paired)
            if !self.paired {
                self.progress.progress = 0.5
                self.status.text = "Pairing"
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changePage"), object: nil, userInfo: ["pageNumber": 4])
            }
        }
        if !paired {
            peripheral.discoverServices([bleService])
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print(peripheral.services as Any)
        peripheral.discoverCharacteristics(nil, for: (peripheral.services?.first)!)
        print("sending")
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("WROTE DATA")
        print(characteristic)
        if let error = error {
            print(error)
        }
        print(characteristic)
    }
    
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        let messageText:String = "Paired"
        let data = messageText.data(using: .utf8)
        print(service.characteristics?.first! as Any)
        peripheral.writeValue(data!, for: (service.characteristics?.first!)!, type: CBCharacteristicWriteType.withoutResponse)
        
        var newUUID:String = String(Int.random(in: 1 ... 5000))
        if newUUID.count == 3 {
            newUUID = "0" + newUUID
        } else if newUUID.count == 2 {
            newUUID = "00" + newUUID
        } else if newUUID.count == 1 {
            newUUID = "000" + newUUID
        }
        let actualUUID = "0x" + newUUID
        newUUID = "UUID0x" + newUUID
        UserDefaults().set(actualUUID, forKey: "deviceUUID")
        UserDefaults().set("Tracker " + actualUUID, forKey: "deviceName")
        
        DispatchQueue.main.async {
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (nil) in
                print(newUUID)
                let UUIDData = newUUID.data(using: .utf8)
                peripheral.writeValue(UUIDData!, for: (service.characteristics?.first!)!, type: CBCharacteristicWriteType.withoutResponse)
                self.progress.progress = 0.7
                self.activity.stopAnimating()
                self.status.text = "Applying changes..."
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changePage"), object: nil, userInfo: ["pageNumber": 5])
            })
            Timer.scheduledTimer(withTimeInterval: 10, repeats: false, block: { (nil) in
                print("Hi2")
                self.centralManager?.cancelPeripheralConnection(peripheral)
                self.activity.startAnimating()
                self.progress.progress = 0.9
                self.status.text = "Reconnecting..."
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changePage"), object: nil, userInfo: ["pageNumber": 6])
                self.paired = true
                self.reconnectAfterPair(newID: actualUUID)
            })
            
        }
    }
    
    
    
    func reconnectAfterPair(newID: String) {
        centralManager?.scanForPeripherals(withServices: [CBUUID(string: newID)], options: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.4, delay: 0.0, options: .curveEaseInOut, animations: {
                self.statusView.transform = .identity
                self.cover.alpha = 0.35
            }, completion: nil)
        }
        
        
        if !bluetoothStatus {
            bluetoothOffAlert()
            recheckBT = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (nil) in
                if self.bluetoothStatus {
                    self.deactivateTimer(timer: self.recheckBT)
                    self.progress.progress = 0.2
                    self.status.text = "Scanning for device"
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changePage"), object: nil, userInfo: ["pageNumber": 2])
                    self.centralManager?.scanForPeripherals(withServices: [self.bleService])
                    self.activity.startAnimating()
                }
            }
        } else {
            progress.progress = 0.2
            status.text = "Scanning for device"
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "changePage"), object: nil, userInfo: ["pageNumber": 2])
            centralManager?.scanForPeripherals(withServices: [bleService])
            activity.startAnimating()
        }
    }

    @IBOutlet var statusView: UIView!
    
    
    @IBOutlet var cover: UIView!
    @IBOutlet var welcomeText: UILabel!
    @IBOutlet var pleaseWait: UILabel!
    @IBOutlet var activityFinish: UIActivityIndicatorView!
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
