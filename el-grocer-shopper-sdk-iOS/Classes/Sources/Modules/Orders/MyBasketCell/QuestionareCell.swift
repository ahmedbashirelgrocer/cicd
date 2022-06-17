//
//  QuestionareCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 28/07/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

let QuestionareCellHeight : CGFloat = 48

class QuestionareCell: UITableViewCell {
    
    

    @IBOutlet var actionButton: UIButton!
    @IBOutlet var radiioImage: UIImageView!
    @IBOutlet var lblOption: UILabel!{
        didSet{
            lblOption.setH4RegDarkStyle()
            lblOption.textAlignment = .natural
        }
    }
    var reason : Reasons?
    var indexPath : IndexPath?
    var buttonClicked : ((_ cellSelectedReason : Reasons? , _ selectIndexPath : IndexPath?) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setAppearace()
    }
    
    func setAppearace(){
        self.selectionStyle = .none
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.lblOption.textAlignment = .right
        }
    }
    
    

    func ConfigureCell (isSelected : Bool = false , text : String , _ givenReason : Reasons? = nil , _ cellIndex : IndexPath? = nil) {
        
        self.reason = givenReason
        self.indexPath = cellIndex
        
        if isSelected{
            radiioImage.image = UIImage(name: "RadioButtonFilled")
        }else{
            radiioImage.image = UIImage(name: "RadioButtonUnfilled")
        }
        
        
        self.lblOption.text = text
        
        if cellIndex == nil {
            actionButton.isUserInteractionEnabled = false
        }
    }
    @IBAction func clickedAction(_ sender: Any) {
        
        if let clouser = self.buttonClicked {
            clouser(self.reason, self.indexPath)
        }
    }
    
}
