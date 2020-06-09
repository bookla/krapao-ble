//
//  PairingStagesViewController.swift
//  Krapao Tracker
//
//  Created by Book Lailert on 9/6/20.
//  Copyright © 2020 Book Lailert. All rights reserved.
//

import UIKit

class PairingStagesViewController: UIPageViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(self.changePage), name: NSNotification.Name(rawValue: "changePage"), object: nil)
        self.setViewControllers([getPage(pageNumber: 1)], direction: .forward, animated: true, completion: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func changePage(notif: NSNotification) {
        if let pageNum = notif.userInfo?["pageNumber"] as? Int {
            let vcTo = self.getPage(pageNumber: pageNum)
            self.setViewControllers([vcTo], direction: .forward, animated: true, completion: nil)
        }
    }
    
    
    func getPage(pageNumber: Int) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: "Pairing-" + String(pageNumber))
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
