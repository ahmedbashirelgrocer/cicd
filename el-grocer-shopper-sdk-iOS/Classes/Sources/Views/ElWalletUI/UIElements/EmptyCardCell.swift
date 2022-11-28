//
//  EmptyCardCell.swift
//  ElGrocerShopper
//
//  Created by Salman on 06/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class EmptyCardCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var innerContainerView: UIView!{
        didSet {
            innerContainerView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 8, withShadow: false)
        }
    }
    @IBOutlet weak var addNewButton: UIButton!{
        didSet {
            addNewButton.layer.cornerRadius = addNewButton.frame.height / 2.0
            addNewButton.setTitle(localizedString("txt_add_new_card_with_plus", comment: ""), for: UIControl.State())
            addNewButton.backgroundColor = ApplicationTheme.currentTheme.buttonEnableBGColor
        }
    }
    @IBOutlet var lblNoCardtext: UILabel! {
        didSet {
            lblNoCardtext.numberOfLines = 0
            lblNoCardtext.text = localizedString("txt_no_card_found", comment: "")
        }
    }
    
    var addNewCardClosure: (()->Void)?
    
    static let reuseId: String = "EmptyCardCell"
    static var nib: UINib {
        return UINib(nibName: "EmptyCardCell", bundle: .resource)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction func addNewTapped(_ sender: UIButton) {
        
        if let addCardClosure = addNewCardClosure {
            addCardClosure()
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
