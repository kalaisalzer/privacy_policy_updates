//
//  AppInfo.swift
//  ReportSpam1
//
//  Created by WMC Global on 9/24/18.
//  Copyright © 2018 WMC Global. All rights reserved.
//

import Foundation

class AppInfo: UIViewController {

    @IBOutlet weak var Menu: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        Menu.addTarget(self.revealViewController(), action:NSSelectorFromString("revealToggle:"), for:UIControl.Event.touchUpInside)
        self.view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        
    }    
}
