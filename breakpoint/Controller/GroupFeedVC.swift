//
//  GroupFeedVC.swift
//  breakpoint
//
//  Created by Andrew Greenough on 06/09/2017.
//  Copyright © 2017 Andrew Greenough. All rights reserved.
//

import UIKit
import Firebase

class GroupFeedVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupTitleLbl: UILabel!
    @IBOutlet weak var membersLbl: UILabel!
    @IBOutlet weak var sendBtnView: UIView!
    @IBOutlet weak var messageTextField: InsetTextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    // Variables
    var group: Group?
    var groupMessages = [Message]()
    
    func initData(forGroup group: Group) {
        self.group = group
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        sendBtnView.bindToKeyboard()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        groupTitleLbl.text = group?.groupTitle
        DataService.instance.getEmails(forGroup: group!) { (returnedEmails) in
            self.membersLbl.text = returnedEmails.joined(separator: ", ")
        }
        DataService.instance.REF_GROUPS.observe(.value) { (snapshot) in
            DataService.instance.getAllMessagesFor(desiredGroup: self.group!, handler: { (returnedGroupMessages) in
                self.groupMessages = returnedGroupMessages
                self.tableView.reloadData()
                
                if self.groupMessages.count > 0 {
                    self.tableView.scrollToRow(at: IndexPath(row: self.groupMessages.count - 1, section: 0), at: UITableViewScrollPosition.none, animated: true)
                }
            })
        }
    }

    @IBAction func backBtnWasPressed(_ sender: Any) {
        dismissDetail()
    }
    
    @IBAction func sendBtnWasPressed(_ sender: Any) {
        if messageTextField.text != "" {
            messageTextField.isEnabled = false
            sendBtn.isEnabled = false
            DataService.instance.uploadPost(withMessage: messageTextField.text!, forUID: (Auth.auth().currentUser?.uid)!, withGroupKey: group?.key, sendComplete: { (complete) in
                if complete {
                    self.messageTextField.text = ""
                    self.messageTextField.isEnabled = true
                    self.sendBtn.isEnabled = true
                }
            })
        }
    }
}

extension GroupFeedVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupMessages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "groupFeedCell", for: indexPath) as? GroupFeedCell else { return UITableViewCell()}
        let message = groupMessages[indexPath.row]
        
        DataService.instance.getUser(forUID: message.senderId) { (returnedUser) in
            let email  = returnedUser.childSnapshot(forPath: "email").value as? String
            if let profileImageURL = returnedUser.childSnapshot(forPath: "profileImageURL").value as? String {
                cell.configureCell(profileImageURL: profileImageURL, email: email!, content: message.content)
            } else {
                cell.configureCell(profileImageURL: "", email: email!, content: message.content)
            }
        }
        return cell
    }
}
