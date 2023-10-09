//
//  Terms_Policy_launch.swift
//  ReportSpam1
//
//  Created by WMC Global on 10/14/18.
//  Copyright © 2018 WMC Global. All rights reserved.
//

import Foundation

class Terms_Policy_launch: UIViewController {
    
    @IBOutlet weak var loadingView: UIView!
    @IBOutlet weak var acceptBtn: UIButton!
    @IBOutlet weak var declineBtn: UIButton!
    @IBOutlet weak var t_c: UITextView!
    @IBOutlet weak var p_p: UITextView!
    var htmlText = ""


    override func viewWillAppear(_ animated: Bool) {
        //resetDefaults()
        var terms:String = ""
        if let userDefaults = UserDefaults(suiteName: "group.com.wmcglobal.spam") {
            if((userDefaults.string(forKey: "terms")) != nil){
                terms = userDefaults.string(forKey: "terms")!
            }
        }
        if(terms == "checked"){
            OperationQueue.main.addOperation {
                [weak self] in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    [weak self] in
                    
                    self?.performSegue(withIdentifier: "rev", sender: self)
                }
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        readString()
        self.acceptBtn.setGradientEffect()
        
        var myDict : NSDictionary?
        var firstTimeT_C: String = ""
        var first_privacy_p: String = ""
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"){
            myDict = NSDictionary(contentsOfFile: path)
        }
        firstTimeT_C = myDict?.value(forKey: "first_t_c") as! String
        
        let repOccurace = "<FONT face=\"Lucida Sans, serif\"><FONT SIZE=3 STYLE=\"font-size: 22px\"><div STYLE=\"text-align: center\"><B>Terms & Conditions</B> </div></FONT></FONT></FONT>         <br /><p class=\"western\" style=\"text-indent: 0in; margin-top: 0.17in\">"
        
        firstTimeT_C = firstTimeT_C.replacingOccurrences(of: repOccurace, with: "")
        
        first_privacy_p = myDict?.value(forKey: "first_privacy_p") as! String
        
        t_c.dataDetectorTypes = UIDataDetectorTypes.all;
        p_p.dataDetectorTypes = UIDataDetectorTypes.all;

        t_c.attributedText = firstTimeT_C.htmlAttributed(family: "SourceSansPro-Light")
        t_c.linkTextAttributes = [ .foregroundColor: UIColor(named: "linkBlueColor")! ]

        p_p.attributedText = first_privacy_p.htmlAttributed(family: "SourceSansPro-Light")
        p_p.linkTextAttributes = [ .foregroundColor: UIColor(named: "linkBlueColor")! ]

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            [weak self] in

            self?.loadingView.removeFromSuperview()
        }

        p_p.attributedText = htmlText.htmlAttributed(family: "SourceSansPro-Light")
      
    }
    func readString() {
       do {
          if let bundlePath = Bundle.main.path(forResource: "privacy_1.html", ofType: nil) {
             let stringContent = try String(contentsOfFile: bundlePath)
              htmlText = stringContent
          }
       } catch {
          print(error)
       }
    }

    @objc func willEnterForeground() {
    
    }
    
    @IBAction func onAcceptBtn(_ sender: Any) {
        if let userDefaults = UserDefaults(suiteName: "group.com.wmcglobal.spam") {
            userDefaults.set("checked" as String, forKey: "terms")
        }
    }
    
    @IBAction func onDeclineBtn(_ sender: Any) {
        exit(0)
    }
    
    func resetDefaults() {
        
        if let userDefaults = UserDefaults(suiteName: "group.com.wmcglobal.spam") {
            let dictionary = userDefaults.dictionaryRepresentation()
            dictionary.keys.forEach { key in
                userDefaults.removeObject(forKey: key)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.t_c.setContentOffset(.zero, animated: false) 
        self.p_p.setContentOffset(.zero, animated: false)

    }
    

}

extension UIButton {
    func setGradientEffect() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.colors = [UIColor(rgb: 0x4d65f6).cgColor, UIColor(rgb: 0x42D7FB).cgColor]
        gradientLayer.locations  = [0.45, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.65)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.2)

        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}

extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")

       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }

   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}



extension String {
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return nil }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return nil
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}
