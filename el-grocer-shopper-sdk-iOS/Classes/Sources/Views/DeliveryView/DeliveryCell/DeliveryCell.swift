//
//  DeliveryCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 25/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

protocol DeliveryCellProtocol : class {
    
    func tickButtonTapped(_ buttonIndex:Int)
    func crossButtonTapped(_ buttonIndex:Int)
}

let kDeliveryCellIdentifier = "DeliveryCell"
let kDeliveryCellHeight: CGFloat = 40

let tickButtonOffset: Int = 45000
let crossButtonOffset: Int = 55000

class DeliveryCell: UITableViewCell {
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var tickButton: UIButton!
    @IBOutlet var crossButton: UIButton!
    
     weak var delegate:DeliveryCellProtocol?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        setUpLabelAppearance()
    }
    
    // MARK: Appearance
    fileprivate func setUpLabelAppearance(){
                
        self.titleLabel.font = UIFont.bookFont(12.0)
        self.titleLabel.textColor = UIColor.darkGrayTextColor()
        self.titleLabel.sizeToFit()
        self.titleLabel.numberOfLines = 0
        
    }
    
    // MARK: Data
    
    func configureCellWithTitle(_ title: String, andWithSelectedIndex sIndex:Int) {
        
        self.titleLabel.text = title
        
        self.tickButton.tag = sIndex + tickButtonOffset
        self.crossButton.tag = sIndex + crossButtonOffset
    }
    
    // MARK: Button Action Handlers
    
    @IBAction func tickButtonHandler(_ sender: AnyObject) {
       
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
        let corssButtonIndex = (button.tag - tickButtonOffset) + crossButtonOffset
        
        
        if let crossButtonWithTag = self.viewWithTag(corssButtonIndex) as? UIButton {
               crossButton = crossButtonWithTag
            if crossButton.isSelected == true {
                crossButton.isSelected = false
            }
        }

        self.delegate?.tickButtonTapped(button.tag)
        
        
       /* let corssButtonIndex = (button.tag - tickButtonOffset) + crossButtonOffset
        let tempCrossButton = self.viewWithTag(corssButtonIndex) as! UIButton
        if tempCrossButton.selected == true {
            tempCrossButton.selected = false
        }*/
    }
    
    @IBAction func crossButtonHandler(_ sender: AnyObject) {
        
        let button = sender as! UIButton
        button.isSelected = !button.isSelected
        
        let tickButtonIndex = (button.tag - crossButtonOffset) + tickButtonOffset
        if let thickButtonWithTag = self.viewWithTag(tickButtonIndex) as? UIButton {
                tickButton = thickButtonWithTag
            if  tickButton.isSelected == true {
                tickButton.isSelected = false
            }
        }
       
        
        self.delegate?.crossButtonTapped(button.tag)
        
        /*let tickButtonIndex = (button.tag - crossButtonOffset) + tickButtonOffset
        let tempTickButton = self.viewWithTag(tickButtonIndex) as! UIButton
        if tempTickButton.selected == true {
            tempTickButton.selected = false
        }*/
    }
    
}
