//
//  HistoryCellTableViewCell.swift
//  ReportSpam1
//
//  Created by WMC Global on 10/9/18.
//  Copyright © 2018 WMC Global. All rights reserved.
//

import UIKit

class HistoryCellTableViewCell: UITableViewCell {
    @IBOutlet weak var senderAddress: UILabel!
    @IBOutlet weak var msgText: UITextView!
    @IBOutlet weak var dateReported: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
