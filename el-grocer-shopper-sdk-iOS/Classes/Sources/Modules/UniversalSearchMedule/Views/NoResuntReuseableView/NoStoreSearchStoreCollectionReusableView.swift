//
//  NoStoreSearchStoreCollectionReusableView.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/01/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class NoStoreSearchStoreCollectionReusableView: UICollectionReusableView {

    var buttonClicked: (()->Void)?
    @IBOutlet var searchButton: UIButton!{
        didSet{
            searchButton.backgroundColor = UIColor.navigationBarColor()
            searchButton.setCornerRadiusStyle()
        }
    }
    @IBOutlet var lblTitle: UILabel! {
        didSet {
            lblTitle.text = NSLocalizedString("lbl_DidNotFind", comment: "")
        }
    }
    @IBOutlet var lblBtnText: UILabel! {
        didSet {
            lblBtnText.text = NSLocalizedString("lbl_NoSearch", comment: "")
            lblBtnText.textColor = UIColor.navigationBarWhiteColor()
            
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    @IBAction func searchButtonAction(_ sender: Any) {
        
        if let clouser = self.buttonClicked {
            clouser()
        }
    }
    
}
