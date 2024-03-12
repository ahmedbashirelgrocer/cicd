//
//  ElgrocerStorePin.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 19/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

class ElgrocerStorePin: UIView {
    
    @IBOutlet var storeImageView: UIImageView!
    
    
    class func loadFromNib() -> ElgrocerStorePin? {
        return self.loadFromNib(withName: "ElgrocerStorePin")
    }
   
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func setImage(_ url : String?  ) {
        if url != nil && url?.range(of: "http") != nil {
            self.storeImageView.sd_setImage(with: URL(string: url!), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0) , completed: {[weak self] (image, error, cacheType, imageURL) in
                guard image != nil else {return}
                
                //self?.storeImageView.contentMode = .scaleAspectFit
                self?.storeImageView.image = image
            })
        }else{
            self.storeImageView.image = productPlaceholderPhoto
        }
    }

}
