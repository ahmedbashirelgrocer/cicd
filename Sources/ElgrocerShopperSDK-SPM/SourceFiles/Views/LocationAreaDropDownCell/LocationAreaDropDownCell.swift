//
//  LocationAreaDropDownCell.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 23.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

class LocationAreaDropDownCell : UITableViewCell {
    
    var separatorView:UIView!
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
   
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.textLabel?.font = UIFont.SFProDisplayNormalFont(14.0)
        self.textLabel?.textAlignment = NSTextAlignment.left
        
        self.separatorView = UIView()
        self.separatorView.backgroundColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 1)
        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(self.separatorView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.separatorView.frame = CGRect(x: 0, y: self.frame.size.height - 1, width: self.frame.size.width, height: 1)
    }
    
}
