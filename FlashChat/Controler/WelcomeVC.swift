//
//  WelcomeVC.swift
//  FlashChat
//
//  Created by Vitalii on 18.11.2019.
//  Copyright © 2019 Vitalii Andrianov. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {
    
    //MARK: - Properties
    @IBOutlet private weak var logoLabel: UILabel!
    @IBOutlet private weak var logInButton: UIButton!
    @IBOutlet private weak var registerButton: UIButton!
    
    //MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        logInButton.alpha = 0.0
        registerButton.alpha = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAppearanceNavBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showLogoAndButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        logoLabel.text = Constant.appLogo
    }
    
    //MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let authVC = segue.destination as? AuthorizationVC else { return }
        
        switch segue.identifier {
        case Constant.Segue.showLogInVCIdentifire:
            authVC.authButtonTitle = "Log In"
            authVC.viewColor = (sender as! UIButton).backgroundColor
            authVC.isNewUser = false
        case Constant.Segue.showRegisterVCIdentifire:
            authVC.authButtonTitle = "Register"
            authVC.viewColor = (sender as! UIButton).backgroundColor
            authVC.isNewUser = true
        default: break
        }
    }
    
    //MARK: - Auxiliary Methods
    private func showLogoAndButtons() {
        logoLabel.text = Constant.appLogo
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { (timer) in
            var timeOffset = 0.1
            let logoString = Constant.appName
            for char in logoString {
                Timer.scheduledTimer(withTimeInterval: 0.1 * timeOffset, repeats: false) { (timer) in
                    self.logoLabel.text?.append(char)
                }
                timeOffset += 0.5
            }
            UIView.animate(withDuration: 0.5,
                           delay: 0.2,
                           options: .transitionCrossDissolve,
                           animations: {
                            self.logInButton.alpha = 1.0
                            self.registerButton.alpha = 1.0
            })
        }
    }
    
    private func setupAppearanceNavBar() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor.clear
        navBarAppearance.shadowColor = .clear
        navBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .title2)
        ]
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        navigationController?.navigationBar.isHidden = true
    }
    
}
