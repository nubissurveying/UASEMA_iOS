//
//  alarmTableViewCell.swift
//  Survey
//
//  Created by Qinjia Huang on 10/9/17.
//  Copyright © 2017 Qinjia Huang. All rights reserved.
//

import UIKit

class alarmTableViewCell: UITableViewCell {

    @IBOutlet weak var alarmDetail: UILabel!
    @IBOutlet weak var alarmDate: UILabel!
    @IBOutlet weak var alarmed: UILabel!
    @IBOutlet weak var taken: UILabel!
    @IBOutlet weak var closed: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
