//
//  LoginVC.swift
//  breakpoint
//
//  Created by Andrew Greenough on 04/09/2017.
//  Copyright © 2017 Andrew Greenough. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {

    // Outlets
    @IBOutlet weak var emailField: InsetTextField!
    @IBOutlet weak var passwordField: InsetTextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        passwordField.delegate = self
    }

    @IBAction func signInBtnWasPressed(_ sender: Any) {
        signIn()
    }
    
    @IBAction func emailTextFieldPrimaryActionTriggered(_ sender: Any) {
        self.emailField.resignFirstResponder()
        self.passwordField.becomeFirstResponder()
    }
    @IBAction func passwordTextFieldPrimaryActionTriggered(_ sender: Any) {
        signIn()
    }
    
    func signIn() {
        if emailField.text != nil && passwordField.text != nil {
            AuthService.instance.loginUser(withEmail: emailField.text!, andPassword: passwordField.text!, loginComplete: { (success, loginError) in
                if success {
                    self.dismiss(animated: true, completion: nil)
                } else {
                    print(String(describing: loginError?.localizedDescription))
                }
                
                AuthService.instance.registerUser(withEmail: self.emailField.text!, andPassword: self.passwordField.text!, userCreationComplete: { (success, registrationError) in
                    if success {
                        AuthService.instance.loginUser(withEmail: self.emailField.text!, andPassword: self.passwordField.text!, loginComplete: { (success, nil) in
                            self.dismiss(animated: true, completion: nil)
                        })
                    } else {
                        print(String(describing: registrationError?.localizedDescription))
                    }
                })
            })
        }
    }
    
    @IBAction func closeBtnWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

extension LoginVC: UITextFieldDelegate { }
