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
    
    func formate() -> String {
        return String(format: "%.0f", self)
    }
    
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
