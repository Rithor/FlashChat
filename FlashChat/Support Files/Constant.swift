//
//  Constant.swift
//  FlashChat
//
//  Created by Vitalii on 24.11.2019.
//  Copyright © 2019 Vitalii Andrianov. All rights reserved.
//

import UIKit

struct Constant {
    
    private init() {}
    
    static let appName = "FlashChat"
    static let appNameWithLogo = "⚡️FlashChat"
    static let appLogo = "⚡️"
    static let messageCornerRadius: CGFloat = 5.0
    
    static let messageCellIdentifire = "messageCell"
    
    struct Color {
        static let brandMintDarkColor = UIColor.init(named: "brandMintDark")
        static let brandMintLightColor = UIColor.init(named: "brandMintLight")
    }
    
    struct Segue {
        static let showLogInVCIdentifire = "showLogInVC"
        static let showRegisterVCIdentifire = "showRegisterVC"
        static let showChatVCIdentifire = "showChatVC"
    }
    
    struct FBase {
        static let collectionName = "messages"
        static let bodyField = "body"
        static let senderField = "sender"
        static let dateFeild = "date"
    }
    
    struct Constraint {
        static let defaultBottomViewHeight: CGFloat = 60.0
        static let defaultTextViewHeight: CGFloat = 38.0
    }
    
}
