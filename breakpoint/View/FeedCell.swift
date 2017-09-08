//
//  FeedCell.swift
//  breakpoint
//
//  Created by Andrew Greenough on 05/09/2017.
//  Copyright © 2017 Andrew Greenough. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    
    func configureCell(profileImageURL: String, email: String, content: String) {
        let defaultProfileImage = UIImage(named: "defaultProfileImage")
        if profileImageURL != "" {
            DataService.instance.setProfileImage(forImageView: self.profileImage, withprofileImageURL: profileImageURL)
        } else {
            self.profileImage.image = defaultProfileImage
        }
        self.emailLbl.text = email
        self.contentLbl.text = content
    }
}
