//
//  MessageCell.swift
//  FlashChat
//
//  Created by Vitalii on 23.11.2019.
//  Copyright © 2019 Vitalii Andrianov. All rights reserved.
//

import UIKit

class MessageCell: UITableViewCell {
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var rightAvaterView: UIView!
    @IBOutlet weak var leftAvatarView: UIView!
    @IBOutlet weak var leftAvatarLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        messageView.layer.cornerRadius = messageView.frame.height / 3
        leftAvatarView.layer.cornerRadius = leftAvatarView.frame.height / 2
        rightAvaterView.layer.cornerRadius = rightAvaterView.frame.height / 2
    }
    
    func configureForCurrentUser() {
        self.leftAvatarView.isHidden = true
        self.rightAvaterView.isHidden = false
        self.messageLabel.textColor = Constant.Color.brandMintDarkColor
        self.messageView.backgroundColor = Constant.Color.brandMintDarkColor?.withAlphaComponent(0.1)
    }
    
    func configureForAnotherUser() {
        self.leftAvatarView.isHidden = false
        self.rightAvaterView.isHidden = true
        self.messageView.backgroundColor = Constant.Color.brandMintDarkColor
        self.messageLabel.textColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
}
