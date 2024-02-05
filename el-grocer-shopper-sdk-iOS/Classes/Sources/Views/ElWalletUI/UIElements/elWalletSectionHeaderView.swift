//
//  elWalletSectionHeaderView.swift
//  ElGrocerShopper
//
//  Created by Salman on 29/04/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class elWalletSectionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var containerView: AWView!{
        didSet {
            containerView.roundWithShadow(corners: [ .layerMaxXMinYCorner, .layerMinXMinYCorner], radius: 8, withShadow: false)
            containerView.backgroundColor = ApplicationTheme.currentTheme.viewWhiteBGColor
//            containerView.borderColor = ApplicationTheme.currentTheme.borderGrayColor
//            containerView.borderWidth = 1.0
        }
    }
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet var moveToDetailsButtonBGView: AWView! {
        didSet {
            moveToDetailsButtonBGView.cornarRadius = 15
            moveToDetailsButtonBGView.backgroundColor = ApplicationTheme.currentTheme.buttonthemeBasePrimaryBlackColor
        }
    }
    @IBOutlet weak var moveToDetailsButton: UIButton!
    var moveNext: (()->Void)?
    
    static let reuseId: String = "elWalletSectionHeaderView"
    static var nib: UINib {
        return UINib(nibName: "elWalletSectionHeaderView", bundle: .resource)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setUpInitialAppearance()
    }
    
    private func setUpInitialAppearance() {
        titleLabel.setBody3SemiBoldDarkStyle()
        moveToDetailsButton.setBody2BoldGreenStyle()
        moveToDetailsButton.setTitleColor(ApplicationTheme.currentTheme.buttonthemeBaseBlackPrimaryForeGroundColor, for: UIControl.State())
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    @IBAction func moveToDetailsTapped(_ sender: UIButton) {
        
        if let moveNext = moveNext {
            moveNext()
        }
    }
    
    func configureHeaderView(title:String, buttonName:String) {
        self.titleLabel.text = title
        self.moveToDetailsButton.setTitle(buttonName, for: UIControl.State())
    }
    
}
