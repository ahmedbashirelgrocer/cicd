//
//  UniTitleCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 23/01/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class UniTitleCell: UITableViewCell {

    @IBOutlet var title: UILabel!
    @IBOutlet var rightButton: UIButton!
    var clearButtonClicked : (()->Void)?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpApearance()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setUpApearance() {
       
        self.title.font = UIFont.SFProDisplayBoldFont(14)
        self.title.textColor = UIColor.newBlackColor()
        
        self.rightButton.titleLabel?.font = UIFont.SFProDisplayBoldFont(14)
        self.rightButton.setTitleColor(ApplicationTheme.currentTheme.buttonTextWithClearBGColor, for: .normal)
        self.rightButton.setTitle(localizedString("clear_button_title", comment: "clear"), for: .normal)
        
    }
    
    func cellConfigureForEmpty () {
        
        self.title.text = ""
        self.rightButton.isHidden = true
    }
    
    func cellConfigureWith (_ obj : SuggestionsModelObj?) {
        guard obj != nil else{return}
        self.title.text = obj?.title
        self.rightButton.isHidden = !(obj?.modelType == SearchResultSuggestionType.titleWithClearOption)
    }
    @IBAction func rightButtonAction(_ sender: Any) {
        if let clouser = self.clearButtonClicked {
            clouser()
        }
    }
    
}
