//
//  Contact.swift
//  ReportSpam1
//
//  Created by WMC Global on 10/28/18.
//  Copyright © 2018 WMC Global. All rights reserved.
//

import Foundation
import MessageUI


extension UITextField {
    func setBottomBorder() {
//        let bottomLine = CALayer()
//        bottomLine.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
//        bottomLine.backgroundColor = UIColor(named: "darkGrayColor")?.cgColor
//        self.borderStyle = .none
//        self.layer.addSublayer(bottomLine)
//
        let border = UIView()
        border.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        border.frame = CGRect(x: self.frame.origin.x,
                              y: self.frame.origin.y + self.frame.height - 1, width: self.frame.width, height: 1)
        border.backgroundColor = UIColor(named: "darkGrayColor")
        self.superview!.insertSubview(border, aboveSubview: self)
    }
}

extension UITextView {
    func addBottomBorder() {
        let border = UIView()
        border.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        border.frame = CGRect(x: self.frame.origin.x,
                              y: self.frame.origin.y + self.frame.height - 1, width: self.frame.width, height: 1)
        border.backgroundColor = UIColor(named: "darkGrayColor")
        self.superview!.insertSubview(border, aboveSubview: self)
    }
}

class Contact: UIViewController, MFMailComposeViewControllerDelegate, UITextViewDelegate {
    @IBOutlet weak var Menu: UIButton!
    
    @IBOutlet weak var sendBtn: UIButton!
    
    @IBOutlet weak var lbl: UITextView!
    @IBOutlet weak var ui_scrollview: UIScrollView!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var email: UITextField!
    @IBOutlet weak var subject: UITextField!
    @IBOutlet weak var message: UITextView!
    
    let notificationCenter = NotificationCenter.default

    override func viewWillAppear(_ animated: Bool) {
        message.text = "Message"
        message.textColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.sendBtn.setGradientEffect()

        message.delegate = self
        self.navigationController?.isNavigationBarHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name:UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name:UIResponder.keyboardWillHideNotification, object: nil)
        
//        message.layer.borderColor = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0).cgColor
//        message.layer.borderWidth = 1.0
//        message.layer.cornerRadius = 5
        
        Menu.addTarget(self.revealViewController(), action:NSSelectorFromString("revealToggle:"), for:UIControl.Event.touchUpInside)
        self.view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.name.setBottomBorder()
        self.email.setBottomBorder()
        self.subject.setBottomBorder()
        self.message.addBottomBorder()
    }
        
    override func viewDidLayoutSubviews() {
      super.viewDidLayoutSubviews()
    }
        
    @IBAction func sendEmail(_ sender: Any) {
        var validation_message: String = ""
        var validation_count = 0
        if (message.text == "" || message.textColor == UIColor.lightGray) {
            validation_message.append("Please enter message")
            validation_count = validation_count + 1
        }
        if (name.text == "") {
            validation_message.append("Please enter name")
            validation_count = validation_count + 1

        }
        if !isValidEmail(testStr: email.text ?? " ") {
            validation_message.append("Please enter a valid email")
            validation_count = validation_count + 1
        }
        if(subject.text == "") {
            validation_message.append("Please enter subject")
            validation_count = validation_count + 1
        }
        if(validation_count > 1) {
            validation_message = "please fill all the details"
            showToast(controller: self, message : validation_message, seconds: 2.0)
            return;
        }
        if(validation_count == 1) {
            showToast(controller: self, message : validation_message, seconds: 2.0)
            return;
        }
        else{
            let mailComposeViewController = ConfigureMailController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                showMailError()
            }
        }
    }
    
    func ConfigureMailController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        mailComposerVC.setToRecipients(["info@spamresponse.com"])
        mailComposerVC.setSubject( "SR iOS: " + (subject.text ?? "Empty Subject"))
        let nameString = name.text ?? " "
        let emailString = email.text ?? " "
        let messageString = "Name: " + nameString  + "\nEmail: " + emailString +  "\nMessage: " + message.text
        mailComposerVC.setMessageBody(messageString, isHTML: false)
        return mailComposerVC
    }
    
    func showMailError() {
        let sendMailErrorAlert = UIAlertController(title:"Could not send email", message:"Your device could not send email", preferredStyle: .alert)
        let dismiss = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: nil)
        sendMailErrorAlert.addAction(dismiss)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        ClearFields(controller)
        controller.dismiss(animated: true, completion: nil)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if message.textColor == UIColor.lightGray.withAlphaComponent(0.5) {
            message.text = nil
            message.textColor = UIColor(named: "darkGrayColor")
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if message.text.isEmpty {
            message.text = "Message"
            message.textColor = UIColor.lightGray.withAlphaComponent(0.5)
        }
    }
    
    @IBAction func ClearFields(_ sender: Any) {
        subject.text = ""
        message.text = ""
        name.text = ""
        email.text = ""
    }
    @objc func keyboardWillShow(notification:NSNotification){
        let userInfo = notification.userInfo!
        var keyboardFrame:CGRect = (userInfo[UIResponder.keyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        keyboardFrame = self.view.convert(keyboardFrame, from: nil)
        
        var contentInset:UIEdgeInsets = self.ui_scrollview.contentInset
        contentInset.bottom = keyboardFrame.size.height
        ui_scrollview.contentInset = contentInset
    }
    
    @objc func keyboardWillHide(notification:NSNotification){
        
        let contentInset:UIEdgeInsets = UIEdgeInsets.zero
        ui_scrollview.contentInset = contentInset
    }
    
    func showToast(controller: UIViewController, message : String, seconds: Double) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.view.backgroundColor = UIColor.black
        alert.view.alpha = 0.6
        alert.view.layer.cornerRadius = 15
        
        controller.present(alert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + seconds) {
            alert.dismiss(animated: true)
        }
    }
    
    func isValidEmail(testStr:String) -> Bool {
        print("validate emilId: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        let result = emailTest.evaluate(with: testStr)
        print(result)
        return result
    }
}
