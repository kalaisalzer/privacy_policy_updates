//
//  UsingApp.swift
//  ReportSpam1
//
//  Created by WMC Global on 9/25/18.
//  Copyright © 2018 WMC Global. All rights reserved.
//

import Foundation
class UsingApp: UIViewController {
    @IBOutlet weak var Menu: UIButton!
   
    @IBOutlet weak var using_app_textview: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        var myDict : NSDictionary?
        var using_app: String = ""
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"){
            myDict = NSDictionary(contentsOfFile: path)
        }
        using_app = myDict?.value(forKey: "using_app") as! String
        using_app = "<br>" + "\(using_app)"

        using_app_textview.attributedText = using_app.htmlAttributed(family: "SourceSansPro-Light")
        self.navigationController?.isNavigationBarHidden = true
        
        Menu.addTarget(self.revealViewController(), action:NSSelectorFromString("revealToggle:"), for:UIControl.Event.touchUpInside)
        self.view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
    }
    
    override func viewDidLayoutSubviews() {
        using_app_textview.setContentOffset(.zero, animated: false)
    }
    
}
