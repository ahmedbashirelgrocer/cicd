//
//  DoubleExtension.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 08/06/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

extension Double{
    
    func formateDisplayString() -> String{
        
        return String(format: " %.2f", self)
        
    }
    
}
