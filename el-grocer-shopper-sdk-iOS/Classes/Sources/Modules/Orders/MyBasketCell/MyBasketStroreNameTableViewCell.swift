//
//  MyBasketStroreNameTableViewCell.swift
//  ElGrocerShopper
//
//  Created by Salman on 29/12/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class MyBasketStroreNameTableViewCell: UITableViewCell {

    @IBOutlet var imageGrocery: UIImageView! {
        didSet {
            imageGrocery.backgroundColor = .navigationBarWhiteColor()
        }
    }
    @IBOutlet var lblGrocery: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setGrocery(grocery : Grocery?) {
        guard grocery != nil else {
            return
        }
        self.lblGrocery.text = grocery?.name ?? ""
        if grocery?.smallImageUrl != nil && grocery?.smallImageUrl?.range(of: "http") != nil {
            self.setGroceryImage(grocery!.smallImageUrl!)
        }else{
            self.imageGrocery.image = productPlaceholderPhoto
        }
    }
    
    fileprivate func setGroceryImage(_ urlString : String) {
        
        self.imageGrocery.sd_setImage(with: URL(string: urlString ), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
            guard let self = self else {
                return
            }
            if cacheType == SDImageCacheType.none {
                
                UIView.transition(with: self.imageGrocery, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                    guard let self = self else {
                        return
                    }
                    self.imageGrocery.image = image
                    }, completion: nil)
                
            }
        })
        
    }
}
