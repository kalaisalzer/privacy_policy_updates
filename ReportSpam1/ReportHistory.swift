//
//  ViewController.swift
//  ReportSpam1
//
//  Created by WMC Global on 7/20/18.
//  Copyright © 2018 WMC Global. All rights reserved.
//

import UIKit
import CoreTelephony
//import CoreData

extension Date {
    
    // Convert local time to UTC (or GMT)
    func toGlobalTime() -> Date {
        
        let timezone = TimeZone(identifier: "UTC")!
        let seconds = -TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds + TimeInterval(timezone.secondsFromGMT()), since: self)
    }
    
    // Convert UTC (or GMT) to local time
    func toLocalTime() -> Date {
        let timezone = TimeZone.current
        let seconds = TimeInterval(timezone.secondsFromGMT(for: self))
        return Date(timeInterval: seconds, since: self)
    }
    
}

class ReportHistory: UIViewController, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    private var histories = [History]()
    @IBOutlet weak var Menu: UIButton!
    var dateFormatterGet = DateFormatter()
    let dateFormatterPrint = DateFormatter()
    var myDict : NSDictionary?
    var domain : String = ""
    var ak : String = ""
    let httpUrl = "retrieve-history?uuid="
    var UUID: String = ""
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(self.handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.gray
        
        return refreshControl
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        
        // changing db UTC to local UTC
        dateFormatterGet.dateFormat = "yyyy-MM-dd hh:mm:ss a"
      // dateFormatterGet = DateFormatter.dateFormat(fromTemplate: "yyyy-MM-dd hh:mm:ss a", options: 0, locale: NSLocale(localeIdentifier: "en_US_POSIX") as Locale)
        dateFormatterGet.timeZone = TimeZone(identifier: "UTC")!
        dateFormatterGet.locale = NSLocale(localeIdentifier: "en_US_POSIX") as Locale
        dateFormatterPrint.dateFormat = "yyyy-MM-dd hh:mm:ss a"
       
        let networkInfo = CTTelephonyNetworkInfo()
        UUID = WMCKeychains.getUUID()
        
        if #available(iOS 12.0, *)  {
            if let userDefaults = UserDefaults(suiteName: "group.com.wmcglobal.spam") , let carrier = networkInfo.serviceSubscriberCellularProviders?.first?.value {
                if let carrier = carrier.carrierName {
                    userDefaults.set(carrier, forKey: "carrierName")
                }
                userDefaults.set(UUID as AnyObject, forKey: "UUID")
                userDefaults.synchronize()
            }
        } else {
            if let userDefaults = UserDefaults(suiteName: "group.com.wmcglobal.spam") , let carrier = networkInfo.subscriberCellularProvider {
                 userDefaults.set(carrier.carrierName as AnyObject, forKey: "carrierName")
                 userDefaults.set(UUID as AnyObject, forKey: "UUID")
                 userDefaults.synchronize()
             }
        }
        
       self.tableView.tableFooterView = UIView()
       self.tableView.addSubview(self.refreshControl)
       self.getData()
        
        Menu.addTarget(self.revealViewController(), action:NSSelectorFromString("revealToggle:"), for:UIControl.Event.touchUpInside)
        self.view.addGestureRecognizer((self.revealViewController()?.panGestureRecognizer())!)
    }
    
    func getData(){
       
        if let path = Bundle.main.path(forResource: "config", ofType: "plist"){
            myDict = NSDictionary(contentsOfFile: path)
        }
        domain = myDict?.value(forKey: "url") as! String
        ak = myDict?.value(forKey: "key")  as! String
        print(UUID)
        guard let url = URL(string: domain + httpUrl + UUID) else {
            return
        }
        var request = URLRequest(url: url)
        request.setValue(ak, forHTTPHeaderField: "X-API-KEY")
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let response = response {
                print(response)
            }
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let records = try decoder.decode(Records.self, from: data)
                    self.histories = records.records
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                    
                } catch{
                    print(error)
                }
            }
        }
        task.resume()
    }
    
    @objc func willEnterForeground() {

    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return max(self.histories.count, 1)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        if self.histories.count == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "norow_cell") else {
                return UITableViewCell()
            }
            self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
            return cell
        }
        else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "hist_cell") as? HistoryCellTableViewCell else {
                return UITableViewCell()
            }
            dateFormatterGet.isLenient = true
            if let date = dateFormatterGet.date(from: histories[indexPath.row].msgReportTime) {
                let localdate = date.toGlobalTime()
                cell.dateReported.text = dateFormatterPrint.string(from: localdate)
            } else {
                print("There was an error decoding the string")
            }

            cell.senderAddress.text = histories[indexPath.row].senderAddress
            cell.msgText.text = histories[indexPath.row].msgText
            cell.msgText.textContainer.lineBreakMode = .byTruncatingTail
            return cell
        }
    }

    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getData()
        self.tableView.reloadData()
        refreshControl.endRefreshing()
    }
}
