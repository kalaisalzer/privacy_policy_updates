//
//  Tutorial.swift
//  ReportSpam1
//
//  Created by WMC Global on 10/31/18.
//  Copyright © 2018 WMC Global. All rights reserved.
//

import Foundation

class Tutorial: UIViewController {
    
    @IBOutlet weak var tutorial_textview: UITextView!
    @IBOutlet weak var nextBtn: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.nextBtn.setGradientEffect()

        var myDict : NSDictionary?
        var using_app: String = ""
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"){
            myDict = NSDictionary(contentsOfFile: path)
        }
        using_app = myDict?.value(forKey: "using_app") as! String
        tutorial_textview.attributedText = using_app.htmlAttributed(family: "SourceSansPro-Light")
        self.navigationController?.isNavigationBarHidden = true
        
    }
    
    override func viewDidLayoutSubviews() {
        tutorial_textview.setContentOffset(.zero, animated: false)
    }
    
    
}

