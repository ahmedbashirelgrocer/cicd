//
//  NeedCustomerSupportView.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 08/03/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
let KneedCustomerSupportCellHeight : CGFloat = 73
class NeedCustomerSupportView: UITableViewCell {

    @IBOutlet var supportBackgroudView: AWView!{
        didSet{
            supportBackgroudView.layer.backgroundColor = UIColor.textfieldBackgroundColor().cgColor
            supportBackgroudView.layer.cornerRadius = 20.5
        }
    }
    @IBOutlet var lblNeedMoreSupport: UILabel!{
        didSet{
            lblNeedMoreSupport.setBody3SemiBoldDarkStyle()
        }
    }
    @IBOutlet var lblChatWithElgrocer: UILabel!{
        didSet{
            lblChatWithElgrocer.setBody3SemiBoldGreenStyle()
        }
    }
    @IBOutlet var btnNeedMoreSupport: UIButton!
    @IBOutlet var liveChatIcon: UIImageView!
   
    var controller: UIViewController?
    var orderId: String?
    override func awakeFromNib() {
        super.awakeFromNib()
        self.initialValues()
    }
    
    func initialValues(){
        self.lblNeedMoreSupport.text = localizedString("need_assistance_lable", comment: "")
        self.lblChatWithElgrocer.text = localizedString("launch_live_chat_text", comment: "")
        self.backgroundColor = UIColor.navigationBarWhiteColor()
    }
    
    func configureValues(controller: UIViewController, orderID: String){
        self.orderId = orderID
        self.controller = controller
    }
    
    @IBAction func btnNeedMoreSupportHandler(_ sender: Any) {
        if let controller = self.controller , let orderId = self.orderId {
            //ZohoChat.showChat(orderId)
            let sendBirdManager = SendBirdDeskManager(controller: controller, orderId: orderId, type: .orderSupport)
            sendBirdManager.setUpSenBirdDeskWithCurrentUser()
        }
    }
    
}
