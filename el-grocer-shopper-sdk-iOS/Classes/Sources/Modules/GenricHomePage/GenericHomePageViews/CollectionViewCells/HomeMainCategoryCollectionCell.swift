//
//  HomeMainCategoryCollectionCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 25/10/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import Lottie
import SDWebImage
// import SDWebImageLottieCoder

class HomeMainCategoryCollectionCell: UICollectionViewCell {
    
    @IBOutlet var bgImageView: UIImageView!{
        didSet{
            bgImageView.alpha = 1
           // bgImageView.backgroundColor = .LightGreyBorderColor()//.navigationBarWhiteColor()
        }
    }
    
    lazy var sdanimationView: AnimationView = {
        let imageView = AnimationView()
        imageView.loopMode = .playOnce
        imageView.backgroundColor = .clear
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        sdanimationView.frame = bounds
    }
    
    @IBOutlet var lblName: UILabel!{
        didSet{
            lblName.setBody3SemiBoldDarkGreenStyle()
        }
    }
    @IBOutlet var imgArrow: UIImageView!
    @IBOutlet var imgCategory: UIImageView!{
        didSet{
            imgCategory.isHidden = true
          //  imgCategory.image = UIImage(named: "testCategoryImage")
        }
    }
    var placeholderPhoto = UIImage(name: "product_placeholder")!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.addSubview(sdanimationView)
        contentView.sendSubviewToBack(sdanimationView)
        contentView.sendSubviewToBack(bgImageView!)
        // Initialization code
        setInitialApperence()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bgImageView.sd_cancelCurrentImageLoad()
        self.bgImageView.image = UIImage()
        // sdanimationView.isHidden = true
    }
    
    func setInitialApperence(){
        self.roundWithShadow(corners: [.layerMaxXMaxYCorner , .layerMaxXMinYCorner ,.layerMinXMinYCorner ,.layerMinXMaxYCorner], radius: 8)
        self.backgroundColor = .navigationBarWhiteColor()
        
        if ElGrocerUtility.sharedInstance.isArabicSelected(){
            self.imgArrow.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func configureCell(cellType: MainCategoryCellType, title: String, image: String,_ showArrow: Bool = false , data: Any){
        
        var title: String = title
        
        var urlEn: URL? = nil
        var urlAr: URL? = nil
        var shortName: String? = nil
        var bgColor: String? = nil
        
        switch cellType {
        case .Categories:
            let storeType = data as? StoreType
            urlEn = storeType?.lottifileEnUrl
            urlAr = storeType?.lottifileArUrl
        case .Deals:
            // How to get URL
            print("Deals Cell")
        case .Featured:
            let grocery = data as? Grocery
            urlEn = grocery?.lottifileEnUrl
            urlAr = grocery?.lottifileArUrl
            shortName = grocery?.shortName
            bgColor = grocery?.bgColor
        default: break
        }
        
        let lottiUrl = LanguageManager.sharedInstance.getSelectedLocale() == "ar" ? urlAr : urlEn
                
        if let url = lottiUrl {
            Animation.loadedFrom(url: url, closure: { [weak self] animation in
                self?.sdanimationView.animation = animation
            }, animationCache:  nil)
            self.sdanimationView.play()
            if let shortName = shortName, shortName.count > 0 {
                title = shortName
            }
        }
        
        if cellType == .Featured {
            setUpAppearence(cellType: .Categories, showArrow: showArrow)
            self.lblName.text = title
            // self.backgroundColor = .navigationBarWhiteColor()
            self.setImage(imageView: self.bgImageView, imageUrl: image)
            if let bgColor = bgColor, bgColor.count > 0 {
                backgroundView?.backgroundColor = UIColor.colorWithHexString(hexString: bgColor)
            } else {
                self.backgroundView?.backgroundColor = UIColor.white
            }
        } else if cellType == .Services {
            self.configureCellForServices(title: title, data: data)
        }else if cellType == .ClickAndCollect {
            self.configureCellForClickAndCollection(title: title, imageName: image)
        }else if cellType == .Recipe {
            self.configureCellForRecipe(title: title, imageName: image)
        }else if cellType == .Categories {
            self.configureCellForCategories(title: title, false, data: data)
        }else if cellType == .ViewAllCategories {
            self.configureCellForViewAllCategories(title: title, true, data: data)
        }else if cellType == .Deals {
            self.configureCellForDeals(title: title)
        }else if cellType == .Store {
            configureCellForStores(title: title, image: image,showArrow)
            /*if let category = data as? Grocery{  } */
        }
        
        if lottiUrl != nil {
            sdanimationView.isHidden = false
            bgImageView.isHidden = true
        } else {
            sdanimationView.isHidden = true
            bgImageView.isHidden = false
        }
    }
    
    func setUpAppearence(cellType: MainCategoryCellType, showArrow: Bool){
        if cellType == .Categories {
            self.lblName.isHidden = false
            self.imgCategory.isHidden = true
            self.bgImageView.isHidden = false
            if showArrow {
                self.showViewAllArrow(true)
            }else{
                self.showViewAllArrow(false)
            }
            
        } else if cellType == .ViewAllCategories {
            self.lblName.isHidden = false
            self.showViewAllArrow(true)
            self.bgImageView.isHidden = true
            imgCategory.isHidden = true
        } else if cellType == .Store {
            self.lblName.isHidden = true
            self.imgCategory.isHidden = true
            self.bgImageView.isHidden = false
            if showArrow{
                self.lblName.isHidden = false
                self.showViewAllArrow(true)
                self.bgImageView.isHidden = true
            }else{
                self.lblName.isHidden = true
                self.showViewAllArrow(false)
            }
        }else if cellType == .Services {
            
            self.lblName.isHidden = false
            self.imgCategory.isHidden = true
            self.showViewAllArrow(false)
            self.bgImageView.isHidden = false
            
        }else if cellType == .ClickAndCollect {
            self.lblName.isHidden = false
            self.imgCategory.isHidden = true
            self.showViewAllArrow(false)
            self.bgImageView.isHidden = false
            
        }else if cellType == .Recipe {
            self.lblName.isHidden = false
            self.imgCategory.isHidden = true
            self.showViewAllArrow(false)
            self.bgImageView.isHidden = false
            
        }
    }
    
    func showViewAllArrow(_ showArrow: Bool = false){
        self.imgArrow.isHidden = !showArrow
    }
    
    func configureCellForCategories(title: String,_ showArrow: Bool = false , data : Any){
        
        setUpAppearence(cellType: .Categories, showArrow: showArrow)
        self.lblName.text = title
        self.backgroundColor = .navigationBarWhiteColor()
        if let dataObj = data as? StoreType {
            self.setImage(imageView: self.bgImageView, imageUrl: dataObj.imageUrl)
        }else {
            self.imgCategory.image = UIImage()
        }
        
        if let retailerType = data as? StoreType {
            let bgColor = retailerType.backGroundColor
            self.backgroundView?.backgroundColor = UIColor.colorWithHexString(hexString: bgColor)
        } else {
            self.backgroundView?.backgroundColor = UIColor.locationScreenLightColor()
        }
        
    }
    
    func configureCellForViewAllCategories(title: String,_ showArrow: Bool = false , data : Any){
        
        setUpAppearence(cellType: .ViewAllCategories, showArrow: showArrow)
        self.lblName.text = title
        self.backgroundColor = .replacementGreenBGColor()
        self.backgroundView?.backgroundColor  = .replacementGreenBGColor()
        self.imgCategory.image = UIImage()
        
    }
    
    func configureCellForClickAndCollection(title: String , imageName : String){
        
        setUpAppearence(cellType: .ClickAndCollect, showArrow: false)
        self.lblName.text = title
        self.bgImageView.image = UIImage(named: imageName)
        self.backgroundView?.backgroundColor = UIColor.locationScreenLightColor()
        
    }
    
    func configureCellForDeals(title: String){
        
        setUpAppearence(cellType: .ClickAndCollect, showArrow: false)
        self.lblName.text = title
        self.bgImageView.image = UIImage(name: "DealsBgImage")
        self.backgroundView?.backgroundColor = UIColor.locationScreenLightColor()
        
    }
    
    func configureCellForRecipe(title: String , imageName : String){
        
        setUpAppearence(cellType: .Recipe, showArrow: false)
        self.lblName.text = title
        self.bgImageView.image = UIImage(named: imageName)
        self.backgroundView?.backgroundColor = UIColor.locationScreenLightColor()
        
    }
    
    func configureCellForServices(title: String , data : Any? = nil){
        setUpAppearence(cellType: .Services, showArrow: false)
        self.imgArrow.isHidden = true
        self.imgCategory.isHidden = true
        self.lblName.text = title
        if let retailerType = data as? RetailerType {
            if let bgColor = retailerType.backGroundColor {
                
                self.backgroundView?.backgroundColor = UIColor.colorWithHexString(hexString: bgColor)
            } else {
                self.backgroundView?.backgroundColor = UIColor.locationScreenLightColor()
            }
            self.setImage(imageView: self.bgImageView, imageUrl: retailerType.imageUrl)
        }else {
            self.backgroundView?.backgroundColor = UIColor.locationScreenLightColor()
        }
    }
    
    func configureCellForStores(title: String,image: String,_ showArrow: Bool = false){
        setUpAppearence(cellType: .Store, showArrow: showArrow)
        self.showViewAllArrow(showArrow)
        self.bgImageView.image = UIImage(named: "testCategoryImage")
        if showArrow{
            self.lblName.text = title
            self.bgImageView.image = UIImage()
        }
    }
    
    private func setImage (imageView : UIImageView , imageUrl : String?) {
        
        if imageUrl != nil && imageUrl?.range(of: "http") != nil {
            
            imageView.sd_setImage(with: URL(string: imageUrl!), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 1), completed: {[weak self] (image, error, cacheType, imageURL) in
//                guard let self = self else {
//                    return
//                }
//                if cacheType == SDImageCacheType.none {
//                    UIView.transition(with: imageView , duration: 0.2, options:  [.transitionCrossDissolve], animations: {
//                        imageView.image = image
//                    }, completion: { (completed) in
//                    })
//                }
            })
        }else {
            imageView.image = productPlaceholderPhoto
        }
        
    }

}

