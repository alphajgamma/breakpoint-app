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
    }

    @IBAction func signOutBtnWasPressed(_ sender: Any) {
        let logoutPopup = UIAlertController(title: "Logout?", message: "Are you sure you want to logout?", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "Logout?", style: .destructive) { (buttonTapped) in
            do {
                try Auth.auth().signOut()
                let authVC = self.storyboard?.instantiateViewController(withIdentifier: "AuthVC") as? AuthVC
                self.present(authVC!, animated: true, completion: nil)
            } catch {
                print(error)
            }
        }
        logoutPopup.addAction(logoutAction)
        present(logoutPopup, animated: true, completion: nil)
    }
}

extension MeVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return allMessages.count
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        let header: UITableViewHeaderFooterView = view as! UITableViewHeaderFooterView
        header.contentView.backgroundColor = #colorLiteral(red: 0.1681650281, green: 0.1798120737, blue: 0.2130297124, alpha: 1)
        header.textLabel!.font = UIFont(name: "Menlo Regular", size: 20.0)
        header.textLabel?.textColor = #colorLiteral(red: 0.6212110519, green: 0.8334299922, blue: 0.3770503998, alpha: 1)
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
