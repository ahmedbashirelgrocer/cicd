//
//  FreeGroceriesViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 27/02/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit


class FreeGroceriesViewController: UIViewController {
    
    
    @IBOutlet weak var freeGroceryTitle: UILabel!
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var freeGroceryDescription: UILabel!
    @IBOutlet weak var invitationLink: UILabel!
    
    @IBOutlet weak var invitationView: UIView!
    @IBOutlet weak var invitationCode: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    @IBOutlet weak var copyButton: UIButton!
    
    @IBOutlet weak var sendInvitationButton: UIButton!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        self.title = localizedString("free_groceries_navigation_bar_title", comment: "")
        
        addBackButton()
        
        /* addMenuButton()
         updateMenuButtonRedDotState(nil)
         NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(UIViewController.updateMenuButtonRedDotState(_:)), name:kHelpshiftChatResponseNotificationKey, object: nil)*/
        
        self.setFreeGroceryTitleLabelAppearance()
        self.setFreeGroceryDescriptionLabelAppearance()
        self.setInvitationLinkLabelAppearance()
        self.setInvitationViewAppearance()
        self.setSendInvitationButtonAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_free_groceries_screen")
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsFreeGroceriesScreen)
        FireBaseEventsLogger.setScreenName(kGoogleAnalyticsFreeGroceriesScreen, screenClass: String(describing: self.classForCoder))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Actions
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    // MARK: Appearance
    fileprivate func setFreeGroceryTitleLabelAppearance() {
        
        self.freeGroceryTitle.font = UIFont.boldFont(15.0)
        self.freeGroceryTitle.textColor = UIColor.black
        self.freeGroceryTitle.text = localizedString("earn_free_credits", comment: "")
    }
    
    fileprivate func setFreeGroceryDescriptionLabelAppearance() {
        
        self.freeGroceryDescription.font = UIFont.bookFont(12.0)
        self.freeGroceryDescription.textColor = UIColor.navigationBarColor()
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
        let titleStr = NSMutableAttributedString(string: localizedString("free_groceries_description", comment: ""))
        titleStr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, titleStr.length))
        self.freeGroceryDescription.attributedText = titleStr
    }
    
    fileprivate func setInvitationLinkLabelAppearance() {
        
        self.invitationLink.font = UIFont.bookFont(12.0)
        self.invitationLink.textColor = UIColor.navigationBarColor()
        self.invitationLink.text = localizedString("free_groceries_invitation_link", comment: "")
    }
    
    fileprivate func setInvitationViewAppearance() {
        
        self.invitationView.layer.cornerRadius = 5
        self.invitationView.layer.borderWidth = 1
        self.invitationView.layer.borderColor = UIColor.navigationBarColor().cgColor
        
        
        self.invitationCode.font = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.invitationCode.textColor =  UIColor.black
        let referralObj = Referral.getReferralObject(DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
        self.invitationCode.text = referralObj?.referralCode
        
        self.inviteButton.titleLabel?.textColor = UIColor.navigationBarColor()
        
        let text = localizedString("how_invite_work", comment: "")
        let titleStr = NSMutableAttributedString(string: text)
        titleStr.addAttribute(NSAttributedString.Key.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: NSMakeRange(0, text.count))
        self.inviteButton.setAttributedTitle(titleStr, for: UIControl.State())
        self.inviteButton.titleLabel?.font = UIFont.boldFont(12.0)
        
        self.copyButton.titleLabel?.textColor = UIColor.navigationBarColor()
        self.copyButton.titleLabel?.font = UIFont.boldFont(12.0)
        self.copyButton.setTitle(localizedString("copy", comment: ""), for: UIControl.State())
    }
    
    fileprivate func setSendInvitationButtonAppearance() {
        
        self.sendInvitationButton.layer.cornerRadius = 5
        self.sendInvitationButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(20.0)
        self.sendInvitationButton.setTitle(localizedString("free_groceries_send_invite", comment: ""), for: UIControl.State())
    }
    
    // MARK: Button Actions
    
    @IBAction func copyToClipBoard(_ sender: AnyObject) {
        
        let referralObject = Referral.getReferralObject(DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
        if referralObject?.referralUrl != nil {
            UIPasteboard.general.string = referralObject?.referralUrl
        }
    }
    
    @IBAction func sendInvitation(_ sender: AnyObject) {
        
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("Invite_friends_from_free_groceries")
        
        let referralObject = Referral.getReferralObject(DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
        self.displayShareSheet((referralObject?.referralMessage!)!)
    }
    
    @IBAction func howInviteWorks(_ sender: AnyObject) {
        
        //HelpshiftSupport.showSingleFAQ("36", with: self, withOptions: nil)

        let questionVC = ElGrocerViewControllers.questionViewController()
        questionVC.titleStr = localizedString("how_invite_work_title", comment: "")
        questionVC.descriptionStr = localizedString("how_invite_work_description", comment: "")
        self.navigationController?.pushViewController(questionVC, animated: true)
    }
    
    fileprivate func displayShareSheet(_ shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
}
