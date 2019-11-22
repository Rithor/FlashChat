//
//  WelcomeVC.swift
//  FlashChat
//
//  Created by Vitalii on 18.11.2019.
//  Copyright © 2019 Vitalii Andrianov. All rights reserved.
//

import UIKit

class WelcomeVC: UIViewController {
    
    @IBOutlet weak var logoLabel: UILabel!
    @IBOutlet weak var logInButton: UIButton!
    @IBOutlet weak var registerButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logInButton.alpha = 0.0
        registerButton.alpha = 0.0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showLogoAndButtons()
        
    }

    //MARK: - Auxiliary Methods
    private func showLogoAndButtons() {
        logoLabel.text = "⚡️"
        var timeOffset = 0.0
        let logoString = "FlashChat"
        for char in logoString {
            Timer.scheduledTimer(withTimeInterval: 0.1 * timeOffset, repeats: false) { (timer) in
                self.logoLabel.text?.append(char)
            }
            timeOffset += 1
        }
        UIView.animate(withDuration: 0.5,
                       delay: 0.5,
                       options: .transitionCrossDissolve,
                       animations: {
                        self.logInButton.alpha = 1.0
                        self.registerButton.alpha = 1.0
        })
    }
}
