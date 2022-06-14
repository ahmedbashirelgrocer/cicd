//
//  smilePointTableCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 22/02/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
let smilePointTableCellHeight: CGFloat = 78
class smilePointTableCell: UITableViewCell {

    var smilePointClickHandler: (()->Void)?
    
    @IBOutlet var imgArrow: UIImageView!{
        didSet{
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
        
                self.imgArrow.transform = CGAffineTransform(scaleX: -1, y: 1)
                self.imgArrow.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
            }
        }
    }
    @IBOutlet var smilePointBGView: LinearGradientView!
    @IBOutlet var lblSmilePoint: UILabel! {
        didSet {
            lblSmilePoint.setBody3SemiBoldWhiteStyle()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpInitialAppearance()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUpInitialAppearance() {
        self.smilePointBGView.setUpGradient(start: .centerLeft, end: .centerRight, colors: [UIColor.smilePrimaryPurpleColor().cgColor,UIColor.smilePrimaryOrangeColor().cgColor])
        self.smilePointBGView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMinYCorner], radius: 8, withShadow: false)
        //lblSmilePoint.text = NSLocalizedString("txt_smile_point", comment: "") +  NSLocalizedString("txt_bracket_login", comment: "")
        lblSmilePoint.text = NSLocalizedString("txt_earn_smiles", comment: "")

    }
    
    func configureShowSmiles(_ smilepoints: Int?) {
        
        //var title = NSLocalizedString("txt_smile_point", comment: "") +  NSLocalizedString("txt_bracket_login", comment: "")
        var title = NSLocalizedString("txt_earn_smiles", comment: "")
        if UserDefaults.getIsSmileUser() {
            let points = UserDefaults.getSmilesPoints()
            title = NSLocalizedString("txt_smile_point", comment: "") + "(\(points) \(NSLocalizedString("smile_point_unit", comment: "")))" 

        }
        lblSmilePoint.text = title
    }
    
    func ConfigurePaidWithSmile() {
        self.lblSmilePoint.text = NSLocalizedString("txt_paid_with_smile", comment: "")
        self.imgArrow.isHidden = true
    }
    
    @IBAction func btnSmilePointClickHandler(_ sender: Any) {
        
        if let clickHandler = smilePointClickHandler {
            clickHandler()
        }
    }
    
}
