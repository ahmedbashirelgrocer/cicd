//
//  NavigationBarChatButton.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 07/03/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class NavigationBarChatButton: UIView {

    @IBOutlet var navChatButton: UIButton!
    @IBOutlet var lblChat: UILabel!{
        didSet{
            //lblChat.text = localizedString("btn_help", comment: "")
        }
    }
    var chatClick: (()->Void)?
    
    class func loadFromNib() -> NavigationBarChatButton? {
        return self.loadFromNib(withName: "NavigationBarChatButton")
    }
    
    override func awakeFromNib() {
        
        setupInitialAppearnce()
    }
    @IBAction func chatButtonHandler(_ sender: Any) {
        if let clouser = chatClick {
            clouser()
        }
    }
    
    func setupInitialAppearnce(){
        self.backgroundColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
      //  lblChat.setCaptionTwoSemiboldWhiteStyle()
        changeChatIconColor()
    }
    
    func setChatButtonHidden(_ hidden:Bool) {
        if let chat = self.navChatButton {
            if hidden{
                chat.visibility = .goneX
            }else{
                chat.visibility = .visible
            }
            
        }
    }
    
    func changeChatIconColor(color: UIColor = ApplicationTheme.currentTheme.themeBasePrimaryColor){
        self.navChatButton.imageView?.changePngColorTo(color: color)
        if color == ApplicationTheme.currentTheme.themeBasePrimaryColor{
            self.backgroundColor = SDKManager.shared.isSmileSDK ? .clear : .clear
        }else{
            self.backgroundColor = SDKManager.shared.isSmileSDK ? .clear : .clear
        }
    }
    
    func setChatIcon ( _ isNewMessage : Bool = false) {
        
        if isNewMessage {
                navChatButton.setImage(UIImage(name: "nav_chat_icon_unread"), for: UIControl.State())
        }else{
            navChatButton.setImage(UIImage(name: "nav_chat_icon"), for: UIControl.State())
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}
