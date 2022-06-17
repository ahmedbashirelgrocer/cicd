//
//  CongratulationsViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 02/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

class CongratulationsViewController: UIViewController {
    
    @IBOutlet weak var imgView: UIImageView!
    
    @IBOutlet weak var congratulationsLabel: UILabel!
    @IBOutlet weak var referralDescription: UILabel!
    @IBOutlet weak var moreSharingLabel: UILabel!
    @IBOutlet weak var invitationLink: UILabel!
    
    @IBOutlet weak var invitationView: UIView!
    @IBOutlet weak var invitationCode: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    
    @IBOutlet weak var sendInvitationButton: UIButton!
    
    var userInfo: [AnyHashable: Any] = [:]

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = localizedString("wallet_navigation_bar_title", comment: "")
        
        addBackButton()
        
        self.setCongratulationsLabelAppearance()
        self.setFreeGroceryDescriptionLabelAppearance()
        self.setMoreSharingLabelAppearance()
        self.setInvitationLinkLabelAppearance()
        self.setInvitationViewAppearance()
        self.setSendInvitationButtonAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsCongratulationScreen)
        FireBaseEventsLogger.setScreenName(kGoogleAnalyticsCongratulationScreen, screenClass: String(describing: self.classForCoder))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Appearance
    
    fileprivate func setCongratulationsLabelAppearance() {
        
        self.congratulationsLabel.font = UIFont.bookFont(24.0)
        self.congratulationsLabel.textColor = UIColor.black
        self.congratulationsLabel.text = localizedString("congratiolations", comment: "")
    }
    
    fileprivate func setFreeGroceryDescriptionLabelAppearance() {
        
        self.referralDescription.font = UIFont.bookFont(12.0)
        self.referralDescription.textColor = UIColor.meunGreenTextColor()
       // self.referralDescription.text = localizedString("congratiolation_referral_description", comment: "")
        self.referralDescription.text = (userInfo["aps"] as? NSDictionary)?["alert"] as? String
    }
    
    fileprivate func setMoreSharingLabelAppearance() {
        
        self.moreSharingLabel.font = UIFont.boldFont(12.0)
        self.moreSharingLabel.textColor = UIColor.meunGreenTextColor()
        self.moreSharingLabel.text = localizedString("congratiolation_keep_sharing_text", comment: "")
    }
    
    fileprivate func setInvitationLinkLabelAppearance() {
        
        self.invitationLink.font = UIFont.bookFont(12.0)
        self.invitationLink.textColor = UIColor.meunGreenTextColor()
        self.invitationLink.text = localizedString("invitation_code", comment: "")
    }
    
    fileprivate func setInvitationViewAppearance() {
        
        self.invitationView.layer.cornerRadius = 5
        self.invitationView.layer.borderWidth = 1
        self.invitationView.layer.borderColor = UIColor.navigationBarColor().cgColor
        
        
        self.invitationCode.font = UIFont.SFProDisplaySemiBoldFont(12.0)
        self.invitationCode.textColor =  UIColor.black
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        self.invitationCode.text = userProfile?.referralCode
        
        self.copyButton.titleLabel?.textColor = UIColor.meunGreenTextColor()
        self.copyButton.titleLabel?.font = UIFont.boldFont(12.0)
    }
    
    fileprivate func setSendInvitationButtonAppearance() {
        
        self.sendInvitationButton.layer.cornerRadius = 5
        self.sendInvitationButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(18.0)
    }
    
    // MARK: Button Actions
    
    @IBAction func copyToClipBoard(_ sender: AnyObject) {
        
        UIPasteboard.general.string = self.invitationCode.text
        
        if let copyText = UIPasteboard.general.string {
            print("Clip Board Copy Text:%@",copyText)
        }
    }
    
    @IBAction func sendInvitation(_ sender: AnyObject) {
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("Invite_friends_from_congratulations_screen")
        let referralObject = Referral.getReferralObject(DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
        self.displayShareSheet((referralObject?.referralMessage!)!)
    }
    
    func displayShareSheet(_ shareContent:String) {
        let activityViewController = UIActivityViewController(activityItems: [shareContent as NSString], applicationActivities: nil)
        present(activityViewController, animated: true, completion: {})
    }
    
    override func backButtonClick() {
        
        self.presentingViewController!.dismiss(animated: false, completion: nil)
    }
}
