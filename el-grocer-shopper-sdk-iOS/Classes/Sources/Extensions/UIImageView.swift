//
//  UIImageView.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 24/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

extension UIImageView {
    
    
    func assignImage(imageUrl: String?){
        
        guard let imageUrl = imageUrl else {
            self.image = productPlaceholderPhoto
            return
        }
        if  imageUrl.range(of: "http") != nil {
            self.sd_setImage(with: URL(string: imageUrl), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    self.image = image
                }
            })
        } else {
            self.image = productPlaceholderPhoto
        }
        
    }
    
    
}
