//
//  CollectorsCarView.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 07/09/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import Foundation
import UIKit

protocol CollectorsCarViewDelegate: AnyObject {
    func tap(view: CollectorsCarView)
}

class CollectorsCarView: UIView {
    @IBOutlet weak var viewBG: AWView!
    @IBOutlet weak var lblCarsDetails: UILabel! {
        didSet {
            lblCarsDetails.setBody3RegWhiteStyle()
        }
    }
    
    @IBOutlet weak var ivForwardIcon: UIImageView!
    weak var delegate: CollectorsCarViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.viewBG.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tap(_ :))))
        self.lblCarsDetails.text = NSLocalizedString("collector_car_text", comment: "")
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.ivForwardIcon.transform = CGAffineTransform(scaleX: -1, y: 1)
        }
    }
    
    func configure(car: Car) {
        self.lblCarsDetails.text = car.plateNumber
    }
    
    @objc func tap(_ sender: UITapGestureRecognizer) {
        self.delegate?.tap(view: self)
    }
}
