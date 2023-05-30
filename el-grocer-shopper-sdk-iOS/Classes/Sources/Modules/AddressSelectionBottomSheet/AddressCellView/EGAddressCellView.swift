//
//  EGAddressCellView.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 31/05/2023.
//

import UIKit

class EGAddressCellView : UIView {
    
    private var name: String
    
    @IBOutlet weak var imgAddressPin: UIImageView!
    @IBOutlet weak var lblAddressNickName: UILabel!
    @IBOutlet weak var lblAddressDetail: UILabel!
    
    
    class func instantiate(name: String) -> EGAddressCellView {
        let nib = UINib(nibName: "EGAddressCellView", bundle: Bundle.resource)
        guard let customView = nib.instantiate(withOwner: EGAddressCellView.self, options: nil).first as? EGAddressCellView else {
            fatalError("Failed to instantiate CustomView from nib")
        }
        customView.name = name
        return customView
    }
    
    init(name: String) {
        self.name = name
        super.init(frame: .zero)
        setupView()
    }
    
   
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        // Configure the view and its subviews using the dependency
        self.lblAddressDetail.text = self.name
    }
    
    
    
    
}
