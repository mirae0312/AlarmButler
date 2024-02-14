//
//  TimeZoneNavigationViewController.swift
//  AlarmButler
//
//  Created by t2023-m0099 on 2/14/24.
//

import UIKit

class TimeZoneNavigationViewController: UINavigationController {
    
    var clockData: [(String, TimeZone)] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupData()
    }
    
    func setupData(){
        let selectVC = self.viewControllers.first as! TimZoneController
        
        selectVC.clockData = self.clockData
    }

}
