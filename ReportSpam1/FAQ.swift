//
//  FAQ.swift
//  ReportSpam1
//
//  Created by WMC Global on 9/25/18.
//  Copyright © 2018 WMC Global. All rights reserved.
//

import Foundation

class FAQ: UIViewController {
    @IBOutlet weak var Menu: UIButton!
    @IBOutlet weak var lbl: UITextView!
  
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        var faq: String = ""
        var myDict : NSDictionary?
        
        
        self.navigationController?.isNavigationBarHidden = true
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"){
            myDict = NSDictionary(contentsOfFile: path)
        }
        faq = myDict?.value(forKey: "faq") as! String
        faq = "<br>" + "\(faq)"

        lbl.attributedText = faq.htmlAttributed(family: "SourceSansPro-Light")
        lbl.linkTextAttributes = [ .foregroundColor: UIColor(named: "linkBlueColor")! ]

        Menu.addTarget(self.revealViewController(), action:NSSelectorFromString("revealToggle:"), for:UIControl.Event.touchUpInside)
        self.view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
    }
    
    override func viewDidLayoutSubviews() {
        lbl.setContentOffset(.zero, animated: false)
    }
    
}
