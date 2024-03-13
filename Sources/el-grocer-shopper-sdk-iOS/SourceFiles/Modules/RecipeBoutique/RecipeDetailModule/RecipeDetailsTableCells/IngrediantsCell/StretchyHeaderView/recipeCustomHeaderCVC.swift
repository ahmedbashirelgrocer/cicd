//
//  recipeCustomHeaderCVC.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 25/03/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

class recipeCustomHeaderCVC: UICollectionViewCell {
    
    @IBOutlet var imageView: UIImageView!{
        didSet{
            imageView.clipsToBounds = true
        }
    }
    @IBOutlet var gradientView: UIView!{
        didSet{
            gradientView.alpha = 0.56
            gradientView.clipsToBounds = true
            
        }
    }
    var playClicked: (()->Void)?
    @IBOutlet var btnPlay: UIButton!
  
    let gradientLayer = CAGradientLayer()
    
    @IBAction func playHandler(_ sender: Any) {
        if let clouser = self.playClicked {
            clouser()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //setUpInitialAppearence()
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setUpInitialAppearence()
    }
    
    func setUpInitialAppearence(){
        //gradientView.frame = self.bounds
        //gradientView.layoutIfNeeded()
        
        gradientView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        gradientView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        gradientView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        gradientView.fadeView(style: .bottom, percentage: 1)
        
    }
    
    func configureCell(recipeImage : String){
        
        if recipeImage != ""{
            self.setImage(recipeImage, inImageView: self.imageView)
        }
        
    }
    
    fileprivate func setImage(_ urlString : String? , inImageView : UIImageView?=nil ) {
        
        guard urlString != nil && urlString!.range(of: "http") != nil && inImageView != nil else {
            return
        }
        inImageView?.clipsToBounds = true
        
        
        
        inImageView!.sd_setImage(with: URL(string: urlString! ), placeholderImage: productPlaceholderPhoto , options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in
            guard error == nil else {return}
            if cacheType == SDImageCacheType.none {
                UIView.transition(with: inImageView! , duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                    inImageView?.image = image
                }, completion: nil)
            }
//            guard error == nil else {return}
//            inImageView?.image = image
            
        })
        
    }
}
