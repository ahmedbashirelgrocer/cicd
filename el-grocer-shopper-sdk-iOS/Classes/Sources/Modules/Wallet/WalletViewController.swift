//
//  WalletViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 27/02/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

enum WalletControllerMode : Int {
    
    case walletAmountHistory = 0
    case walletEmpty = 1
}

class WalletViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {
    
    var controllerMode:WalletControllerMode = .walletAmountHistory
    
    /* ---------- Empty View Outlets ----------*/
    
    @IBOutlet weak var emptyWalletView: UIView!
    @IBOutlet weak var amountHistoryWalletView: UIView!
    
    @IBOutlet weak var inviteFriends: UILabel!
    @IBOutlet weak var referrerAmountLabel: UILabel!
    
    @IBOutlet weak var inviteFriendsButton: UIButton!
    
    /* ---------- History View Outlets ----------*/
    
    @IBOutlet weak var walletAmount: UILabel!
    @IBOutlet weak var walletCurrency: UILabel!
    @IBOutlet weak var availableBalance: UILabel!
    
    @IBOutlet weak var walletView: UIView!
    @IBOutlet weak var walletExpiry: UILabel!
    @IBOutlet weak var walletImgView: UIImageView!
    
    @IBOutlet weak var purchasingDetail: UILabel!
    @IBOutlet weak var walletTableView: UITableView!
    
    var walletArray:[ReferralWallet] = []
    var referralObject : Referral?
    let dateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.title = localizedString("wallet_navigation_bar_title", comment: "")
        
        addBackButton()
        
        referralObject = Referral.getReferralObject(DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
        
        if (Double(referralObject!.walletTotal!) == 0) {
            controllerMode = .walletEmpty
        }else{
            controllerMode = .walletAmountHistory
        }
        
        dateFormatter.dateFormat = "dd MMM, yyyy"
        
        walletArray = referralObject!.referralWallet.allObjects as! [ReferralWallet]
       elDebugPrint("Wallet Array Count:%d",walletArray.count)
        
        if self.controllerMode == .walletEmpty {
            
            self.emptyWalletView.isHidden = false
            self.amountHistoryWalletView.isHidden = true
            
        }else{
    
            self.amountHistoryWalletView.isHidden = false
            self.emptyWalletView.isHidden = true
        }
        
        self.registerTableViewCell()
        
        self.setReferrerAmountLabelAppearance()
        self.setInviteFriendsLabelAppearance()
        self.setInviteFriendsButtonAppearance()
        self.setHistoryViewLabelAppearance()
        self.setWalletViewAppearance()
        self.setTableViewAppearance()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        
        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_wallet_screen")
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsWalletScreen)
        FireBaseEventsLogger.setScreenName(kGoogleAnalyticsWalletScreen, screenClass: String(describing: self.classForCoder))
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
    
    fileprivate func setReferrerAmountLabelAppearance() {
        
        self.referrerAmountLabel.font = UIFont.SFProDisplaySemiBoldFont(11.0)
        self.referrerAmountLabel.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
        
        self.referrerAmountLabel.text = ElGrocerUtility.sharedInstance.referrerAmount
    }
    
    fileprivate func setInviteFriendsLabelAppearance() {
        
        self.inviteFriends.font = UIFont.SFProDisplaySemiBoldFont(13.0)
        self.inviteFriends.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
        paragraphStyle.alignment = NSTextAlignment.center
        let titleStr = NSMutableAttributedString(string: localizedString("wallet_no_balance_text", comment: ""))
        titleStr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, titleStr.length))
        self.inviteFriends.attributedText = titleStr
    }
    
    fileprivate func setInviteFriendsButtonAppearance() {
        
        self.inviteFriendsButton.layer.cornerRadius = 5
        self.inviteFriendsButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(18.0)
        self.inviteFriendsButton.setTitle(localizedString("wallet_invite_friend", comment: ""), for: UIControl.State())
    }
    
    fileprivate func setHistoryViewLabelAppearance() {
        
        self.walletAmount.font = UIFont.SFProDisplaySemiBoldFont(24.0)
        self.walletAmount.textColor = ApplicationTheme.currentTheme.labelPrimaryBaseTextColor
        self.walletAmount.text = String(format: "%0.2f",Double(referralObject!.walletTotal!)!)
        self.walletAmount.numberOfLines = 0
        self.walletAmount.sizeToFit()
        
        self.walletCurrency.font = UIFont.SFProDisplaySemiBoldFont(16.0)
        self.walletCurrency.textColor = UIColor.black
        self.walletCurrency.text = localizedString("aed", comment: "")
        
        self.availableBalance.font = UIFont.SFProDisplaySemiBoldFont(14.0)
        self.availableBalance.textColor = UIColor.lightTextGrayColor()
        self.availableBalance.text = localizedString("available_balance", comment: "")
        
        self.walletExpiry.font = UIFont.lightFont(14.0)
        self.walletExpiry.textColor = UIColor.black
        self.walletExpiry.text = localizedString("balance_expire", comment: "")
        
        self.purchasingDetail.font = UIFont.SFProDisplaySemiBoldFont(16.0)
        self.purchasingDetail.textColor = UIColor.black
        self.purchasingDetail.text = localizedString("balance_details", comment: "")
        
    }
    
    fileprivate func setWalletViewAppearance() {
        
        self.walletView.backgroundColor = UIColor.lightGrayBGColor()
    }
    
    fileprivate func setTableViewAppearance() {
        
        self.walletTableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.walletTableView.separatorColor = UIColor.borderGrayColor()
        self.walletTableView.separatorInset = UIEdgeInsets.zero
        self.walletTableView.tableFooterView = UIView()
    }
    
    //MARK: TableView Data Source
    
    func registerTableViewCell() {
        
        let walletHistoryCellNib  = UINib(nibName: "WalletHistoryCell", bundle: Bundle.resource)
        self.walletTableView.register(walletHistoryCellNib, forCellReuseIdentifier: kWalletHistoryCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return kWalletHistoryCellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return walletArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:WalletHistoryCell = tableView.dequeueReusableCell(withIdentifier: kWalletHistoryCellIdentifier, for: indexPath) as! WalletHistoryCell
        
        let wallet = walletArray[(indexPath as NSIndexPath).row]
        
        let DateStr = dateFormatter.string(from: wallet.walletExpireDate! as Date)
       elDebugPrint(DateStr)
        
        cell.configureCellWithPurchaseTitle(wallet.walletInfo!, withPurchaseDate: DateStr, withPurchaseAmount:wallet.walletAmount!, andWithCurrencyType: localizedString("aed", comment: ""))
        
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    // MARK: Button Actions
    
    @IBAction func inviteFriends(_ sender: AnyObject) {
        
        let freeGroceriesController = ElGrocerViewControllers.freeGroceriesViewController()
        self.navigationController?.pushViewController(freeGroceriesController, animated: true)
    }
}
