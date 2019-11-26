//
//  Validate.swift
//  ToDoey
//
//  Created by Vitaliy on 25.10.2019.
//  Copyright © 2019 VitaliyAndrianov. All rights reserved.
//

import Foundation

struct Validation {
    
    //name isn't empty and isn't be white space only
    static func isValidateString(_ testString: String) -> Bool {
        return testString.rangeOfCharacter(from: .alphanumerics) == nil ? false : true
    }
    
}
