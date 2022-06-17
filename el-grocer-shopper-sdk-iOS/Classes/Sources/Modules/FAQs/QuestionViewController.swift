//
//  QuestionViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Chatha on 2/7/18.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

class QuestionViewController: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionView: UITextView!
    
    var titleStr:String = ""
    var descriptionStr:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = localizedString("setting_faq", comment: "")
        addBackButton()
        
        self.setLabelAppearance()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
    }
    
    // MARK: Actions
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: Appearance
    fileprivate func setLabelAppearance() {
        
        self.titleLabel.font = UIFont.SFProDisplayBoldFont(18.0)
        self.titleLabel.textColor = UIColor.black
        self.titleLabel.text = titleStr
        self.titleLabel.sizeToFit()
        self.titleLabel.numberOfLines = 0
        self.titleLabel.backgroundColor = .clear
        
        self.descriptionView.font = UIFont.SFProDisplayNormalFont(14.0)
        self.descriptionView.textColor = UIColor.black
        self.descriptionView.text = self.descriptionStr
        self.descriptionView.backgroundColor = .clear
    }
}
