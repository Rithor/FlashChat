//
//  CommonFunc.swift
//  Flash Chat
//
//  Created by Vitaliy on 09.10.2019.
//  Copyright © 2019 London App Brewery. All rights reserved.
//

import UIKit

struct CommonFunc {
    
    static func showAlertWith(message: String, sender: UIViewController) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
        alert.addAction(okButton)
        sender.present(alert, animated: true, completion: nil)
    }
    
}
