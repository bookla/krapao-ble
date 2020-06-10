//
//  SearchingViewController.swift
//  Krapao Tracker
//
//  Created by Book Lailert on 10/6/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import UIKit

class SearchingViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        x.layer.cornerRadius = x.frame.height/2
        x.clipsToBounds = true
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet var x: UIButton!
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
