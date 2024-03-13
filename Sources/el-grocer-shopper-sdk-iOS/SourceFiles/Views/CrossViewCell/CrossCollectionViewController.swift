//
//  CrossCollectionViewController.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 11/12/2019.
//  Copyright © 2019 elGrocer. All rights reserved.
//

import UIKit

let kCrossCollectionCellIdentifier = "CrossCOllection"

enum crossActionState: Int {
    case redBorder = 0
    case WhiteBorder = 1
    
}



class CrossCollectionViewController: UICollectionViewCell {
    
    @IBOutlet weak var lblRemoveItem: UILabel!{
        didSet{
            lblRemoveItem.setBody2RegDarkStyle()
        }
    }
    var removeItemFromSubSitute : (()->Void)?
    
    var cellState : crossActionState? = .redBorder {
        didSet {
            self.setBGBorderColor(self.cellState ?? .WhiteBorder)
        }
    }

    @IBOutlet weak var bgImage: UIImageView!
    @IBOutlet weak var bgView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.lblRemoveItem.text = localizedString("remove_Item_button_title", comment: "")
    }
    fileprivate func setBGBorderColor (_ state : crossActionState) {
        
        
        if state == .redBorder {
            self.bgView.layer.borderColor = UIColor.red.cgColor
            self.bgImage.backgroundColor = .white
            self.bgImage.alpha = 0.7
        }else  if state == .WhiteBorder {
            
            self.bgView.layer.borderColor = UIColor.white.cgColor
            self.bgImage.image = UIImage(name: "NoAlternative")
            self.bgImage.alpha = 1.0
        }
       
        self.bgImage.layer.cornerRadius = 5
        self.bgView.layer.cornerRadius = 5
        self.bgView.layer.borderWidth = 1.8
        
        
        
    }

    @IBAction func removeClick(_ sender: Any) {
        if let clouser = self.removeItemFromSubSitute {
            clouser()
        }
       
    }
}
