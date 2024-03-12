//
//  ElGrocerGradientView.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 25/04/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class ElGrocerGradientView: UIView {

    
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
        self.fadeView(style: .bottom, percentage: 1)
    }
    

}
