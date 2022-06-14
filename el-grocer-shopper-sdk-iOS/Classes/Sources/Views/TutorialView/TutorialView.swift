//
//  TutorialView.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 15.11.2015.
//  Copyright © 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

let kIsIphone4 = UIScreen.main.bounds.height < 568

class TutorialView : UIView {
    
    enum TutorialImage : Int {
        
        case dashboard = 0
        case locations
        case categories
        case brandDetails
        case search
        case subcategories
        case groceryList
        case basket
        
        static let images = ["home-tutorial", "addresses-tutorial", "category-tutorial", "brand-toturial", "search-tutorial", "sub-catgory-tutorial", "grocery-list-tutorial", "basket-tutorial"]
    }
    
    // MARK: Properties
    
    @IBOutlet weak var tutorialImageView: UIImageView!
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addTapGesture()
    }
    
    // MARK: Instance

    class func showTutorialView(withImage image:TutorialImage) {
        
        let view = Bundle.main.loadNibNamed("TutorialView", owner: nil, options: nil)![0] as! TutorialView
        view.frame = UIScreen.main.bounds
        view.setTutorialImage(image)
        
        UIApplication.shared.keyWindow?.addSubview(view)
    }
    
    // MARK: Image

    fileprivate func setTutorialImage(_ image:TutorialImage) {
        
        if kIsIphone4 {
            
            //iphone 4 (if we have specific image - load)
            let iphone4Image = TutorialImage.images[image.rawValue] + "-iphone4"
            if let iphone4File = UIImage(named: iphone4Image) {
                
                self.tutorialImageView.image = iphone4File
                return
            }
        }
        
        let imageName = TutorialImage.images[image.rawValue]
        self.tutorialImageView.image = UIImage(named: imageName)
    }
    
    // MARK: Tap gesture
    
    fileprivate func addTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(TutorialView.onTutorialImageClick))
        self.tutorialImageView.addGestureRecognizer(tapGesture)
    }
    
    @objc func onTutorialImageClick() {
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.alpha = 0

        }, completion: { (result:Bool) -> Void in
                
            self.removeFromSuperview()
        }) 
    }
}
