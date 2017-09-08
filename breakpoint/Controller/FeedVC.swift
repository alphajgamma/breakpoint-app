//
//  FeedVC.swift
//  breakpoint
//
//  Created by Andrew Greenough on 04/09/2017.
//  Copyright © 2017 Andrew Greenough. All rights reserved.
//

import UIKit

class FeedVC: UIViewController {
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    
    // Variables
    var messageArray = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DataService.instance.getAllFeedMessages { (returnedMessagesArray) in
            self.messageArray = returnedMessagesArray.reversed()
            self.tableView.reloadData()
        }
    }
    
}

extension FeedVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messageArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier:"feedCell") as? FeedCell else { return UITableViewCell() }
        let message = messageArray[indexPath.row]
        
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

