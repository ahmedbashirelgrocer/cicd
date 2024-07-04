//
//  AWSegmentViewCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 24/04/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit
import SDWebImage

let kSegmentViewCellIdentifier = "SegmentViewCell"
let SegmentViewCellHeight: CGFloat = 36

class AWSegmentViewCell: UICollectionViewCell {
    
    @IBOutlet var outerView: AWView!
    @IBOutlet var segmentTitleLabel: UILabel!
    @IBOutlet var selectionLineView: UIView!
    @IBOutlet var verticalLineView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
//        self.verticalLineView.backgroundColor = UIColor(red: 222.0 / 255.0, green: 222.0 / 255.0, blue: 222.0 / 255.0, alpha: 1)
//        self.selectionLineView.backgroundColor = UIColor(red: 79.0 / 255.0, green: 166.0 / 255.0, blue: 71.0 / 255.0, alpha: 1)
        self.segmentTitleLabel.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        self.segmentTitleLabel.backgroundColor = .clear

    }
    
    func configareCellWithTitle(_ segmentTitle:String, withSelectedState isSelected: Bool, borderColor: UIColor? = nil, imageURL: String? = nil){
        
        self.outerView.layer.cornerRadius = 19 //self.outerView.layer.frame.height / 2
        
         self.selectionLineView.isHidden = true
        
         self.outerView.clipsToBounds = true //isSelected
        self.outerView.borderWidth = 0
        
        if isSelected == true {
            self.outerView.borderWidth = 2
            self.segmentTitleLabel.textColor = ApplicationTheme.currentTheme.pillSelectedTextColor
            self.outerView.borderColor = ApplicationTheme.currentTheme.pillSelectedBGColor
            self.outerView.backgroundColor = ApplicationTheme.currentTheme.pillSelectedBGColor
             
        }else{
            
            
            self.outerView.backgroundColor = ApplicationTheme.currentTheme.pillUnSelectedBGColor
            self.segmentTitleLabel.textColor = ApplicationTheme.currentTheme.pillUnSelectedTextColor
            self.outerView.borderColor = ApplicationTheme.currentTheme.pillUnSelectedBGColor
            self.outerView.borderWidth = borderColor == nil ? 0 : 1
            self.outerView.borderColor = borderColor ?? .clear
            self.outerView.backgroundColor = ApplicationTheme.currentTheme.pillUnSelectedBGColor
        }
        
        self.segmentTitleLabel.text = segmentTitle
      //  self.segmentTitleLabel.sizeToFit()
        self.segmentTitleLabel.numberOfLines = 1
        self.segmentTitleLabel.textAlignment = .center
        self.outerView.layer.shadowColor = UIColor.clear.cgColor
    }
}
