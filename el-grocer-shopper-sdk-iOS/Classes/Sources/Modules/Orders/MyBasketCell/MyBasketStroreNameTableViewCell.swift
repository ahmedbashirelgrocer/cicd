//
//  MyBasketStroreNameTableViewCell.swift
//  ElGrocerShopper
//
//  Created by Salman on 29/12/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

class MyBasketStroreNameTableViewCell: UITableViewCell {

    @IBOutlet var imageGrocery: UIImageView! {
        didSet {
            imageGrocery.backgroundColor = .navigationBarWhiteColor()
        }
    }
    @IBOutlet weak var returnToStoreStackView: UIStackView!
    @IBOutlet var lblGrocery: UILabel!
    @IBOutlet weak var buttonReturnToStore: UIButton! {
        didSet {
            buttonReturnToStore.setCaption1SemiBoldGreenStyle()
        }
    }
    
    @IBOutlet weak var buttonAddProduct: UIButton!
    @IBOutlet weak var ivUndo: UIImageView!
    
    var returnToStoreHandler: (()->())?
    var addProductHandler: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        buttonReturnToStore.setTitle(localizedString("return_to_store_text", comment: ""), for: .normal)
        let undoIcon = UIImage(name: "undo")?.withRenderingMode(.alwaysTemplate)
        ivUndo.image = undoIcon
        ivUndo.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        
        // Add product button configuration
        buttonAddProduct.setTitle(localizedString("add_product_button_text", comment: ""), for: .normal)
        buttonAddProduct.layer.cornerRadius = 20.0
        buttonAddProduct.setBody3BoldWhiteStyle()
        buttonAddProduct.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setGrocery(grocery : Grocery?, editOrder: Bool = UserDefaults.isOrderInEdit()) {
        guard grocery != nil else {
            return
        }
        self.lblGrocery.text = grocery?.name ?? ""
        if grocery?.smallImageUrl != nil && grocery?.smallImageUrl?.range(of: "http") != nil {
            self.setGroceryImage(grocery!.smallImageUrl!)
        }else{
            self.imageGrocery.image = productPlaceholderPhoto
        }
        
        returnToStoreStackView.isHidden = editOrder
        buttonAddProduct.isHidden = !editOrder
        buttonAddProduct.visibility = editOrder ? .visible : .goneX
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
    
    @IBAction func returnToStoreTapped(_ sender: Any) {
        if let returnToStoreHandler = self.returnToStoreHandler {
            returnToStoreHandler()
        }
    }
    
    @IBAction func addProductTapped(_ sender: Any) {
        if let addProductHandler = self.addProductHandler {
            addProductHandler()
        }
    }
    
}
