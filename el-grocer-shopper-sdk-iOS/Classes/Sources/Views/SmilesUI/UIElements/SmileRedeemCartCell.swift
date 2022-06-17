//
//  SmileRedeemCartCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 23/02/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

class SmileRedeemCartCell: UITableViewCell {

    var payWithSmilesPointSwitch: ((_ smileSwitch:UISwitch)->())?
    var smileSwitchIsOn: Bool = false
    enum infoType : Int {
        case none = 0
        case redeem = 1
        case needmore = 2
    }
    
    @IBOutlet var bGView: UIView! {
        didSet {
            bGView.roundWithShadow(corners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner, .layerMinXMaxYCorner, .layerMinXMinYCorner], radius: 8, withShadow: false)
        }
    }
    @IBOutlet var lblPayWithSmile: UILabel! {
        didSet {
            lblPayWithSmile.setBody3BoldUpperStyle(false)
            lblPayWithSmile.text = NSLocalizedString("txt_pay_with_smile", comment: "")
        }
    }
    @IBOutlet var lblAvailableSmilePoints: UILabel! {
        didSet {
            lblAvailableSmilePoints.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var smilePaySwitch: UISwitch!
    @IBOutlet var imgInfo: UIImageView!{
        didSet {
            imgInfo.image = UIImage(name: "smallInfoIconSmiles")
        }
    }
    @IBOutlet var lblInfoMessage: UILabel!{
        didSet {
            lblInfoMessage.setCaptionOneRegDarkStyle()
            lblInfoMessage.textColor = UIColor.navigationBarColor()
            lblInfoMessage.text = NSLocalizedString("smile_point_redeem", comment: "")
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setSmileInfoMessage(type: infoType = .none, points:Int) {
        
        switch type {
        case .none:
            // show nothing
            lblInfoMessage.visibility = .goneY
            imgInfo.visibility = .goneY
        case .redeem:
            // show points to redeeme
            lblInfoMessage.textColor = .navigationBarColor()
            imgInfo.changePngColorTo(color: .navigationBarColor())
            lblInfoMessage.visibility = .visible
            imgInfo.visibility = .visible
            lblInfoMessage.text = "\(points) " + NSLocalizedString("smile_point_redeem", comment: "")
        case .needmore:
            // not enough points to redeeme
            lblInfoMessage.textColor = .textfieldErrorColor()
            imgInfo.changePngColorTo(color: .textfieldErrorColor())
            lblInfoMessage.visibility = .visible
            imgInfo.visibility = .visible
            lblInfoMessage.text = NSLocalizedString("not_enough_smile_point_initial", comment: "") + " \(points) " + NSLocalizedString("not_enough_smile_point_end", comment: "")
        default:
            lblInfoMessage.visibility = .goneY
            imgInfo.visibility = .goneY
            
        }
    }
    
    func ConfigureCellSwitchState(isOn: Bool) {
        self.smileSwitchIsOn = isOn
        smilePaySwitch.setOn(isOn, animated: true)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCellData(smileUser: SmileUser) {
        lblAvailableSmilePoints.text = NSLocalizedString("txt_available_points", comment: "") + "\(smileUser.availablePoints ?? 0) " + NSLocalizedString("smile_point_unit", comment: "")
    }
    @IBAction func smilePaySwitchHandler(_ sender: Any) {
        smileSwitchIsOn = smilePaySwitch.isOn
        if let switchClosure = payWithSmilesPointSwitch {
            switchClosure(smilePaySwitch)
        }
    }
    
}
