//
//  MeCell.swift
//  breakpoint
//
//  Created by Andrew Greenough on 07/09/2017.
//  Copyright © 2017 Andrew Greenough. All rights reserved.
//

import UIKit

class MeFeedCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var groupTitleLbl: UILabel!
    @IBOutlet weak var messageContentLbl: UILabel!
    
    func configureCell(groupTitle: String, messageContent: String) {
        self.groupTitleLbl.text = groupTitle
        self.messageContentLbl.text = messageContent
    }
}
