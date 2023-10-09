//
//  TermsConditions.swift
//  ReportSpam1
//
//  Created by WMC Global on 9/25/18.
//  Copyright © 2018 WMC Global. All rights reserved.
//

import Foundation

class TermsConditions: UIViewController {
    @IBOutlet weak var Menu: UIButton!
    @IBOutlet weak var txtView: UITextView!

    func readString() {
       do {
          // creating a path from the main bundle
          if let bundlePath = Bundle.main.path(forResource: "privacy.html", ofType: nil) {
             let stringContent = try String(contentsOfFile: bundlePath)
             print("Content string starts from here-----")
             print(stringContent)
             print("End at here-----")
          }
       } catch {
          print(error)
       }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        readString()
        
        var myDict : NSDictionary?
        var firstTimeT_C: String = ""
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"){
            myDict = NSDictionary(contentsOfFile: path)
        }
        firstTimeT_C = "<br>" + "\(myDict?.value(forKey: "first_t_c") as! String)"
        firstTimeT_C = firstTimeT_C.replacingOccurrences(of: "Terms & Conditions", with: "Terms of Use")
        
        txtView.attributedText = firstTimeT_C.htmlAttributed(family: "SourceSansPro-Light")
        txtView.linkTextAttributes = [ .foregroundColor: UIColor(named: "linkBlueColor")! ]

        self.navigationController?.isNavigationBarHidden = true
        Menu.addTarget(self.revealViewController(), action:NSSelectorFromString("revealToggle:"), for:UIControl.Event.touchUpInside)
        self.view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
    }
    
    override func viewDidLayoutSubviews() {
        txtView.setContentOffset(.zero, animated: false)
    }
}
