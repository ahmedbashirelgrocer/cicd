//
//  GrocerySelectionCell.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 28.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

let kGrocerySelectionCellIdentifier = "GrocerySelectionCell"
let kGrocerySelectionCellHeight: CGFloat = 110

protocol GrocerySelectionCellProtocol : class {
    
    func grocerySelectionCellDidTouchScore(_ cell:GrocerySelectionCell) -> Void
}

class GrocerySelectionCell : UITableViewCell {
    
    @IBOutlet weak var groceryPhoto: UIImageView!
    @IBOutlet weak var groceryAddress: UILabel!
    @IBOutlet weak var groceryName: UILabel!
    @IBOutlet weak var groceryItemsCount: UILabel!
    @IBOutlet weak var groceryScoreButton: UIButton!
    
    weak var delegate:GrocerySelectionCellProtocol?
    
    var placeholderImage = UIImage(named: "category_placeholder")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpGroceryNameAppearance()
        setUpGroceryAddressAppearance()
        setUpGroceryScoreAppearance()
        setUpItemsCountAppearance()
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
        
        self.groceryAddress.font = UIFont.bookFont(9.0)
        self.groceryAddress.textColor = UIColor.white
    }
    
    fileprivate func setUpGroceryScoreAppearance() {
        
        self.groceryScoreButton.layer.cornerRadius = 4
    }
    
    fileprivate func setUpItemsCountAppearance() {
        
        self.groceryItemsCount.font = UIFont.bookFont(11.0)
        self.groceryItemsCount.textColor = UIColor.white
    }
    
    // MARK: Data
    
    func configureWithGrocery(_ grocery:Grocery, availableProducts:Int, totalProducts:Int) {

        self.groceryName.text = grocery.name
        self.groceryAddress.text = grocery.address
        
        self.groceryItemsCount.text = "\(availableProducts)/\(totalProducts) " + NSLocalizedString("grocery_items_available_label", comment: "")
        
        if grocery.smallImageUrl != nil && grocery.smallImageUrl?.range(of: "http") != nil {
            
            self.groceryPhoto.sd_setImage(with: URL(string: grocery.smallImageUrl!), placeholderImage: self.placeholderImage, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
                if cacheType == SDImageCacheType.none {
                    
                    UIView.transition(with: self.groceryPhoto, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.groceryPhoto.image = image
                        
                    }, completion: nil)
                }
            })
            
           /* self.groceryPhoto.sd_setImage(with: URL(string: grocery.imageUrl!), placeholderImage: self.placeholderImage, completed: { (image, error, cache, url) in
                
                if cache == SDImageCacheType.none {
                    
                    UIView.transition(with: self.groceryPhoto, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                        
                        self.groceryPhoto.image = image
                        
                        }, completion: nil)
                }
            })*/
        }
        
        //review scrore
        switch grocery.reviewScore.intValue {
            
        case 0:
            self.groceryScoreButton.setBackgroundImage(UIImage(named: "brating-00"), for: UIControl.State())
            
        case 1:
            self.groceryScoreButton.setBackgroundImage(UIImage(named: "brating-01"), for: UIControl.State())
            
        case 2:
            self.groceryScoreButton.setBackgroundImage(UIImage(named: "brating-02"), for: UIControl.State())
            
        case 3:
            self.groceryScoreButton.setBackgroundImage(UIImage(named: "brating-03"), for: UIControl.State())
            
        case 4:
            self.groceryScoreButton.setBackgroundImage(UIImage(named: "brating-04"), for: UIControl.State())
            
        case 5:
            self.groceryScoreButton.setBackgroundImage(UIImage(named: "brating-05"), for: UIControl.State())
            
        default:
            self.groceryScoreButton.setBackgroundImage(UIImage(named: "brating-00"), for: UIControl.State())
            
        }

    }
    
    // MARK: Actions
    
    @IBAction func onGroceryScoreButtonClick(_ sender: AnyObject) {
        
        self.delegate?.grocerySelectionCellDidTouchScore(self)
    }
    
}
