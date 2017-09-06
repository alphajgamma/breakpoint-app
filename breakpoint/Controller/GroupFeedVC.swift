//
//  GroupFeedVC.swift
//  breakpoint
//
//  Created by Andrew Greenough on 06/09/2017.
//  Copyright © 2017 Andrew Greenough. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class GroupFeedVC: UICollectionViewController {
    
    // Outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var groupTitleLbl: UILabel!
    @IBOutlet weak var membersLbl: UILabel!
    @IBOutlet weak var sendBtnView: UIView!
    @IBOutlet weak var messageTextField: InsetTextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sendBtnView.bindToKeyboard()
    }

    @IBAction func backBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendBtnWasPressed(_ sender: Any) {
    }
}
