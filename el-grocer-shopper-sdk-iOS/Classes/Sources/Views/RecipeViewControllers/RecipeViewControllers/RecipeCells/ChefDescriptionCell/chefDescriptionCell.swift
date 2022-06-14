//
//  chefDescriptionCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 13/04/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

let kChefDescriptionCell : CGFloat = 100

class chefDescriptionCell: UITableViewCell {

    @IBOutlet var chefImage: UIImageView!{
        didSet{
            chefImage.layer.cornerRadius = 4
            chefImage.backgroundColor = .navigationBarWhiteColor()
            
        }
    }
    @IBOutlet var lblChefName: UILabel!{
        didSet{
            lblChefName.setH3SemiBoldDarkStyle()
        }
    }
    @IBOutlet var lblChefDescription: UILabel!{
        didSet{
            lblChefDescription.setBody3RegDarkStyle()
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configCell(chef : CHEF){
        lblChefName.text = chef.chefName
        lblChefDescription.text = chef.chefDescription
        self.setImage(chef.chefImageURL, inImageView: chefImage)
    }

    fileprivate func setImage(_ urlString : String? , inImageView : UIImageView?=nil ) {

        guard urlString != nil && urlString!.range(of: "http") != nil && inImageView != nil else {
            return
        }
        inImageView?.clipsToBounds = true



        inImageView!.sd_setImage(with: URL(string: urlString! ), placeholderImage: productPlaceholderPhoto , options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in

            if cacheType == SDImageCacheType.none {
                UIView.transition(with: inImageView! , duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                    inImageView?.image = image
                }, completion: nil)
            }
            guard error == nil else {return}
            inImageView?.image = image

        })

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
