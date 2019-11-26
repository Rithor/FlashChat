//
//  AuthorizationVC.swift
//  FlashChat
//
//  Created by Vitalii on 22.11.2019.
//  Copyright © 2019 Vitalii Andrianov. All rights reserved.
//

import UIKit
import FirebaseAuth

class AuthorizationVC: UIViewController {
    
    //MARK: - Properties
    var authButtonTitle: String?
    var viewColor: UIColor?
    var isNewUser: Bool?
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var authButton: UIButton!
    @IBOutlet fileprivate weak var passwordTextFeild: UITextField!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authButton.setTitle(authButtonTitle, for: .normal)
        view.backgroundColor = viewColor
    }
    
    //MARK: - IBActions
    @IBAction fileprivate func actionAuthButton(_ sender: Any) {
        guard let userEmail = emailTextField.text,
            let userPassword = passwordTextFeild.text,
            let isNewUser = isNewUser else { return }
        
        if isNewUser {
            createNewUser(with: userEmail, userPassword)
        } else {
            signInUser(with: userEmail, userPassword)
        }
    }
    
    //MARK: - Auxiliary Methods
    private func createNewUser(with userEmail: String, _ userPassword: String) {
        Auth.auth().createUser(withEmail: userEmail, password: userPassword) { (user, error) in
            if let regError = error {
                CommonFunc.showAlertWith(message: regError.localizedDescription, sender: self)
            } else {
                self.performSegue(withIdentifier: Constant.Segue.showChatVCIdentifire, sender: self)
            }
        }
    }
    
    private func signInUser(with userEmail: String, _ userPassword: String) {
        Auth.auth().signIn(withEmail: userEmail, password: userPassword) { [weak self] authResult, error in
            guard let strongSelf = self else { return }
            if let signInError = error {
                CommonFunc.showAlertWith(message: signInError.localizedDescription, sender: strongSelf)
            } else {
                strongSelf.performSegue(withIdentifier: Constant.Segue.showChatVCIdentifire, sender: strongSelf)
            }
        }
    }
    
}

//MARK: - UITextFieldDelegate
extension AuthorizationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailTextField {
            passwordTextFeild.becomeFirstResponder()
        } else if textField == passwordTextFeild {
            actionAuthButton(textField)
        }
        return true
    }
}
