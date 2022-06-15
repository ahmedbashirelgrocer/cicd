//
//  GroceryNewCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let KGroceryNewCollectionViewCell = "GroceryNewCollectionViewCell"
let KGroceryNewCollectionViewCellHeight = 173
class GroceryNewCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var lblDate: UILabel!
    @IBOutlet var lblMinOrder: UILabel!
    @IBOutlet var groceryImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureGroceryCell(_ grocery : Grocery) {
        self.setImage(grocery.smallImageUrl)
        self.setMinOrder(minOrderValue:  String(format: "%@ %.0f",CurrencyManager.getCurrentCurrency(),grocery.minBasketValue))
        self.setDeliveryDate(grocery.genericSlot ?? "")
    }
    
    func setDeliveryDate (_ data : String) {
        
        let dataA = data.components(separatedBy: CharacterSet.newlines)
        var attrs1 = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Light", size: 11) , NSAttributedString.Key.foregroundColor : self.lblDate.textColor ]
        if dataA.count == 1 {
            if self.lblDate.text?.count ?? 0 > 13 {
                attrs1 = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Light", size: 9) , NSAttributedString.Key.foregroundColor : self.lblDate.textColor ]
                 let attributedString1 = NSMutableAttributedString(string: dataA[0], attributes:attrs1 as [NSAttributedString.Key : Any])
                 self.lblDate.attributedText = attributedString1
                return
            }
        }
        let attrs2 = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Semibold", size: 11) , NSAttributedString.Key.foregroundColor : self.lblDate.textColor]
        
        let attributedString1 = NSMutableAttributedString(string:dataA[0], attributes:attrs1 as [NSAttributedString.Key : Any])
        let timeText = dataA.count > 1 ? dataA[1] : ""
        let attributedString2 = NSMutableAttributedString(string:"\n\(timeText)", attributes:attrs2 as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)
        self.lblDate.attributedText = attributedString1
        
        self.lblDate.minimumScaleFactor = 0.5;
        
    }
    
    func setMinOrder (minOrderValue : String) {
        
        
        let attrs1 = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Light", size: 11) , NSAttributedString.Key.foregroundColor : self.lblDate.textColor ]
        
        let attrs2 = [NSAttributedString.Key.font : UIFont(name: "SFProDisplay-Semibold", size: 11) , NSAttributedString.Key.foregroundColor : self.lblDate.textColor]
        
        
        let attributedString1 = NSMutableAttributedString(string: NSLocalizedString("lbl_MinOrder", comment: "") , attributes:attrs1 as [NSAttributedString.Key : Any])
        
        let attributedString2 = NSMutableAttributedString(string:"\n\(minOrderValue)", attributes:attrs2 as [NSAttributedString.Key : Any])
        
        attributedString1.append(attributedString2)
        self.lblMinOrder.attributedText = attributedString1
        
    }
    
    func setImage(_ url : String? ) {
        if url != nil && url?.range(of: "http") != nil {
            
            self.groceryImage.sd_setImage(with: URL(string: url!), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 7), completed: {[weak self] (image, error, cacheType, imageURL) in
               // debugPrint("Imagese: \(self)")
//                if cacheType == SDImageCacheType.none {
//                    self?.groceryImage.image = image
//
//                    debugPrint("Imagese: Cached: lfconsition \(imageURL)")
//                }else{
//                    debugPrint("Imagese: elseChache: lfconsition \(imageURL)")
//                }
                self?.setAspects()
                self?.layoutIfNeeded()
            })
        }
    }
    func setAspects() {
        
        groceryImage.contentMode = .scaleAspectFit
        
//        if let image  = resizeImage(groceryImage.image, size: groceryImage.frame.size) {
//            groceryImage.contentMode = .center
//            groceryImage.image = image
//        }else{
//            groceryImage.contentMode = .scaleAspectFit
//        }

    }
    
    func resizeImage(_ image : UIImage? , size : CGSize ) -> UIImage? {
        guard image != nil else {return image}
        UIGraphicsBeginImageContext(size);
        image!.draw(in: CGRect.init(x: 0, y: 0, width: size.width, height: size.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return newImage;
    }
    

}
