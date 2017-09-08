//
//  MeVC.swift
//  breakpoint
//
//  Created by Andrew Greenough on 04/09/2017.
//  Copyright © 2017 Andrew Greenough. All rights reserved.
//

import UIKit
import Firebase

class MeVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    // Variables
    var feedMessagesArray = [Message]()
    var groupsArray = [Group]()
    var groupMessagesArray = [Message]()
    var groupTitlesArray = [String]()
    var allMessages = [String: [Message]]()
    var profileImageURL = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.emailLbl.text = Auth.auth().currentUser?.email
        feedMessagesArray = []
        groupsArray = []
        groupMessagesArray = []
        DataService.instance.getAllFeedMessages { (returnedMessagesArray) in
            self.allMessages["_feed"] = returnedMessagesArray.reversed().filter({ $0.senderId == Auth.auth().currentUser?.uid })
            self.tableView.reloadData()
        }
        DataService.instance.REF_GROUPS.observe(.value) { (snapshot) in
            DataService.instance.getAllGroups { (returnedGroupsArray) in
                self.groupsArray = returnedGroupsArray
                for group in self.groupsArray {
                    DataService.instance.REF_GROUPS.observe(.value) { (snapshot) in
                        DataService.instance.getAllMessagesFor(desiredGroup: group, handler: { (returnedGroupMessages) in
                            self.allMessages[group.groupTitle] = returnedGroupMessages
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        }
        DataService.instance.REF_USERS.observe(.value) { (snapshot) in
            DataService.instance.getUser(forUID: (Auth.auth().currentUser?.uid)!, handler: { (returnedUser) in
                if let profileImageURL = returnedUser.childSnapshot(forPath: "profileImageURL").value as? String {
                    self.profileImageURL = profileImageURL
                    DataService.instance.setProfileImage(forImageView: self.profileImage, withprofileImageURL: profileImageURL)
                }
            })
        }
        
    }

    @IBAction func changePictureBtnWasPressed(_ sender: Any) {
        let changePicturePopup = UIAlertController(title: "Change Profile Image", message: "Take or Select an image?", preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { (buttonTapped) in
                self.captureProfileImage(sourceType: .camera)
            }
            changePicturePopup.addAction(cameraAction)
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            let selectPictureAction = UIAlertAction(title: "Select From Library", style: .default) { (buttonTapped) in
                self.captureProfileImage(sourceType: .photoLibrary)
            }
            changePicturePopup.addAction(selectPictureAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        changePicturePopup.addAction(cancelAction)
        if changePicturePopup.actions.count > 1 {
            present(changePicturePopup, animated: true, completion: nil)
        } else {
            let errorAlert = UIAlertController(title: "Error", message: "There are no available source types to get an image", preferredStyle: .alert)
            present(errorAlert, animated: true, completion: nil)
        }
    }
    
    func captureProfileImage(sourceType: UIImagePickerControllerSourceType){
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        if imagePicker.sourceType == .camera {
            imagePicker.cameraDevice = .front
        }
        imagePicker.allowsEditing = true
        imagePicker
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func signOutBtnWasPressed(_ sender: Any) {
        let logoutPopup = UIAlertController(title: "Logout?", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout?", style: .destructive) { (buttonTapped) in
            do {
                try Auth.auth().signOut()
                let defaultProfileImage = UIImage(named: "defaultProfileImage")
                self.profileImage.image = defaultProfileImage
                let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
                self.present(authVC!, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        logoutPopup.addAction(logoutAction)
        logoutPopup.addAction(cancelAction)
        present(logoutPopup, animated: true, completion: nil)
    }
}

extension MeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return allMessages.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = #colorLiteral(red: 0.168627451, green: 0.1803921569, blue: 0.2117647059, alpha: 1)
        header.textLabel!.font = UIFont(name: "Menlo Regular", size: 20.0)
        header.textLabel?.textColor = #colorLiteral(red: 0.6196078431, green: 0.8352941176, blue: 0.3764705882, alpha: 1)
        header.textLabel?.numberOfLines = 1
        header.textLabel?.text = header.textLabel!.text!.lowercased()
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionTitles = Array(allMessages.keys)
        return sectionTitles[section]
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionTitles = Array(allMessages.keys)
        guard let messagesInSection = allMessages[sectionTitles[section]] else { return 0 }
        return messagesInSection.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "meFeedCell") as? MeFeedCell else { return UITableViewCell()}
        let sectionTitles = Array(allMessages.keys)
        let messagesInSection = allMessages[sectionTitles[indexPath.section]]!
        cell.configureCell(messageContent: messagesInSection[indexPath.row].content)
        return cell
    }
}

extension MeVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = UIImage()
        if picker.sourceType == .camera {
            let capturedImage =  info[UIImagePickerControllerEditedImage] as! UIImage
            let flippedImage = capturedImage.imageFlippedForRightToLeftLayoutDirection()
            image = flippedImage
        } else {
            image = info[UIImagePickerControllerEditedImage] as! UIImage
        }
        self.profileImage.image = image
        DataService.instance.uploadProfileImage(withImage: image, andOldProfileImageURL: self.profileImageURL) { (uploadComplete) in
            if uploadComplete {
                self.dismiss(animated:true, completion: nil)
            } else {
                print("error uploading file")
            }
        }
    }
}
