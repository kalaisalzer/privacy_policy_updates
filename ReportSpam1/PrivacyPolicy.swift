//
//  PrivacyPolicy.swift
//  ReportSpam1
//
//  Created by WMC Global on 9/25/18.
//  Copyright © 2018 WMC Global. All rights reserved.
//

import Foundation

class PrivacyPolicy: UIViewController {
    @IBOutlet weak var Menu: UIButton!
    @IBOutlet weak var txtView: UITextView!
    var htmlText = ""
  

    override func viewDidLoad() {
        super.viewDidLoad()
        var first_privacy_p: String = ""
        var myDict : NSDictionary?
        readString()

        self.navigationController?.isNavigationBarHidden = true
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"){
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        txtView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)

        first_privacy_p = "<br>" + "\(myDict?.value(forKey: "first_privacy_p") as! String)"
        first_privacy_p = first_privacy_p.replacingOccurrences(of: "left;\"><strong>READ OUR PRIVACY POLICY", with: "center;\"><strong>Read Our Privacy Policy")
    
//        txtView.attributedText = first_privacy_p.htmlAttributed(family: "SourceSansPro-Light")
        txtView.linkTextAttributes = [ .foregroundColor: UIColor(named: "linkBlueColor")! ]

        Menu.addTarget(self.revealViewController(), action:NSSelectorFromString("revealToggle:"), for:UIControl.Event.touchUpInside)
        self.view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        txtView.attributedText = htmlText.htmlAttributed(family: "SourceSansPro-Light")
    }
    
    override func viewDidLayoutSubviews() {
        self.txtView.setContentOffset(.zero, animated: false) 
    }

    func readString() {
       do {
          // creating a path from the main bundle
          if let bundlePath = Bundle.main.path(forResource: "privacy.html", ofType: nil) {
             let stringContent = try String(contentsOfFile: bundlePath)
            htmlText = stringContent

          }
       } catch {
          print(error)
       }
    }
}
