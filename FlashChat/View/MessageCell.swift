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
    
}
