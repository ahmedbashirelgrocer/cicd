//
//  GroceriesEmptyView.swift
//  ElGrocerShopper
//
//  Created by PiotrGorzelanyMac on 22/04/16.
//  Copyright © 2016 RST IT. All rights reserved.
//

import UIKit

protocol GroceriesEmptyViewDelegate: class {
    
    func presentChangeLocationView()
    func presentChatViewController()
}

enum NoGroceriesMode : Int {
    
    /** There are no partner groceries in the selected area */
    case noPartnerGrocery = 0
    
    /** All groceries in the selected area are closed */
    case offline = 1
}

class GroceriesEmptyView: UIView {
    
    @IBOutlet weak var bgView: UIImageView!
    // MARK: Outlets
    @IBOutlet weak var topImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var agentChatBtn: UIButton!
    @IBOutlet weak var changeLocationBtn: UIButton!
    
    weak var delegate: GroceriesEmptyViewDelegate?
    
    
    // MARK: Properties
    var mode: NoGroceriesMode = .noPartnerGrocery {
        didSet {
            self.modeChanged()
        }
    }
    
    // MARK: Lifecycle
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.setInitialViewAppearance()
        self.modeChanged()
    }
    
    class func initFromNib() -> GroceriesEmptyView {
        
        let groceryEmptyView = Bundle.resource.loadNibNamed("GroceriesEmptyView", owner: nil, options: nil)![0] as! GroceriesEmptyView
        return groceryEmptyView
    }

    // MARK: Helpers
    
    fileprivate func modeChanged() {
        
        switch self.mode {
        case .noPartnerGrocery:
            
            //titleLabel.text = localizedString("no_partner_grocery", comment: "")
            titleLabel.text = localizedString("no_groceries_sorry_message", comment: "")
            topImageView.image = UIImage(name: "img_shops")
            
        case .offline:
            
            titleLabel.text = localizedString("no_groceries_sorry_message", comment: "")
            topImageView.image = UIImage(name: "shops_offline")
        }
        
    }
    
    // MARK: Appearance
    
    fileprivate func setInitialViewAppearance() {





        self.titleLabel.font = UIFont.SFProDisplaySemiBoldFont(15)
        self.titleLabel.textColor = UIColor.redInfoColor()
        self.subtitleLabel.font = UIFont.lightFont(13)
        self.subtitleLabel.textColor = UIColor.black
        self.subtitleLabel.text = localizedString("no_groceries_subtitle_label_title", comment: "")
        
        
        let buttonsCornerRadius: CGFloat = 5.0
        let buttonsFont = UIFont.SFProDisplaySemiBoldFont(14.0)
        
        // chat button appearance
        self.agentChatBtn.layer.cornerRadius = buttonsCornerRadius
        self.agentChatBtn.backgroundColor = UIColor.secondaryDarkGreenColor()
        self.agentChatBtn.titleLabel?.font = buttonsFont
        self.agentChatBtn.setTitleColor(UIColor.white, for: UIControl.State())
        self.agentChatBtn.setTitle(localizedString("agentchat_button", comment: ""), for: UIControl.State())
        
        // location button appearance
        self.changeLocationBtn.layer.cornerRadius = buttonsCornerRadius
        self.changeLocationBtn.backgroundColor = UIColor.secondaryDarkGreenColor()
        self.changeLocationBtn.titleLabel?.font = buttonsFont
        self.changeLocationBtn.setTitleColor(UIColor.white, for: UIControl.State())
        self.changeLocationBtn.setTitle(localizedString("changelocation_button", comment: ""), for: UIControl.State())
    }

    @IBAction func changeLocation(_ sender: AnyObject) {
        
        delegate?.presentChangeLocationView()
    }
    
    
    @IBAction func speakToAgent(_ sender: AnyObject) {
        
       delegate?.presentChatViewController()
        
    }
}
