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
        
        messageView.layer.cornerRadius = 10
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
