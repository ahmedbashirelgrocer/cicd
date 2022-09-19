//
//  PromocodeView.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 25/08/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

protocol PromocodeDelegate: AnyObject {
    func tap(promocode: String?)
}

class PromocodeView: UIView {
    @IBOutlet weak var viewBG: AWView!
    @IBOutlet weak var lblPromocode: UILabel! {
        didSet {
            lblPromocode.setBody3RegDarkStyle()
        }
    }
    
    @IBOutlet weak var ivForwardIcon: UIImageView!
    private var promocode: String?
    weak var delegate: PromocodeDelegate?
    
    override func awakeFromNib() {
        self.viewBG.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(promocodeTapHandler(_:))))
        
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.ivForwardIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func configure(promocode: String) {
        if promocode == "" {
            lblPromocode.text = localizedString("Apply Promocode", comment: "")
            return
        }
        self.promocode = promocode
        self.lblPromocode.text = promocode + " " + localizedString("txt_applied_promocode", comment: "")
    }
    
    @objc func promocodeTapHandler(_ sender: UITapGestureRecognizer) {
        self.delegate?.tap(promocode: promocode)
    }
}
