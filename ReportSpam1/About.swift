//
//  About.swift
//  ReportSpam1
//
//  Created by WMC Global on 9/24/18.
//  Copyright © 2018 WMC Global. All rights reserved.
//

import Foundation

extension String{
    func htmlAttributed(family: String?) -> NSAttributedString? {
        do {
            let htmlCSSString = "<style>" +
                "html *" +
                "{" +
                "font-family: \(family ?? "SourceSansPro-Light"), SourceSansPro !important;" +
            "}</style> \(self)"
            
            guard let data = htmlCSSString.data(using: String.Encoding.utf8) else {
                return nil
            }
            
            
            let attribiute = try NSMutableAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html,
                                                            .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
             
            let textColor = [ NSAttributedString.Key.foregroundColor: UIColor(named: "darkGrayColor") ]
            attribiute.addAttributes(textColor as [NSAttributedString.Key : Any], range: NSRange(location: 0, length: attribiute.length))
            return attribiute
        } catch {
            print("error: ", error)
            return nil
        }
    }
    
    func convertHtml() -> NSAttributedString{
//        let html: NSAttributedString.DocumentType
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do{
            
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil)
        }catch{
            return NSAttributedString()
        }
    }
}

class About: UIViewController {
    @IBOutlet weak var Menu: UIButton!
    
    @IBOutlet weak var lbl: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        var myDict : NSDictionary?
        var about: String = ""
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"){
            myDict = NSDictionary(contentsOfFile: path)
        }
        
        //December 1, 2018
//        let dateFormatterGet = DateFormatter()
//        dateFormatterGet.dateFormat = "MMMM dd, yyyy"
//        let dateStr = dateFormatterGet.string(from: Date())
            
        about = "<br>" + "\(myDict?.value(forKey: "about") as! String)"
        about = about.replacingOccurrences(of: "Version: 1.0", with: "Version: \(Bundle.main.releaseVersionNumber ?? "Version: 1.0")")
        about = about.replacingOccurrences(of: "CDate", with: "October 9, 2023")

        lbl.attributedText = about.htmlAttributed(family: "SourceSansPro-Light")
        lbl.linkTextAttributes = [ .foregroundColor: UIColor(named: "linkBlueColor")! ]

        self.navigationController?.isNavigationBarHidden = true

        
        Menu.addTarget(self.revealViewController(), action:NSSelectorFromString("revealToggle:"), for:UIControl.Event.touchUpInside)
        self.view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
    }
    
    override func viewDidLayoutSubviews() {
        lbl.setContentOffset(.zero, animated: false)
    }
}

extension Bundle {

    var releaseVersionNumber: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }

    var buildVersionNumber: String? {
        return self.infoDictionary?["CFBundleVersion"] as? String
    }

}
