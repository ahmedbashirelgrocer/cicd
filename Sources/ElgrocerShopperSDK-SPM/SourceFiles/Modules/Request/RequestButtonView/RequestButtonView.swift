//
//  RequestButtonView.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 16/10/2017.
//  Copyright © 2017 elGrocer. All rights reserved.
//

import UIKit

protocol RequestButtonViewProtocol : class {
    
    func requestButtonHandler()
}

class RequestButtonView: UIView {
    
    //MARK: Outlets
    @IBOutlet var requestButton: UIButton!
    
    //MARK: Variables
    weak var delegate:RequestButtonViewProtocol?
    
    // MARK: Life cycle
    override func awakeFromNib() {
        self.setUpRequestButtonAppearance()
    }
    
    // MARK: Appearance
    fileprivate func setUpRequestButtonAppearance(){
        
        self.requestButton.setTitle(localizedString("request_button_title", comment: ""), for: UIControl.State())
        self.requestButton.titleLabel?.font = UIFont.SFProDisplayBoldFont(14.0)
    }
    
    // MARK: Get RequestButtonView
    class func getRequestButtonView() -> RequestButtonView {
        let view = Bundle.resource.loadNibNamed("RequestButtonView", owner: nil, options: nil)![0] as! RequestButtonView
        return view
    }
    
    // MARK: Button Action
    @IBAction func requestHandler(_ sender: AnyObject) {
        self.delegate!.requestButtonHandler()
    }
}
