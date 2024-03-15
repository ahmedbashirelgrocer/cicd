//
//  CollectorView.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 07/09/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation
import UIKit

protocol CollectorsViewDelegate: AnyObject {
    func tap(view: CollectorsView)
}

class CollectorsView: AWView {
    @IBOutlet weak var viewBG: AWView!
    @IBOutlet weak var lblCollectorsDetails: UILabel! {
        didSet {
            lblCollectorsDetails.setBody3RegWhiteStyle()
        }
    }
    @IBOutlet weak var ivForwardIcon: UIImageView!
    
    weak var delegate: CollectorsViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.isUserInteractionEnabled = true
        self.viewBG.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_ :))))
        
        self.lblCollectorsDetails.text = localizedString("collector_text", comment: "")
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.ivForwardIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func configure(collector: collector) {
        self.lblCollectorsDetails.text = collector.name + ", " + collector.phonenNumber
    }
    
    @objc func tap(_ : UITapGestureRecognizer) {
        self.delegate?.tap(view: self)
    }
}
