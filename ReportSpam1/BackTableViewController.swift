//
//  BackTableViewController.swift
//  ReportSpam1
//
//  Created by WMC Global on 9/24/18.
//  Copyright © 2018 WMC Global. All rights reserved.
//

import Foundation

let reuseIdentifier = "BackTableHeaderView"

class BackTableViewController: UITableViewController {

    var tableArray = [String]()
    var tableIcons = [String]()
    
    var lastSelectionIndex: IndexPath?
        
    let notificationCenter = NotificationCenter.default

    override func viewDidLoad() {
        self.lastSelectionIndex = IndexPath(row: 0, section: 0)

        //UIApplication.shared.statusbarstatusBarView?.backgroundColor = UIColor.white
        
        self.tableView.register(UINib(nibName: reuseIdentifier, bundle: nil), forHeaderFooterViewReuseIdentifier: reuseIdentifier)

        tableArray = ["Report History", "About", "App Info", "Privacy Policy", "Terms and Conditions"]
        tableIcons = ["ReportHistory", "About", "Info_Info", "Privacy_Privacy", "TermsCondition"]
        
        let headerView: UIView = UIView.init(frame: CGRect(x: 1, y: 0, width: 276, height: 120))
        headerView.backgroundColor = UIColor(named: "darkGrayColor")
        
        let bg: UIImageView = UIImageView.init(frame: CGRect(x: 15, y: 70, width: 200, height: 39))
        bg.image = UIImage(named: "sideHeaderLogo")
        bg.contentMode = .scaleAspectFit
        headerView.addSubview(bg)
        self.tableView.tableHeaderView = headerView
        let indexPath = IndexPath(row: 0, section: 0)
        if(self.tableView.indexPathForSelectedRow?.row ?? -1 < 0){
            self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        }
        

        // Add observer:
        notificationCenter.addObserver(self,
                                       selector:#selector(self.applicationFinishedRestoringState),
          name:UIApplication.willResignActiveNotification,
          object:nil)
    }
    
    // Callback:
    @objc func applicationWillResignActiveNotification() {
      // Handle application will resign notification event.
        self.tableView.reloadData()
    }
    
    var coverView: UIView = UIView()
    override func viewWillAppear(_ animated: Bool) {
        let screenRect:CGRect = UIScreen.main.bounds
        coverView = UIView(frame: screenRect)
        coverView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        coverView.addGestureRecognizer((self.revealViewController()?.tapGestureRecognizer())!)
        coverView.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
        self.revealViewController()?.frontViewController.view.addSubview(coverView)
        self.tableView.reloadData()
    }

    override func viewDidDisappear(_ animated: Bool) {
        coverView.removeFromSuperview()
    }
    
    // , "Privacy Policy", "Terms & Conditions", "Exit"
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: tableArray[indexPath.row], for: indexPath) as UITableViewCell
        let menu = tableArray[indexPath.row]
        let imageName = tableIcons[indexPath.row]
        
        var textColor = UIColor(named: "darkGrayColor")
        if self.traitCollection.userInterfaceStyle == .dark {
            if let selIndexPath = self.lastSelectionIndex, selIndexPath.row == indexPath.row {
                textColor = UIColor(named: "darkModeTblTextColor")
            }
        }
        
        if let imageView = cell.contentView.viewWithTag(22) as? UIImageView {
            if self.traitCollection.userInterfaceStyle == .dark, let selIndexPath = self.lastSelectionIndex, selIndexPath.row == indexPath.row {
                imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = UIColor(named:"darkModeTblTextColor")
            } else {
                imageView.image = UIImage(named: imageName)
            }
        }
        
        let view = UIView()
        view.backgroundColor = UIColor(named: "tbleSelectionColor")
        cell.selectedBackgroundView = view
        
        if let selIndexPath = self.lastSelectionIndex, selIndexPath.row == indexPath.row {
//            cell.backgroundColor = UIColor(named: "tbleSelectionColor")
            tableView.selectRow(at: selIndexPath, animated: false, scrollPosition: UITableView.ScrollPosition.none)
        } else {
//            cell.backgroundColor = UIColor.clear
        }

        let myAttribute = [ NSAttributedString.Key.foregroundColor: textColor, NSAttributedString.Key.font: UIFont(name: "SourceSansPro-Regular", size: 18.0)! ]

        let attriString = NSAttributedString(string: menu, attributes: myAttribute as [NSAttributedString.Key : Any])
        cell.textLabel?.attributedText = attriString
        
        cell.indentationLevel = 3;
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.lastSelectionIndex = indexPath
        tableView.reloadData()
    }
    
    func decorateText(sub:String, des:String)->NSAttributedString{
        let textAttributesOne = [NSAttributedString.Key.foregroundColor: UIColor(displayP3Red: 0.76, green: 0, blue: 0.18, alpha: 1.0), NSAttributedString.Key.font: UIFont(name: "LucidaSans-Demi", size: 18.0)]
        
        let textAttributesTwo = [NSAttributedString.Key.foregroundColor: UIColor.white, NSAttributedString.Key.font: UIFont(name: "LucidaSans-Demi", size: 18.0)]
        
        let textPartOne = NSMutableAttributedString(string: sub, attributes: textAttributesOne as [NSAttributedString.Key : Any])
        let textPartTwo = NSMutableAttributedString(string: des, attributes: textAttributesTwo as [NSAttributedString.Key : Any])
        
        let textCombination = NSMutableAttributedString()
        textCombination.append(textPartOne)
        textCombination.append(textPartTwo)
        return textCombination
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
