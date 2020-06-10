//
//  Settings.swift
//  Krapao Tracker
//
//  Created by Book Lailert on 6/11/18.
//  Copyright © 2018 Book Lailert. All rights reserved.
//

import UIKit

class Settings: UITableViewController {
    
    let vc = MainViewController()
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 2 && indexPath.row == 1{
            UserDefaults().set(true, forKey: "unpair")
            UserDefaults().set(true, forKey: "stateChange")
            self.dismiss(animated: true, completion: nil)
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBOutlet var mapModeSelector: UISegmentedControl!
    
    
    @IBAction func mapMode(_ sender: Any) {
        UserDefaults().set(mapModeSelector.selectedSegmentIndex, forKey: "mapMode")
        UserDefaults().set(true, forKey: "stateChange")
    }
    
    @IBAction func Notificationtoggle(_ sender: Any) {
        UserDefaults().set(notificationActivation.isOn, forKey: "notification")
    }
    
    @IBOutlet var notificationActivation: UISwitch!
    
    @IBOutlet var deviceID: UILabel!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        let mapMode = UserDefaults().integer(forKey: "mapMode")
        if mapMode == 1 {
            mapModeSelector.selectedSegmentIndex = 1
        } else {
            mapModeSelector.selectedSegmentIndex = 0
        }
        deviceID.text = UserDefaults().string(forKey: "deviceUUID")!
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }



    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
