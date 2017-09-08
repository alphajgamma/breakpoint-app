//
//  FeedCell.swift
//  breakpoint
//
//  Created by Andrew Greenough on 05/09/2017.
//  Copyright © 2017 Andrew Greenough. All rights reserved.
//

import UIKit
import FirebaseStorageUI

class FeedCell: UITableViewCell {
    
    // Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var contentLbl: UILabel!
    
    func configureCell(profileImageURL: String, email: String, content: String) {
        let defaultProfileImage = UIImage(named: "defaultProfileImage")
        if profileImageURL != "" {
            let profileImageRef = Storage.storage().reference(forURL: profileImageURL)
            SDImageCache.shared().removeImage(forKey: profileImageURL, fromDisk: true, withCompletion: nil)
            self.profileImage.sd_setImage(with: profileImageRef, placeholderImage: defaultProfileImage)
        } else {
            self.profileImage.image = defaultProfileImage
        }
        self.emailLbl.text = email
        self.contentLbl.text = content
    }
}
