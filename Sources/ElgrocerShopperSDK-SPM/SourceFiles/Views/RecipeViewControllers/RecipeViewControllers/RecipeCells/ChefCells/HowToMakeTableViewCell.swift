//
//  HowToMakeTableViewCell.swift
//  ElGrocerShopper
//
//  Created by Abubaker Majeed on 17/04/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let KHowToMakeTableViewCellIdentifier = "HowToMakeTableViewCell"
class HowToMakeTableViewCell: UITableViewCell {
    
    lazy var placeholderPhoto : UIImage = {
            return UIImage(name: "product_placeholder")!
    }()
    
    @IBOutlet weak var stepImage: UIImageView!
    @IBOutlet weak var topConnectedLine: UIView!
    @IBOutlet weak var topIndicatedCircle: UIView!
    @IBOutlet weak var CenterConnectedLine: UIView!
    @IBOutlet weak var BottomIndicatedCircle: UIView!
    @IBOutlet weak var lableStepText: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell (_ steps : RecipeSteps , indexPath : IndexPath , totalCount : Int) {
        
        if indexPath.row == 0 {
            setAsTopStep()
        }else if indexPath.row == totalCount-1 {
            setAsFinalSteps()
        }else{
            setAsCenterSteps()
        }
       // self.setStepsImage(steps.recipeStepImageURL , inImageView: stepImage)
        self.lableStepText.text = steps.recipeStepDetail
        
    }
    
    func setAsTopStep() -> Void {
        self.topConnectedLine.isHidden = true
         self.topIndicatedCircle.isHidden = false
         self.CenterConnectedLine.isHidden = false
         self.BottomIndicatedCircle.isHidden = true
    }
    func setAsCenterSteps() -> Void {
        self.topConnectedLine.isHidden = false
        self.topIndicatedCircle.isHidden = false
        self.CenterConnectedLine.isHidden = false
        self.BottomIndicatedCircle.isHidden = true
    }
    func setAsFinalSteps() -> Void {
        self.topConnectedLine.isHidden = false
        self.topIndicatedCircle.isHidden = false
        self.CenterConnectedLine.isHidden = false
        self.BottomIndicatedCircle.isHidden = false
    }
    
    fileprivate func setStepsImage(_ urlString : String? , inImageView : UIImageView?=nil ) {
        
        guard urlString != nil && urlString!.range(of: "http") != nil && inImageView != nil else {
            inImageView?.image = self.placeholderPhoto
            return
        }
        inImageView?.clipsToBounds = true
        inImageView!.sd_setImage(with: URL(string: urlString! ), placeholderImage: self.placeholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: { (image, error, cacheType, imageURL) in

            guard image != nil else {
                inImageView?.image = self.placeholderPhoto
                return

            }
            if cacheType == SDImageCacheType.none {
                UIView.transition(with: inImageView! , duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: { () -> Void in
                    inImageView?.image = image
                }, completion: nil)
            }
            guard error == nil else {return}
            inImageView?.image = image
            
        })
        
    }

}
