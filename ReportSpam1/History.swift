//
//  History_model.swift
//  ReportSpam1
//
//  Created by WMC Global on 10/9/18.
//  Copyright © 2018 WMC Global. All rights reserved.
//

import Foundation

class Records: Codable {
    let records : [History]
    
    init(records: [History]) {
        self.records = records
    }
}

class History: Codable {
    let id: Int;
    let msgDateTime : String;
    let msgReportTime: String;
    let msgText : String;
    let senderAddress : String;
    
    init(id: Int, msgDateTime: String, msgReportTime: String, msgText: String, senderAddress: String) {
        self.id = id
        self.msgDateTime =  msgDateTime
        self.msgReportTime = msgReportTime
        self.msgText = msgText
        self.senderAddress = senderAddress
    }
}
