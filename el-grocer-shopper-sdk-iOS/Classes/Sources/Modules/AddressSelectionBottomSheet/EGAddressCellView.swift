//
//  EGAddressCellView.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 31/05/2023.
//

import UIKit

class EGAddressCellView : UIView {
    
    @IBOutlet weak var imgAddressPin: UIImageView!
    @IBOutlet weak var lblAddressNickName: UILabel! {
        didSet{
            lblAddressNickName.setBody2RegDarkStyle()
        }
    }
    @IBOutlet weak var lblAddressDetail: UILabel!{
        didSet{
            lblAddressDetail.setBody3RegDarkStyle()
        }
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    class func instantiate() -> EGAddressCellView {
       
        let nib = UINib(nibName: "EGAddressCellView", bundle: Bundle.resource)
        guard let customView = nib.instantiate(withOwner: EGAddressCellView.self, options: nil).first as? EGAddressCellView else {
            fatalError("Failed to instantiate CustomView from nib")
        }
        return customView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
    }
    
    func configureView(with name:String, and  addressDetail: String) {
        // Configure the view and its subviews using the dependency
        self.lblAddressNickName.text = name
        self.lblAddressDetail.text = addressDetail
    }
    
    
    
}
