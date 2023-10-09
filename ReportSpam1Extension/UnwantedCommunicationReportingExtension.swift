//
//  UnwantedCommunicationReportingExtension.swift
//  ReportSpam1Extension
//
//  Created by WMC Global on 7/20/18.
//  Copyright © 2018 WMC Global. All rights reserved.
//

import UIKit
import IdentityLookup
import IdentityLookupUI
import CoreTelephony
import CoreData

extension Date {
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds + TimeInterval(timezone.secondsFromGMT()), since: self)
    }
}

class UnwantedCommunicationReportingExtension: ILClassificationUIExtensionViewController, UITextViewDelegate {
   
    @IBOutlet weak var red_label: UILabel!
    @IBOutlet weak var confirmLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: "darkGrayColor")!]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        var terms:String = ""
        if let userDefaults = UserDefaults(suiteName: "group.com.wmcglobal.spam") {
            if((userDefaults.string(forKey: "terms")) != nil){
                terms = userDefaults.string(forKey: "terms")!
            }
        }
        
        if(terms != "checked") {
            //confirmLabel.textColor = UIColor(displayP3Red: 0.76, green: 0, blue: 0.18, alpha: 1.0)
            confirmLabel.text = "You must review and accept the Terms and Conditions before you can report spam."
            let alert = UIAlertController(title: "SpamResponse Alert!", message: "You must review and accept the Terms and Conditions before you can report spam.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                case .default:
                    print("default")
                
                case .cancel:
                    print("cancel")
                
                case .destructive:
                    print("destructive")
                
            }}))
            self.present(alert, animated: true, completion: nil)
            self.extensionContext.isReadyForClassificationResponse = false
        }
        else {
            let mainAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "SourceSansPro-Regular", size: 18.0)!]
            
            let worldAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont(name: "SourceSansPro-SemiBold", size: 18.0)!]

            let helloWorldString = NSMutableAttributedString(string: "Click Done to Report Spam!", attributes: mainAttributes)
            helloWorldString.addAttributes(worldAttributes, range: NSRange(location: 6, length: 4))

            self.confirmLabel.attributedText =  helloWorldString
            self.extensionContext.isReadyForClassificationResponse = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
    }
    
    // Customize UI based on the classification request before the view is loaded
    override func prepare(for classificationRequest: ILClassificationRequest) {
        // Configure your views for the classification request
    }
    
    // Provide a classification response for the classification request
    override func classificationResponse(for request:ILClassificationRequest) -> ILClassificationResponse {
        let userAction:ILClassificationAction =  ILClassificationAction.reportJunk;
        let userData:ILClassificationResponse = ILClassificationResponse.init(action: userAction)
        
        // if user wants to report [a] message
        if let ilmessage:ILMessageClassificationRequest = request as? ILMessageClassificationRequest{
            let messageCom = ilmessage.messageCommunications;
            var carrierName: String = "";
            var uuid: String = "";
            if let userDefaults = UserDefaults(suiteName: "group.com.wmcglobal.spam") {
                carrierName = userDefaults.string(forKey: "carrierName")!
                uuid = userDefaults.string(forKey: "UUID")!
            }
            
            var message_body:[String] = []
            var message_date: [String] = []
            for message in messageCom {
                message_body.append((message.messageBody?.description)!)
                message_date.append((message.dateReceived.description.description))
            }
            //let message_body = (messageCom[0].messageBody?.description)! + " "
            
            let carr_name = String(describing: carrierName) + " "
            
            
            let message_sender = String(describing: messageCom[0].sender!.description) + " "
            
            userData.userInfo = ["dateRecieved": message_date, "messageBody": message_body, "sender":message_sender, "carrierName": carr_name, "UUID": uuid.description, "dateReported": Date().description ]
            
        }
        // if user wants to report a call.
        if let ilphone:ILCallClassificationRequest = request as? ILCallClassificationRequest{
            let phoneCom = ilphone.callCommunications;
            var carrierName: String = "";
            var uuid: String = "";
            if let userDefaults = UserDefaults(suiteName: "group.com.wmcglobal.spam") {
                carrierName = userDefaults.string(forKey: "carrierName")!
                uuid = userDefaults.string(forKey: "UUID")!
            }
            
            var phone_body:[String] = []
            var phone_date: [String] = []
            for phone in phoneCom {
                phone_body.append(("Phone call"))
                phone_date.append((phone.dateReceived.description.description))
            }
            //let message_body = (messageCom[0].messageBody?.description)! + " "
            
            let carr_name = String(describing: carrierName) + " "
            
            
            let phone_sender = String(describing: phoneCom[0].sender!.description) + " "
            
            userData.userInfo = ["dateRecieved": phone_date, "messageBody": phone_body, "sender":phone_sender, "carrierName": carr_name, "UUID": uuid.description, "dateReported": Date().description ]
            
        }
        return userData
    }
}

