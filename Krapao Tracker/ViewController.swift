//
//  ViewController.swift
//  Krapao Tracker
//
//  Created by Book Lailert on 21/10/18.
//  Copyright © 2018 Book Lailert. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class ViewController: UIViewController {
    
    let defaults = UserDefaults()
    
    let bleService = CBUUID(string: "0x1819")
    let bleCharacter = CBUUID(string: "0x2A07")
    var centralManager: CBCentralManager?
    var bluetoothStatus = true
    
    
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
        checkBluetoothStatus(central: central) { (status) in
            if status {
                bluetoothStatus = true
            } else {
                bluetoothStatus = false
            }
        }
        
    }
    
    
    func pairAlert() {
        let alert = UIAlertController(title: "No Devices Paired", message: "Pairing will start now.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: { action in
            
            self.performSegue(withIdentifier: "startPairing", sender: nil)
            
        }))
        
        self.present(alert, animated: true)
    }
    
    var locationManager = CLLocationManager()
    
    @IBOutlet var text: UILabel!
    @IBOutlet var autoout: UIButton!
    @IBAction func auto(_ sender: Any) {
        self.performSegue(withIdentifier: "startPairing", sender: nil)
    }
    
    
    @IBAction func manual(_ sender: Any) {
        self.performSegue(withIdentifier: "alreadyPaired", sender: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            self.text.isHidden = true
            self.autoout.isHidden = true

        }
                //manualout.isHidden = true
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("Start")
        //manualout.isHidden = false
        print(defaults.bool(forKey: "devicePaired"))
        if defaults.bool(forKey: "devicePaired") {
            self.performSegue(withIdentifier: "alreadyPaired", sender: nil)
        } else {
            text.isHidden = false
            autoout.isHidden = false
        }
    }


}

