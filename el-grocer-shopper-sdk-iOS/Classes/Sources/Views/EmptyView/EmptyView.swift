//
//  EmptyView.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 20.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

class EmptyView : UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setUpTitleLabelAppearance()
        setUpDescriptionLabelAppearance()
    }
    
    // MARK: Appearance
    
    fileprivate func setUpTitleLabelAppearance() {
        
        self.titleLabel.textColor = UIColor.emptyViewTextColor()
        self.titleLabel.font = UIFont.boldFont(20.0)
    }
    
    fileprivate func setUpDescriptionLabelAppearance() {
        
        self.descriptionLabel.textColor = UIColor.emptyViewTextColor()
        self.descriptionLabel.font = UIFont.bookFont(17.0)
    }
    
    // MARK: Instance
    
    class func createAndAddEmptyView(_ title:String, description:String, addToView superView:UIView) -> EmptyView {
        
        let view = Bundle.main.loadNibNamed("EmptyView", owner: nil, options: nil)![0] as! EmptyView
        view.titleLabel.text = title
        view.descriptionLabel.text = description
        view.translatesAutoresizingMaskIntoConstraints = false
        
        superView.addSubview(view)
        
        let views:NSDictionary = ["emptyView": view]
        
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[emptyView]-(0)-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: views as! [String : AnyObject]))
        superView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[emptyView]-(0)-|", options: NSLayoutConstraint.FormatOptions(), metrics: nil, views: views as! [String : AnyObject]))
        
        return view
    }
}
