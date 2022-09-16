//
//  ElWalletCardsVC.swift
//  ElGrocerShopper
//
//  Created by Salman on 09/05/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import Adyen

class ElWalletCardsVC: UIViewController, NavigationBarProtocol {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addNewBtnConatinerView: AWView!{
        didSet{
            
            //MARK: For top shadow
            //addNewBtnConatinerView.layer.masksToBounds = false
            addNewBtnConatinerView.layer.shadowOffset = CGSize(width: 0, height: -2)
            addNewBtnConatinerView.layer.shadowOpacity = 0.16
            addNewBtnConatinerView.layer.shadowRadius = 1
            addNewBtnConatinerView.layer.cornerRadius = 8
            addNewBtnConatinerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
    }
    @IBOutlet weak var addNewCardButton: AWButton!{
        didSet{
            addNewCardButton.cornarRadius = 28
            addNewCardButton.setButton2SemiBoldWhiteStyle()
            addNewCardButton.setTitle(NSLocalizedString("btn_add_new_card", comment: ""), for: UIControl.State())
        }
    }
    
    var creditCardA: [CreditCard] = []
    var selectedCreditCard: CreditCard?
    var viewModel = ElWalletHomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.registerCellsForTableView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setInitialAppearence()
    }
    
    private func setInitialAppearence() {
        
        self.setupNavigationAppearence()
        self.tableView.rowHeight = UITableView.automaticDimension
        self.tableView.estimatedRowHeight = 80
        self.setupBottomView()
    }
    
    private func bindData() {
    
    }
    
    func setupNavigationAppearence() {
        self.navigationController?.navigationBar.isHidden = false
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
        //self.addBackButton()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
        self.title = NSLocalizedString("txt_cards_small", comment: "")
        
    }
    
    private func registerCellsForTableView() {
        
        self.tableView.register(elWalletSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: elWalletSectionHeaderView.reuseId)

        self.tableView.register(elWalletSectionFooterView.nib, forHeaderFooterViewReuseIdentifier: elWalletSectionFooterView.reuseId)

        self.tableView.register(CardCell.nib, forCellReuseIdentifier: CardCell.reuseId)
        self.tableView.register(EmptyCardCell.nib, forCellReuseIdentifier: EmptyCardCell.reuseId)
    }
    
    override func backButtonClick() {
        guard let navCount = self.navigationController else {
            self.navigationController?.dismiss(animated: true, completion: nil)
            return
        }
        if  navCount.viewControllers.count == 1 {
            self.navigationController?.dismiss(animated: true, completion: nil)
        }else{
             self.navigationController?.popViewController(animated: true)
        }
    }
    
    func backButtonClickedHandler() {
        backButtonClick()
    }
    
    func setupBottomView() {
        
        self.addNewBtnConatinerView.isHidden = self.creditCardA.count > 0 ? false : true
    }
    
    @IBAction func addNewCardTapped(_ sender: AWButton) {
        
        self.goToAddNewCardController()
    }
    
    fileprivate func getCardCell(_ tableView: UITableView, indexPath: IndexPath) -> CardCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CardCell.reuseId, for: indexPath) as! CardCell
        cell.configCell(creditCardA[indexPath.row])
        return cell
    }
    
    fileprivate func getEmptyCardCell(_ tableView: UITableView, indexPath: IndexPath) -> EmptyCardCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EmptyCardCell.reuseId, for: indexPath) as! EmptyCardCell
        cell.addNewCardClosure = {
            self.goToAddNewCardController()
        }
        return cell
    }
    func navigateToPaymentSuccessVC(isSuccess: Bool, creditCard: CreditCard? = nil, controllerType: PaymentControllerSuccessType) {
        
        let vc = ElGrocerViewControllers.getPaymentSuccessVC()
        vc.isSuccess = isSuccess
        vc.controlerType = controllerType
        vc.creditCard = creditCard
        vc.ispushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func goToAddNewCardController() {
        
        AdyenManager.sharedInstance.performZeroTokenization(controller: self,true)
        AdyenManager.sharedInstance.walletPaymentMade = {(error, response, adyenObj) in
            SpinnerView.hideSpinnerView()
            if error {
                self.navigateToPaymentSuccessVC(isSuccess: false, controllerType: .cardAdd)
            }
        }
        AdyenManager.sharedInstance.isNewCardAdded = { (error , response, adyenObj) in
            if error {
                print("error in authorization")
                if let resultCode = response["resultCode"] as? String {
                    print(resultCode)
                    self.parseAdyenResponse(response: response)
                    self.navigateToPaymentSuccessVC(isSuccess: false, creditCard: nil, controllerType: .cardAdd)
                    //handle faliure Case
                }
            }else{
                //handle success case
                self.parseAdyenResponse(response: response)
                self.navigateToPaymentSuccessVC(isSuccess: true, creditCard: nil, controllerType: .cardAdd)
            }
        }
    }
    
    func parseAdyenResponse(response: NSDictionary) {
        
        print(response)
    }
    
    func getAdyenPaymentMethods() {
        viewModel.getAdyenPaymentMethods(isApplePayAvailbe: false, shouldAddVoucher: false) { paymentMethodA, creditCardA, applePayPaymentMethod, error in
            if error != nil {
                error?.showErrorAlert()
            }
            if let creditA = creditCardA {
                self.creditCardA = creditA
            }
            
            Thread.OnMainThread {
                self.tableView.reloadData()
                self.setupBottomView()
                
            }
        }
    }
    
    //MARK: Delete Card
    
    func deleteCardAt( _ index : Int) {
        
        let vc = ElGrocerViewControllers.getDeleteCardConfirmationBottomSheet()
        vc.selectedClosure = { (shouldRemove) in
            if shouldRemove {
                self.deleteCardCall(index)
            }
        }
        vc.modalPresentationStyle = .overCurrentContext
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true)
    }
    func deleteCardCall(_ index: Int)  {
        
        let card = self.creditCardA[index]
        
        AdyenApiManager().deleteCreditCard(recurringDetailReference: card.cardID) { (error, response) in
            if let error = error {
                error.showErrorAlert()
                return
            } else {
                if let data = response?["data"] as? NSDictionary {
                    if let responseData = data["response"] as? NSDictionary {
                        let status = response?["status"] as? String
                        if status ==  "success" {
                            self.creditCardA.remove(at: index)
                        }
                        self.tableView.reloadDataOnMain()
                    }
                }
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension ElWalletCardsVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditCardA.count == 0 ? 1 : creditCardA.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if creditCardA.count>0 {
            return getCardCell(tableView, indexPath: indexPath)
        } else {
            self.tableView.isEditing = false
            return getEmptyCardCell(tableView, indexPath: indexPath)
        }
        
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "elWalletSectionHeaderView") as! elWalletSectionHeaderView
        if self.creditCardA.count == 0 {
            headerView.configureHeaderView(title: NSLocalizedString("txt_cards_title", comment: ""), buttonName: "")
            headerView.moveToDetailsButton.isUserInteractionEnabled = false
        }else if(self.tableView.isEditing == true) {
            headerView.configureHeaderView(title: NSLocalizedString("txt_cards_title", comment: ""), buttonName: NSLocalizedString("btn_done_edit_card", comment: ""))
            headerView.moveToDetailsButton.isUserInteractionEnabled = true
        }else {
            headerView.configureHeaderView(title: NSLocalizedString("txt_cards_title", comment: ""), buttonName: NSLocalizedString("btn_edit_card", comment: ""))
            headerView.moveToDetailsButton.isUserInteractionEnabled = true
        }
        headerView.moveNext = {
            if(self.tableView.isEditing == true) {
                self.tableView.isEditing = false
                headerView.moveToDetailsButton.setTitle(NSLocalizedString("btn_edit_card", comment: ""), for: UIControl.State())
            } else {
                self.tableView.isEditing = true
                headerView.moveToDetailsButton.setTitle(NSLocalizedString("btn_done_edit_card", comment: ""), for: UIControl.State())
            }
        }
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "elWalletSectionFooterView") as! elWalletSectionFooterView
        //footerView.footerLabel.text = "TableView Footer \(section)"
        return footerView
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            self.deleteCardAt(indexPath.row)
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
            cell.backgroundColor = UIColor.tableViewBackgroundColor() // Your color here!
    }
}
