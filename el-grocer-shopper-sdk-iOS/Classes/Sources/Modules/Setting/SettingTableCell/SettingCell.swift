//
//  SettingCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 23/02/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

let kSettingCellIdentifier = "SettingTableCell"


let kSettingCellHeight: CGFloat  = 65

class SettingCell: RxUITableViewCell {

    @IBOutlet weak var bottomLine: UIView!
    @IBOutlet weak var itemTitle: UILabel!{
        didSet{
            itemTitle.setBody3RegDarkStyle()
        }
    }
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var arrowImage: UIImageView! {
        didSet {
            arrowImage.image = UIImage(name: "SettingArrowForward")?.withCustomTintColor(color: AppSetting.theme.themeBasePrimaryColor)
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                arrowImage.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
        }
    }
    
    var viewModel: SettingCellViewModel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.separatorColor()
        self.contentView.backgroundColor = UIColor.separatorColor()
        
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        self.backgroundColor = highlighted ? UIColor.unselectedPageControl() : UIColor.clear
        
    }
    
    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? SettingCellViewModel else { return }
        self.viewModel = viewModel
        self.itemTitle.text = self.viewModel.title
        self.itemImage.image = self.viewModel.image
    }
    
    
    @IBAction func clickAction(_ sender: Any) {
        self.viewModel.inputs.actionObserver.onNext(self.viewModel.cellType)
    }
    

    // MARK: Data    
    func configureCellWithTitle(_ title: String, withImage image:String) {
        
        self.itemImage.image = UIImage(name: image)
        self.itemTitle.text = title
        
        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
        if currentLang == "ar" {
            self.arrowImage.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.arrowImage.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
    }
}
