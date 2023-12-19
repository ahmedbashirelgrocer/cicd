//
//  BasketBannerCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 28/05/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
let kBasketBannerCellIdentifier = "BasketBannerCell"
let kBasketBannerCellHeight: CGFloat = 110

protocol BasketBannerDelegate : class {
    func reOrderButtonHandlerWithIndex(_ index:NSInteger)
    //func showRecipe()
}

class BasketBannerCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var bgImgView: UIImageView!
    
    @IBOutlet weak var imageContainer: UIView!
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var reOrderButton: UIButton!
    @IBOutlet weak var containerWidth: NSLayoutConstraint!
    
    weak var delegate:BasketBannerDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backgroundColor = ApplicationTheme.currentTheme.viewWhiteBGColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.goForRecipeAction(_:)))
        self.bgImgView.addGestureRecognizer(tap)
        self.bgImgView.isUserInteractionEnabled = true
        
       // self.containerView.layer.cornerRadius = 5
        self.containerView.layer.masksToBounds = true
       // self.containerView.backgroundColor = UIColor(red: 235.0 / 255.0, green: 179.0 / 255.0, blue: 96.0 / 255.0, alpha: 0.5)
        
      //  self.bgImgView.layer.cornerRadius = 5
        self.bgImgView.layer.masksToBounds = true
        
        self.imageContainer.layer.cornerRadius = self.imageContainer.bounds.width/2
        self.imageContainer.layer.masksToBounds = true
        
        self.imgView.image =  UIImage(name: "reorder-basket")
        self.imgView.image = self.imgView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.imgView.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        
        self.titleLabel.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        self.titleLabel.textColor = UIColor.secondaryBlackColor()
        
        self.descriptionLabel.font = UIFont.SFProDisplayNormalFont(13.0)
        self.descriptionLabel.textColor = UIColor.secondaryBlackColor()
        
        self.reOrderButton.layer.cornerRadius = 5
        self.reOrderButton.layer.masksToBounds = true
        self.reOrderButton.setTitle(localizedString("reorder_banner_button_title", comment: ""), for: UIControl.State())
        self.reOrderButton.setTitleColor(ApplicationTheme.currentTheme.buttonEnableBGColor, for: UIControl.State())
        self.reOrderButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(14.0)
    }
    
    // MARK: Data
    func configureCell(_ homeFeed: Home, currentRow:NSInteger){
        self.titleLabel.text = localizedString("reorder_banner_title", comment: "")
        self.descriptionLabel.text = localizedString("reorder_banner_description", comment: "")
        self.reOrderButton.tag = 200 + currentRow
        self.bgImgView.isHidden = true
    }
    
    func configureRecipeCell(){
        

        self.titleLabel.text = localizedString("recipe_Title", comment: "").uppercased()
        self.descriptionLabel.text = localizedString("recipe_Decription", comment: "").uppercased()
        self.reOrderButton.setTitle(localizedString("banner_button_title", comment: "").uppercased(), for: .normal)
        
        
        
        self.titleLabel.textColor = .black
        self.descriptionLabel.textColor = .black
        
//        self.titleLabel.shadowColor = UIColor.black
//        self.titleLabel.shadowOffset = CGSize.init(width: 0.0, height: -0.5)
//        self.descriptionLabel.shadowColor = UIColor.black
//        self.descriptionLabel.shadowOffset = CGSize.init(width: 0.0, height: -0.5)
       
        self.titleLabel.font = UIFont.SFProDisplayBoldFont(18.4)
        self.descriptionLabel.font = UIFont.SFProDisplayNormalFont(10)
        self.reOrderButton.titleLabel?.font = UIFont.SFProDisplayBoldFont(13.5)
        
        self.reOrderButton.layer.cornerRadius = 12
        self.reOrderButton.layer.masksToBounds = true
        self.reOrderButton.setTitleColor(UIColor.white, for: UIControl.State())
        
        self.reOrderButton.tag = 200 + 0
        self.bgImgView.image = UIImage(name: "product_placeholder")
        self.imageContainer.isHidden = true
        self.containerWidth.constant = 0
        self.imageContainer.layoutIfNeeded()
        self.imageContainer.setNeedsLayout()
        
//        let strokeTextAttributes: [NSAttributedString.Key : Any] = [
//            NSAttributedString.Key.strokeColor : UIColor.black,
//            NSAttributedString.Key.foregroundColor : UIColor.white,
//            NSAttributedString.Key.strokeWidth : -4.0,
//            ]
//
//        self.titleLabel.attributedText = NSAttributedString(string: self.titleLabel.text! , attributes: strokeTextAttributes)
//        self.descriptionLabel.attributedText = NSAttributedString(string: self.descriptionLabel.text! , attributes: strokeTextAttributes)
        
    }
    @objc func goForRecipeAction(_ gesture : UITapGestureRecognizer){
        // 200 tag for button // old shit logic
         self.delegate?.reOrderButtonHandlerWithIndex(0)
    }
    @IBAction func reOrderHandler(_ sender: Any) {
        let button = sender as! UIButton
        let index = button.tag - 200
        self.delegate?.reOrderButtonHandlerWithIndex(index)
    }
    
}
