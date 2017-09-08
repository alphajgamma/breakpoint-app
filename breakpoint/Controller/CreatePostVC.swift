//
//  CreatePostVC.swift
//  breakpoint
//
//  Created by Andrew Greenough on 05/09/2017.
//  Copyright © 2017 Andrew Greenough. All rights reserved.
//

import UIKit
import Firebase
import FirebaseStorageUI

class CreatePostVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.delegate = self
        sendBtn.bindToKeyboard()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailLbl.text = Auth.auth().currentUser?.email
        DataService.instance.REF_USERS.observe(.value) { (snapshot) in
            DataService.instance.getUser(forUID: (Auth.auth().currentUser?.uid)!, handler: { (returnedUser) in
                if let profileImageURL = returnedUser.childSnapshot(forPath: "profileImageURL").value as? String {
                    let defaultProfileImage = UIImage(named: "defaultProfileImage")
                    let profileImageRef = Storage.storage().reference(forURL: profileImageURL)
                    SDImageCache.shared().removeImage(forKey: profileImageURL, fromDisk: true, withCompletion: nil)
                    self.profileImage.sd_setImage(with: profileImageRef, placeholderImage: defaultProfileImage)
                }
            })
        }
    }

    @IBAction func sendBtnWasPressed(_ sender: Any) {
        if textView.text != nil && textView.text != "Say something here..." {
            sendBtn.isEnabled = false
            DataService.instance.uploadPost(withMessage: textView.text, forUID: (Auth.auth().currentUser?.uid)!, withGroupKey: nil, sendComplete: { (isComplete) in
                if isComplete {
                    self.sendBtn.isEnabled = true
                    self.dismiss(animated: true, completion: nil)
                } else {
                    self.sendBtn.isEnabled = true
                    print("There was an error!")
                }
            })
            
        }
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension CreatePostVC: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        textView.text = ""
    }
}
