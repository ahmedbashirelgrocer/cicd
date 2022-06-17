//
//  ChefDataCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 16/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let KChefDataReuseIdentifier : String  = "ChefDataCollectionViewCell"
let kChefCellHeight: CGFloat = 103
let kChefCellWidth: CGFloat = 88
class ChefDataCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var avatarChef: AWImageView!{
        didSet{
            avatarChef.backgroundColor = .navigationBarWhiteColor()
            
        }
    }
    @IBOutlet weak var lblChefName: UILabel!
    lazy var placeholderPhoto : UIImage = {
        return UIImage(name: "product_placeholder")!
    }()
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setUpApearance() {
        self.avatarChef.cornarRadius = 8
//        self.avatarChef.shadowRadius = 4
//        self.avatarChef.shadowOffset = CGSize(width: 0, height: 2)
//        self.avatarChef.shadowColor = UIColor.newBlackColor()
//        self.avatarChef.shadowOpacity = 0.16
        self.avatarChef.clipsToBounds = true
        
    }
    
    func configureCell (_ cellChef : CHEF) {
       
        self.lblChefName.text = cellChef.chefName
        if cellChef.chefImageURL != nil && cellChef.chefImageURL?.range(of: "http") != nil {
            self.setChefAvatar(cellChef.chefImageURL!)
        }else{
            self.avatarChef.image = self.placeholderPhoto
        }

    }
    
    fileprivate func setChefAvatar(_ urlString : String) {
    
    self.avatarChef.sd_setImage(with: URL(string: urlString ), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
    guard let self = self else {
    return
    }
    if cacheType == SDImageCacheType.none {
    
    UIView.transition(with: self.avatarChef, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
    guard let self = self else {
    return
    }
    self.avatarChef.image = image
    }, completion: nil)
    
    }
        self.setUpApearance()
    })
    
    }
    

}
