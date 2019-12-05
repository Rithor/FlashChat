//
//  AuthorizationVC.swift
//  FlashChat
//
//  Created by Vitalii on 22.11.2019.
//  Copyright © 2019 Vitalii Andrianov. All rights reserved.
//

import UIKit

class AuthorizationVC: UIViewController {
    
    //MARK: - Properties
    private let networkServise = NetworkService()
    var authButtonTitle: String?
    var viewColor: UIColor?
    var isNewUser: Bool?
    
    @IBOutlet private weak var emailTextField: UITextField!
    @IBOutlet private weak var passwordTextFeild: UITextField!
    @IBOutlet private weak var authButton: UIButton!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        authButton.setTitle(authButtonTitle, for: .normal)
        view.backgroundColor = viewColor
    }
    
    //MARK: - IBActions
    @IBAction private func actionAuthButton(_ sender: Any) {
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
        networkServise.createNewUser(with: userEmail, userPassword) { (user, error) in
            if let regError = error {
                CommonFunc.showAlertWith(message: regError.localizedDescription, sender: self)
            } else {
                self.performSegue(withIdentifier: Constant.Segue.showChatVCIdentifire, sender: self)
            }
        }
    }
    
    private func signInUser(with userEmail: String, _ userPassword: String) {
        networkServise.signInUser(with: userEmail, userPassword) { [weak self] (result, error) in
            guard let weakSelf = self else { return }
            if let signInError = error {
                CommonFunc.showAlertWith(message: signInError.localizedDescription, sender: weakSelf)
            } else {
                weakSelf.performSegue(withIdentifier: Constant.Segue.showChatVCIdentifire, sender: weakSelf)
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
