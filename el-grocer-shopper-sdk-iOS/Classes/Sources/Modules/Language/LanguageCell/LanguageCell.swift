//
//  LanguageCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 07/06/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

let kLanguageCellIdentifier = "LanguageCell"
let kLanguageCellHeight:CGFloat = 44.0

class LanguageCell: UITableViewCell {
    
    @IBOutlet weak var languageTitle: UILabel!
    @IBOutlet weak var languageImage: UIImageView!
    @IBOutlet weak var selectionImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpLabelAppearance()
    }
    
    // MARK: Appearance
    fileprivate func setUpLabelAppearance() {
        self.languageTitle.font = UIFont.bookFont(15.0)
        self.languageTitle.textColor = UIColor.black
    }
    
    // MARK: Data
    func configureCellWithTitle(_ title: String, withImage image:String) {
        self.languageImage.image = UIImage(named:image)
        self.languageImage.layer.cornerRadius = 10
        self.languageImage.layer.masksToBounds = true
        self.languageTitle.text = title
    }
}
