//
//  OrderPaymentSelectionViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 27.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
//import Intercom
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}


protocol PaymentSelectionProtocol : class {
    
    func confirmPaymentWithPaymentOption(_ selectedPaymentOption:PaymentOption, andWithAmountPaidFromWallet walletPaidAmount:Double) -> Void
}

class OrderPaymentSelectionViewController : UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let kHttpErrorForbidden:Int = 403
    let kHttpErrorNoMinimumOrderValue:Int = 423
    
    var grocery:Grocery!
    var selectedPaymentOption:PaymentOption!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var paymentMethodLabel: UILabel!
   // @IBOutlet weak var payLabel: UILabel!
    
    @IBOutlet weak var confirmPaymentButton: UIButton!

    weak var delegate:PaymentSelectionProtocol?
    
    var referralObject : Referral?
    
    var Images = [String]()
    var titles = [String]()
    
    var remainingAmount:Double = 0
    var walletPaidAmount:Double = 0
    var walletAmount:Double = 0
    var priceSum = 0.00
    
    var lastSelection:IndexPath!
    
    
    // MARK: Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("place_order_title_label", comment: "")
        
        addBackButton()
        
        setUpPaymentMethodLabelAppearance()
        setUpConfirmButtonAppearance()
        
        referralObject = Referral.getReferralObject(DatabaseHelper.sharedInstance.backgroundManagedObjectContext)
        if referralObject != nil {
            walletAmount = Double(referralObject!.walletTotal!)!
        }
        
        if let amount = UserDefaults.getWalletPaidAmount(){
            walletAmount = Double(amount)!
            remainingAmount = priceSum - Double(amount)!
            self.walletPaidAmount = Double(amount)!
        }

        registerTableViewCell()
        
        titles =  [NSLocalizedString("pay_via_wallet", comment: "")]
        Images =  ["Wallet"]
        
        /* ---------- Check for available payment types ---------- */
        self.selectedPaymentOption = PaymentOption(rawValue: UserDefaults.getPaymentMethod(forStoreId: ""))
        
//        if(UserDefaults.getPaymentMethod() != 0) {
//            self.setConfirmButtonEnabled(true)
//        }
        
        if self.grocery.availablePayments.uint32Value & PaymentOption.cash.rawValue > 0 {
            titles.append(NSLocalizedString("pay_via_cash", comment: ""))
            Images.append("Cash")
            if ( self.selectedPaymentOption == PaymentOption.cash) {
                self.lastSelection = IndexPath(row: 0, section: titles.firstIndex(of: NSLocalizedString("pay_via_cash", comment: ""))!)
                self.setConfirmButtonEnabled(true)
            }
        }
        
        if self.grocery.availablePayments.uint32Value & PaymentOption.card.rawValue > 0 {
            
            titles.append(NSLocalizedString("pay_via_card", comment: ""))
            Images.append("Card")
            if ( self.selectedPaymentOption == PaymentOption.card ) {
                self.lastSelection = IndexPath(row: 0, section: titles.firstIndex(of: NSLocalizedString("pay_via_card", comment: ""))!)
                self.setConfirmButtonEnabled(true)
            }
        }
        
       /* if self.grocery.availablePayments.unsignedIntValue & PaymentOption.Cash.rawValue > 0 && self.grocery.availablePayments.unsignedIntValue & PaymentOption.Card.rawValue > 0 {
            
            //both payments are available
            titles.append(NSLocalizedString("pay_via_cash", comment: ""))
            Images.append("Cash")
            titles.append(NSLocalizedString("pay_via_card", comment: ""))
            Images.append("Card")

        } else if self.grocery.availablePayments.unsignedIntValue & PaymentOption.Cash.rawValue > 0 && self.grocery.availablePayments.unsignedIntValue & PaymentOption.Card.rawValue == 0 {
            
            //only cash
            titles.append(NSLocalizedString("pay_via_cash", comment: ""))
            Images.append("Cash")

            
        } else if self.grocery.availablePayments.unsignedIntValue & PaymentOption.Cash.rawValue == 0 && self.grocery.availablePayments.unsignedIntValue & PaymentOption.Card.rawValue > 0 {
            
            titles.append(NSLocalizedString("pay_via_card", comment: ""))
            Images.append("Card")
        }*/
        
       /* if UserDefaults.getPaymentMethod() == "Cash" {
            self.lastSelection = NSIndexPath(forRow: 0, inSection: 1)
            self.selectedPaymentOption = .Cash
            self.setConfirmButtonEnabled(true)
        }else if UserDefaults.getPaymentMethod() == "Card" {
            self.lastSelection = NSIndexPath(forRow: 0, inSection: 2)
            self.selectedPaymentOption = .Card
            self.setConfirmButtonEnabled(true)
        }*/
        
    }
    
    deinit {
        
        NotificationCenter.default.removeObserver(self);
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        GoogleAnalyticsHelper.trackScreenWithName(kGoogleAnalyticsOrderPaymentSelectionScreen)
        FireBaseEventsLogger.setScreenName( kGoogleAnalyticsOrderPaymentSelectionScreen , screenClass: String(describing: self.classForCoder))
    }
    
    // MARK: Appearance
    
    fileprivate func setUpConfirmButtonAppearance() {
        
        self.confirmPaymentButton.setTitle(NSLocalizedString("confirm_payment_button_title", comment: ""), for: UIControl.State())
        self.confirmPaymentButton.setH4SemiBoldWhiteStyle()
        self.confirmPaymentButton.layer.cornerRadius = 5
        self.setConfirmButtonEnabled(false)
    }
    
    fileprivate func setConfirmButtonEnabled(_ enabled:Bool) {
        
        self.confirmPaymentButton.isEnabled = enabled
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.confirmPaymentButton.alpha = enabled ? 1 : 0.3
        })
    }
    
    fileprivate func setUpPaymentMethodLabelAppearance() {
        
        self.paymentMethodLabel.font = UIFont.SFProDisplaySemiBoldFont(16.0)
        self.paymentMethodLabel.textColor = UIColor(red:(57.0/255.0), green:(57.0/255.0), blue:(57.0/255.0), alpha: 1.0)
        self.paymentMethodLabel.text = NSLocalizedString("payment_method_title", comment: "")
        
     //   self.payLabel.font = UIFont.bookFont(12.0)
      //  self.payLabel.textColor = UIColor(red:(143.0/255.0), green:(143.0/255.0), blue:(143.0/255.0), alpha: 1.0)
      //  self.payLabel.text = NSLocalizedString("paying_with_title", comment: "")
    }
    
    
    //MARK: TableView Data Source
    
    func registerTableViewCell() {
        
        let settingCellNib = UINib(nibName: "PaymentSelectionCell", bundle: Bundle(for: type(of: self)))
        self.tableView.register(settingCellNib, forCellReuseIdentifier: kPaymentSelectionCellIdentifier)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1 && remainingAmount > 0 {
            return 40
        }else{
            return 10
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 1 && remainingAmount > 0 {
            
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 40))
            headerView.backgroundColor = UIColor.white
            
            let headerLabel = UILabel(frame: CGRect(x: 15, y: 15, width: tableView.frame.size.width-15, height: 25))
            headerLabel.textAlignment = NSTextAlignment.left
            headerLabel.backgroundColor = UIColor.white
            
            let dict1 = [NSAttributedString.Key.foregroundColor: UIColor.darkTextGrayColor(),NSAttributedString.Key.font:UIFont.bookFont(10.0)]
            
            let dict2 = [NSAttributedString.Key.foregroundColor: UIColor.lightBlackColor(),NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(12.0)]
            
            let titlePart = NSMutableAttributedString(string:NSLocalizedString("payment_method_for_remaining_amount", comment: ""), attributes:dict1)
            
            let amontPart = NSMutableAttributedString(string:String(format:" %0.2f",remainingAmount), attributes:dict2)
            
            let attttributedText = NSMutableAttributedString()
            
            attttributedText.append(titlePart)
            attttributedText.append(amontPart)
            
            headerLabel.attributedText = attttributedText
            headerView.addSubview(headerLabel)
            
            return headerView
            
        }else{
            let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 10))
            headerView.backgroundColor = UIColor.white
            return headerView
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return kPaymentSelectionCellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let rows = 1
        return rows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:PaymentSelectionCell = tableView.dequeueReusableCell(withIdentifier: kPaymentSelectionCellIdentifier, for: indexPath) as! PaymentSelectionCell
        
        cell.configureCellWithTitle(titles[(indexPath as NSIndexPath).section], withImage: Images[(indexPath as NSIndexPath).section])
        if ((indexPath as NSIndexPath).section == 0){
            
            cell.walletAmount.isHidden = false
            cell.walletAmount.text = String(format: "%0.2f %@",walletAmount,CurrencyManager.getCurrentCurrency())
            
            if referralObject == nil || referralObject!.walletTotal == nil || Double(referralObject!.walletTotal!)! == 0 {
                cell.containerView.backgroundColor = UIColor.borderGrayColor()
            }else{
                cell.containerView.backgroundColor = UIColor.white
            }
        }else{
            cell.walletAmount.isHidden = true
            
            if self.lastSelection != nil {
                
                if (indexPath as NSIndexPath).section == lastSelection.section{
                    cell.checkedImgView.isHidden = false
                }else{
                    cell.checkedImgView.isHidden = true
                }
            
            }
        }
        
        return cell
    }
    
    
    //MARK: TableView Delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if ((indexPath as NSIndexPath).section == 0){
            
            if (Double(referralObject!.walletTotal!)! > 0) {
                
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                _ = WalletPopUp.showWalletPopUp(self, withTopView: appDelegate.window!, andWithTotalBillAmount: priceSum)
                ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_selected_wallet")
            }else{
                
                print("Empty Wallet.")
                
                let notification = ElGrocerAlertView.createAlert(NSLocalizedString("wallet_navigation_bar_title", comment: ""),description: NSLocalizedString("empty_wallet", comment: ""),positiveButton:nil,negativeButton:nil,buttonClickCallback:nil)
                notification.showPopUp()
            }
            
        }else{
            
            if self.lastSelection != nil {
                let lastSelectedCell:PaymentSelectionCell = tableView.cellForRow(at: lastSelection) as! PaymentSelectionCell
                lastSelectedCell.checkedImgView.isHidden = true
            }
            
            if titles[(indexPath as NSIndexPath).section] == NSLocalizedString("pay_via_cash", comment: "") {
                self.selectedPaymentOption = .cash
                ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_selected_cash")
            }else{
                self.selectedPaymentOption = .card
                ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("user_selected_card")
            }
            
            
            UserDefaults.setPaymentMethod(self.selectedPaymentOption.rawValue, forStoreId: "")
            
            let cell:PaymentSelectionCell = tableView.cellForRow(at: indexPath) as! PaymentSelectionCell
            cell.checkedImgView.isHidden = false
            self.lastSelection = indexPath
            self.setConfirmButtonEnabled(true)
        }
    }
    
    // MARK: Actions

    override func backButtonClick() {
        
        if self.selectedPaymentOption != PaymentOption.none {
            self.delegate?.confirmPaymentWithPaymentOption(self.selectedPaymentOption, andWithAmountPaidFromWallet: self.walletPaidAmount)
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmPaymentHandler(_ sender: AnyObject) {
        
        if self.selectedPaymentOption != PaymentOption.none {
            self.delegate?.confirmPaymentWithPaymentOption(self.selectedPaymentOption, andWithAmountPaidFromWallet: self.walletPaidAmount)
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension OrderPaymentSelectionViewController: WalletPopUpViewProtocol {
    
    func walletDidPayTapped(_ walletPopUp:WalletPopUp, paidAmount:String) {
        
        print("Paid Amount from Wallet:%@",paidAmount)
        
        walletPaidAmount = Double(paidAmount)!
        if (Double(paidAmount) < priceSum) {
             remainingAmount = priceSum - Double(paidAmount)!
             walletAmount = Double(paidAmount)!
             UserDefaults.setWalletPaidAmount(paidAmount)
             self.tableView.reloadData()
        }else{
           self.setConfirmButtonEnabled(true)
        }
    }
}
