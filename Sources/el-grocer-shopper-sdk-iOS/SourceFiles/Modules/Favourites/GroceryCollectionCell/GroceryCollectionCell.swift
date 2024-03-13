//
//  GroceryCollectionCell.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 16.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

let kGroceryCollectionCellIdentifier = "GroceryCollectionCell"
let kGroceryCollectionCellHeight: CGFloat = 110

protocol GroceryCollectionCellProtocol : class {
    
    func groceryCollectionCellDidTouchFavourite(_ groceryCell:GroceryCollectionCell, grocery:Grocery) -> Void
    func groceryCollectionCellDidTouchScore(_ groceryCell:GroceryCollectionCell, grocery:Grocery) -> Void
}

class GroceryCollectionCell : UICollectionViewCell {
    
    @IBOutlet weak var groceryPhoto: UIImageView!
    @IBOutlet weak var groceryAddress: UILabel!
    @IBOutlet weak var groceryName: UILabel!
    @IBOutlet weak var favouriteIcon: UIImageView!
    @IBOutlet weak var groceryScoreButton: UIButton!
    
    var placeholderImage = UIImage(name: "category_placeholder")!
    
    weak var grocery:Grocery!
    weak var delegate:GroceryCollectionCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpGroceryNameAppearance()
        setUpGroceryAddressAppearance()
        setUpGroceryScoreAppearance()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(GroceryCollectionCell.onFavouriteButtonClick))
        self.favouriteIcon.addGestureRecognizer(tapGesture)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.groceryPhoto.sd_cancelCurrentImageLoad()
        self.groceryPhoto.image = self.placeholderImage
    }
    
    // MARK: Appearance
    
    fileprivate func setUpGroceryNameAppearance() {
        
        self.groceryName.font = UIFont.SFProDisplaySemiBoldFont(19.0)
        self.groceryName.textColor = UIColor.white
    }
    
    fileprivate func setUpGroceryAddressAppearance() {
        
        self.groceryAddress.font = UIFont.SFProDisplayNormalFont(9.0)
        self.groceryAddress.textColor = UIColor.white
    }
    
    fileprivate func setUpGroceryScoreAppearance() {
        
        self.groceryScoreButton.layer.cornerRadius = 4
    }
    
    // MARK: Data
    
    func configureWithGrocery(_ grocery:Grocery) {
        
        self.grocery = grocery
        
        //check for favourite
        self.favouriteIcon.image = self.grocery.isFavourite.boolValue ? UIImage(name: "heart_full") : UIImage(name: "heart_empty")
        
        self.groceryName.text = grocery.name
        self.groceryAddress.text = grocery.address
                
        if let photoUrl = grocery.imageUrl {
            
            self.groceryPhoto.sd_setImage(with: URL(string: photoUrl), placeholderImage: self.placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.groceryPhoto, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.groceryPhoto.image = image
                        
                    }, completion: nil)
                }
            })
        }
        
        //review scrore
        switch self.grocery.reviewScore.intValue {
            
        case 0:
            self.groceryScoreButton.setBackgroundImage(UIImage(name: "brating-00"), for: UIControl.State())
            
        case 1:
            self.groceryScoreButton.setBackgroundImage(UIImage(name: "brating-01"), for: UIControl.State())
            
        case 2:
            self.groceryScoreButton.setBackgroundImage(UIImage(name: "brating-02"), for: UIControl.State())
            
        case 3:
            self.groceryScoreButton.setBackgroundImage(UIImage(name: "brating-03"), for: UIControl.State())
            
        case 4:
            self.groceryScoreButton.setBackgroundImage(UIImage(name: "brating-04"), for: UIControl.State())
            
        case 5:
            self.groceryScoreButton.setBackgroundImage(UIImage(name: "brating-05"), for: UIControl.State())
            
        default:
            self.groceryScoreButton.setBackgroundImage(UIImage(name: "brating-00"), for: UIControl.State())
            
        }
        
        if !grocery.isInRange.boolValue || !grocery.isOpen.boolValue {
            
            self.groceryPhoto.backgroundColor = UIColor.clear
            
            let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.dark)
            let blurEffectView = UIVisualEffectView(effect: blurEffect)
            let vibrancy = UIVibrancyEffect(blurEffect: UIBlurEffect(style: UIBlurEffect.Style.dark))
            blurEffectView.effect = vibrancy
            blurEffectView.alpha = 1.0
            blurEffectView.frame = self.groceryPhoto.bounds
            blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.groceryPhoto.addSubview(blurEffectView)
            
        }else{

            self.groceryPhoto.subviews.forEach { $0.removeFromSuperview() }
        }
    }
    
    // MARK: Actions
    
    @objc func onFavouriteButtonClick() {
        
        self.grocery.isFavourite = NSNumber(value: !self.grocery.isFavourite.boolValue as Bool)
        DatabaseHelper.sharedInstance.saveDatabase()
        self.favouriteIcon.image = self.grocery.isFavourite.boolValue ? UIImage(name: "heart_full") : UIImage(name: "heart_empty")
        
        self.delegate?.groceryCollectionCellDidTouchFavourite(self, grocery: self.grocery)
    }
    
    @IBAction func onScoreButtonClick(_ sender: AnyObject) {
        
        self.delegate?.groceryCollectionCellDidTouchScore(self, grocery: self.grocery)
    }
}
