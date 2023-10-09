//
//  WMCKeychains.swift
//  ReportSpam1
//
//  Created by Nicson Selvaraj on 06/10/20.
//  Copyright © 2020 WMC Global. All rights reserved.
//

import UIKit

import Security
 
class WMCKeychains: NSObject {
 
    static func generateUDID() -> String {
        var uuid = NSUUID().uuidString
        if let userDefaults = UserDefaults(suiteName: "group.com.wmcglobal.spam") {
                if((userDefaults.string(forKey: "UUID")) != nil){
                    uuid = userDefaults.string(forKey: "UUID")!
                }
            }
        KeychainWrapper.standard.set(uuid, forKey: "uniqueId", withAccessibility: .always)
        return uuid
    }
    
    static func getUUID() -> String {
        if let uuid = KeychainWrapper.standard.string(forKey: "uniqueId") {
            return uuid
        } else {
            return generateUDID()
        }
    }
    
}

extension KeychainWrapper.Key {
    static let uniqueId: KeychainWrapper.Key = "uniqueId"
}
