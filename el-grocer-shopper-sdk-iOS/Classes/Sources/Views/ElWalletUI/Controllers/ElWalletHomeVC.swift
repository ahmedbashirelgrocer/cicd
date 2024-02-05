    //
    //  ElWalletHomeVC.swift
    //  ElGrocerShopper
    //
    //  Created by Salman on 28/04/2022.
    //  Copyright © 2022 elGrocer. All rights reserved.
    //

import UIKit
import Adyen

class ElWalletHomeVC: UIViewController, NavigationBarProtocol {
    
    @IBOutlet weak var walletAmountLabel: UILabel!
    
    @IBOutlet weak var addFundImage: UIImageView! {
        didSet{
            addFundImage.image = sdkManager.isShopperApp ? UIImage(name: "add-circle-filled-Elgrocer") :UIImage(name: "addFundImage")
        }
    }
    @IBOutlet weak var addFundsButton: UIButton! {
        didSet {
            addFundsButton.setTitle(localizedString("txt_add_funds", comment: "Add Fuunds"), for: UIControl.State())
        }
    }
    @IBOutlet weak var walletTableView: UITableView!
    
    var userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    var paymentMethodA: [Any] = []
    let addNewCardCell: String = KAddNewCellString
    var selectedApplePayMethod: ApplePayPaymentMethod?
    var creditCardA: [CreditCard] = []
    
    var voucherData: VoucherRecord?
    var allVouchers: [Voucher] = [Voucher]()
    
    var transactionData: TransactionRecord?
    var allTransection: [Transaction] = [Transaction]()
    var isFirstTime: Bool = true
    private let viewModel = ElWalletHomeViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
            // Do any additional setup after loading the view.
        setInitialAppearence()
        bindData()
        
        // Logging segment screen event
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .elWalletScreen))
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupNavigationAppearence()
        if isFirstTime {
            let _ = SpinnerView.showSpinnerViewInView(self.view)
            isFirstTime = false
        }
        viewModel.getWalletAvailableBalance()
        viewModel.fetchVoucherData()
        viewModel.fetchTransactionData()
        self.getAdyenPaymentMethods(isApplePayAvailbe: true, shouldAddVoucher: true)
    }
    
    private func setInitialAppearence() {
        
        self.setupNavigationAppearence()
        self.registerCellsForTableView()
        self.walletTableView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
        self.walletTableView.rowHeight = UITableView.automaticDimension
        self.walletTableView.estimatedRowHeight = UITableView.automaticDimension
        self.walletTableView.separatorStyle = .none
        
        walletAmountLabel.font = UIFont.SFProDisplaySemiBoldFont(28)
        walletAmountLabel.textColor = UIColor.newBlackColor()
        
        addFundsButton.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(20)
        addFundsButton.setTitleColor(ApplicationTheme.currentTheme.buttonTextWithClearBGColor, for: UIControl.State())
    }
    
    private func bindData() {
        
        viewModel.voucherInfo.bind { [weak self] voucherdata in
            self?.voucherData = voucherdata
        }
        
        viewModel.allVouchers.bind { [weak self] vouchers in
            self?.allVouchers = vouchers
            self?.walletTableView.reloadSections(IndexSet([0]), with: .none)
        }
        
        viewModel.allTransactions.bind { [weak self] transactions in
            self?.allTransection = transactions
            self?.walletTableView.reloadSections(IndexSet([2]), with: .none)
        }
        
        viewModel.transactionInfo.bind { [weak self] transactiondata in
            self?.transactionData = transactiondata
            self?.walletAmountLabel.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: self?.viewModel.walletBalance.value ?? 0.0)
        }
        
        viewModel.walletBalance.bind { [weak self] data in
            self?.walletAmountLabel.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: data ?? 0.0)
        }
        
    }
    
    func setupNavigationAppearence() {
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(false)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.actiondelegate = self
            //self.addBackButton()
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.barTintColor = .navigationBarWhiteColor()
        self.title = localizedString("txt_title_elWallet", comment: "")
        
    }
    
    private func registerCellsForTableView() {
        
        self.walletTableView.estimatedRowHeight = UITableView.automaticDimension
        self.walletTableView.rowHeight = UITableView.automaticDimension
        self.walletTableView.register(elWalletSectionHeaderView.nib, forHeaderFooterViewReuseIdentifier: elWalletSectionHeaderView.reuseId)
        
        self.walletTableView.register(elWalletSectionFooterView.nib, forHeaderFooterViewReuseIdentifier: elWalletSectionFooterView.reuseId)
        
        self.walletTableView.register(VouchersCell.nib, forCellReuseIdentifier: VouchersCell.reuseId)
        self.walletTableView.register(EmptyVouchersCell.nib, forCellReuseIdentifier: EmptyVouchersCell.reuseId)
        
        self.walletTableView.register(CardCell.nib, forCellReuseIdentifier: CardCell.reuseId)
        self.walletTableView.register(EmptyCardCell.nib, forCellReuseIdentifier: EmptyCardCell.reuseId)
        
        self.walletTableView.register(TransactionsCell.nib, forCellReuseIdentifier: TransactionsCell.reuseId)
        self.walletTableView.register(EmptyTransactionsCell.nib, forCellReuseIdentifier: EmptyTransactionsCell.reuseId)
    }
    
    override func backButtonClick() {
        MixpanelEventLogger.trackElWalletClose()
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
    func navigateToAddFundsVC(methodSelect: Any, creditCard: CreditCard? = nil) {
        let fundsVC = ElGrocerViewControllers.getElWalletAddFundsVC()
        fundsVC.paymentOption = methodSelect
        fundsVC.creditCard = creditCard
        fundsVC.applePaymentMethod = self.selectedApplePayMethod
        
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [fundsVC]
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: { });
    }
    func navigateToPaymentSuccessVC(isSuccess: Bool, creditCard: CreditCard? = nil, controllerType: PaymentControllerSuccessType) {
        
        let vc = ElGrocerViewControllers.getPaymentSuccessVC()
        vc.isSuccess = isSuccess
        vc.controlerType = controllerType
        vc.creditCard = creditCard
        vc.ispushed = false
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [vc]
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: { });
    }
    
    @IBAction func addFundsButtonTapped(_ sender: UIButton) {
        
        // Logging segment event for add fund clicked
        SegmentAnalyticsEngine.instance.logEvent(event: AddFundClickedEvent())
        
        MixpanelEventLogger.trackElWalletAddFundsClicked()
        let creditVC = CreditCardListViewController(nibName: "CreditCardListViewController", bundle: .resource)
        if #available(iOS 13, *) {
            creditVC.view.backgroundColor = .clear
        } else {
            creditVC.view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        }
        creditVC.userProfile = self.userProfile
        creditVC.isNeedShowAllPaymentType = true
        creditVC.isFromWallet = true
        creditVC.paymentMethodA =  self.paymentMethodA
            //        creditVC.selectedGrocery = ElGrocerUtility.sharedInstance.activeGrocery ?? ElGrocerUtility.sharedInstance.gricer[0]
        let navigation = ElgrocerGenericUIParentNavViewController.init(rootViewController: creditVC)
        if #available(iOS 13, *) {
            navigation.view.backgroundColor = .clear
        }else{
            navigation.view.backgroundColor = UIColor.white.withAlphaComponent(0.5)
        }
        
        creditVC.paymentMethodSelection = { [weak self] (methodSelect) in
            guard let self = self else {return}
            
            
            if (methodSelect as? PaymentOption) == PaymentOption.voucher {
                MixpanelEventLogger.trackElwalletAddFundPaymentMethodSelection(methodName: "VOUCHER")
                self.getElWalletViewAll()
                
                // Logging segment event for fund method selected
                SegmentAnalyticsEngine.instance.logEvent(event: FundMethodSelectedEvent(paymentMethod: PaymentOption.voucher))
                return
            }
            if methodSelect is CreditCard {
                MixpanelEventLogger.trackElwalletAddFundPaymentMethodSelection(methodName: "CARD")
                
                // Logging segment event for fund method selected
                SegmentAnalyticsEngine.instance.logEvent(event: FundMethodSelectedEvent(paymentMethod: PaymentOption.creditCard))
                
            }else if (methodSelect as? PaymentOption) == PaymentOption.applePay {
                MixpanelEventLogger.trackElwalletAddFundPaymentMethodSelection(methodName: "APPLE_PAY")
                
                // Logging segment event for fund method selected
                SegmentAnalyticsEngine.instance.logEvent(event: FundMethodSelectedEvent(paymentMethod: PaymentOption.applePay))
            }
            self.navigateToAddFundsVC(methodSelect: methodSelect as Any)
        }
        
        creditVC.goToAddNewCard = { [weak self] (credit) in
            guard let self = self else {return}
            MixpanelEventLogger.trackElwalletAddFundPaymentMethodSelectionAddNewCardClicked()
            self.goToAddNewCardController()
            
        }
        // below not using for wlwallet
        creditVC.newCardAdded = {[weak self](paymentArray) in
            guard let self = self else {return}
            self.paymentMethodA = paymentArray
            self.walletTableView.reloadDataOnMain()
        }
        
        creditVC.creditCardSelected = { [weak self] (creditCardSelected) in
            guard let self = self else {return}
            
            self.navigateToAddFundsVC(methodSelect: PaymentOption.creditCard,creditCard: creditCardSelected)
            
        }
        
        creditVC.applePaySelected = { [weak self] (applePaySelected) in
            guard let self = self else {return}
            self.navigateToAddFundsVC(methodSelect: PaymentOption.applePay)
            
        }
        
        creditVC.creditCardDeleted = { [weak self] (creditCardSelected) in
            guard let self = self else {return}
            
        }
        
        creditVC.addCard = {
        }
        self.present(navigation, animated: true, completion: nil)
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
               //  print("error in authorization")
                if let resultCode = response["resultCode"] as? String {
                   //  print(resultCode)
                    self.navigateToPaymentSuccessVC(isSuccess: false, creditCard: nil, controllerType: .cardAdd)
                        // handle faliure case
                }
            }else{
                    //handle success case
               //  print(response)
                self.navigateToPaymentSuccessVC(isSuccess: true, creditCard: nil, controllerType: .cardAdd)
                
                // Logging segment event for card added event
                SegmentAnalyticsEngine.instance.logEvent(event: CardAddedEvent())
            }
        }
    }
    
    
    func getAdyenPaymentMethods(isApplePayAvailbe: Bool = false, shouldAddVoucher: Bool = false) {
        
        viewModel.getAdyenPaymentMethods(isApplePayAvailbe: isApplePayAvailbe, shouldAddVoucher: shouldAddVoucher) { (paymentMethodA, creditCardA, applePayPaymentMethod, error) in
            SpinnerView.hideSpinnerView()
            if error != nil {
                error?.showErrorAlert()
            }
            
            if let paymentMethodA = paymentMethodA {
                self.paymentMethodA = paymentMethodA
            }
            
            if let creditCardA = creditCardA {
                self.creditCardA = creditCardA
                Thread.OnMainThread {
                    self.walletTableView.reloadSections(IndexSet([1]), with: .fade)
                }
            }
            
            if let applePayPaymentMethod = applePayPaymentMethod {
                self.selectedApplePayMethod = applePayPaymentMethod
            }
            
        }
    }
    
    func navigateToSuccessVCForVoucher(voucher: Voucher, isSuccess: Bool, voucherValue: String) {
        let vc = ElGrocerViewControllers.getPaymentSuccessVC()
        vc.controlerType = .voucher
        vc.isSuccess = isSuccess
        vc.voucher = voucher.code
        vc.voucherValue = voucherValue
        vc.ispushed = false
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.viewControllers = [vc]
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: { });
    }
    
    fileprivate func getVouchersCell(_ tableView: UITableView, indexPath: IndexPath) -> VouchersCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: VouchersCell.reuseId, for: indexPath) as! VouchersCell
        cell.configure(allVouchers[indexPath.row])
        cell.viewDetailButton.tag = indexPath.row
        cell.redeemButton.tag = indexPath.row
        cell.showVoucherDetails = {
            self.walletTableView.beginUpdates()
            let objIndex = cell.viewDetailButton.tag
            let indexpath = IndexPath(row: cell.viewDetailButton.tag, section: 0)
            self.allVouchers[objIndex].showDetails = !self.allVouchers[objIndex].showDetails
            self.walletTableView.reloadRows(at: [indexpath], with: .automatic)
            self.walletTableView.endUpdates()
        }
        cell.redeemVoucher = { [weak self](voucher) in
            let _ = SpinnerView.showSpinnerView()
            MixpanelEventLogger.trackElWalletRedeemVoucherClicked(voucherId: String(voucher.id), voucherCode: voucher.code ?? "")
            self?.viewModel.redeemVoucherWith(code: voucher.code ?? "") { error, response in
                SpinnerView.hideSpinnerView()
                if error == nil {
                    if let value = (response?["data"] as? NSDictionary)?["value_cents"] as? NSNumber {
                        let valueAED: Int = value.intValue / 100
                        self?.navigateToSuccessVCForVoucher(voucher: voucher, isSuccess: true, voucherValue: String(valueAED))
                    }else {
                        self?.navigateToSuccessVCForVoucher(voucher: voucher, isSuccess: false, voucherValue: "")
                    }
                } else {
                   //  print("something wrong ho gaya")
                    self?.navigateToSuccessVCForVoucher(voucher: voucher, isSuccess: false, voucherValue: "")
                }
            }
            
        }
            //cell.textLabel?.text = "IndexPath \(indexPath.row)"
        return cell
    }
    
    fileprivate func getEmptyVouchersCell(_ tableView: UITableView, indexPath: IndexPath) -> EmptyVouchersCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EmptyVouchersCell.reuseId, for: indexPath) as! EmptyVouchersCell
        return cell
    }
    
    fileprivate func getCardCell(_ tableView: UITableView, indexPath: IndexPath) -> CardCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: CardCell.reuseId, for: indexPath) as! CardCell
        cell.configCell(creditCardA[indexPath.row])
        return cell
    }
    
    fileprivate func getEmptyCardCell(_ tableView: UITableView, indexPath: IndexPath) -> EmptyCardCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EmptyCardCell.reuseId, for: indexPath) as! EmptyCardCell
        cell.addNewCardClosure = {
            MixpanelEventLogger.trackElwalletAddNewCardClicked()
            self.goToAddNewCardController()
        }
        return cell
    }
    
    fileprivate func getTransactionsCell(_ tableView: UITableView, indexPath: IndexPath) -> TransactionsCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: TransactionsCell.reuseId, for: indexPath) as! TransactionsCell
        if allTransection[indexPath.row] != nil {
            cell.configure(allTransection[indexPath.row])
            if indexPath.row == 1 {
                cell.lineView.isHidden = true
            }else {
                cell.lineView.isHidden = false
            }
        }
        
        return cell
    }
    
    fileprivate func getEmptyTransactionsCell(_ tableView: UITableView, indexPath: IndexPath) -> EmptyTransactionsCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EmptyTransactionsCell.reuseId, for: indexPath) as! EmptyTransactionsCell
        return cell
    }
}


extension ElWalletHomeVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
            case 0:
                var count = 1
                count = allVouchers.count > 1 ? 2 : 1//allVouchers.count
                return count
            case 1:
                var count = 1
                count = creditCardA.count > 1 ? 2 : 1//creditCardA.count
                return count
            case 2:
                var count = 1
                count = allTransection.count > 1 ? 2 : 1//allTransection.count
                return count
            default:
                return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
            case 0:
                if allVouchers.count>0 {
                    return getVouchersCell(tableView, indexPath: indexPath)
                } else {
                    return getEmptyVouchersCell(tableView, indexPath: indexPath)
                }
            case 1:
                if creditCardA.count>0 {
                    return getCardCell(tableView, indexPath: indexPath)
                } else {
                    return getEmptyCardCell(tableView, indexPath: indexPath)
                }
            case 2:
                if allTransection.count>0 {
                    return getTransactionsCell(tableView, indexPath: indexPath)
                } else {
                    return getEmptyTransactionsCell(tableView, indexPath: indexPath)
                }
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "VouchersCell", for: indexPath) as! VouchersCell
                return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let voucherCell = cell as? VouchersCell {
            DispatchQueue.main.async { [weak cell] in
                voucherCell.voucherCodeBorderView.addDashedBorderAroundView(color: ApplicationTheme.currentTheme.buttonWithBorderTextColor)
            }
        }
        if cell != nil {
            colorSection(tableView, willDisplay: cell, forRowAt: indexPath)
        }
    }
    
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "elWalletSectionHeaderView") as! elWalletSectionHeaderView
            //headerView.sectionTitleLabel.text = "TableView Heder \(section)"
        switch section {
            case 0:
                let title = localizedString("txt_active_vouchers", comment: "active vouchers") + "(\(self.voucherData?.activeVoucherCount ?? 0))"
                let buttonName = localizedString("txt_view_all", comment: "")
                headerView.configureHeaderView(title: title, buttonName: buttonName )
                headerView.moveNext = {
                    MixpanelEventLogger.trackElWalletVoucherViewAllClicked()
                    let voucherVC = ElGrocerViewControllers.getElWalletVouchersVC()
                        //TODO: viewModel should be assign by a method not like this
                    voucherVC.viewModel = self.viewModel
                    let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                    navigationController.hideSeparationLine()
                    navigationController.viewControllers = [voucherVC]
                    navigationController.modalPresentationStyle = .fullScreen
                    self.navigationController?.present(navigationController, animated: true)
                }
            case 1:
                headerView.configureHeaderView(title: localizedString("txt_cards_capital", comment: "cards"), buttonName: localizedString("txt_manage_cards", comment: ""))
                headerView.moveNext = {
                    MixpanelEventLogger.trackElWalletManageCardsClicked()
                    let cardsVC = ElGrocerViewControllers.getElWalletCardsVC()
                    cardsVC.creditCardA = self.creditCardA
                    cardsVC.viewModel = self.viewModel
                    let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                    navigationController.hideSeparationLine()
                    navigationController.viewControllers = [cardsVC]
                    navigationController.modalPresentationStyle = .fullScreen
                    self.present(navigationController, animated: true)
                }
            case 2:
                headerView.configureHeaderView(title: localizedString("txt_transection_history", comment: "transec"), buttonName: localizedString("txt_view_all", comment: ""))
                headerView.moveNext = {
                    MixpanelEventLogger.trackElwalletTransactionsViewAllClicked()
                    let transactionVC = ElGrocerViewControllers.getElWalletTransactionVC()
                    transactionVC.balance = self.viewModel.walletBalance.value
                    let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
                    navigationController.hideSeparationLine()
                    navigationController.viewControllers = [transactionVC]
                    navigationController.modalPresentationStyle = .fullScreen
                    self.navigationController?.pushViewController(transactionVC, animated: true)
                }
            default:
                headerView.configureHeaderView(title: "", buttonName: "")
                
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
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func colorSection(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let cornerRadius: CGFloat = 0.0
        cell.backgroundColor = UIColor.clear
        tableView.backgroundColor = .clear
        let layer: CAShapeLayer = CAShapeLayer()
        let pathRef: CGMutablePath = CGMutablePath()
        let bounds: CGRect = cell.bounds.insetBy(dx: 8, dy: 0)
        var addLine: Bool = false
        
        if indexPath.row == 0 && indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            pathRef.addRoundedRect(in: bounds, cornerWidth: cornerRadius, cornerHeight: cornerRadius)
        } else if indexPath.row == 0 {
            pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.maxY))
            pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.minY),
                           tangent2End: CGPoint(x: bounds.midX, y: bounds.minY),
                           radius: cornerRadius)
            
            pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.minY),
                           tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY),
                           radius: cornerRadius)
            pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
            addLine = true
        } else if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
            pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.maxY),
                           tangent2End: CGPoint(x: bounds.midX, y: bounds.maxY),
                           radius: cornerRadius)
            
            pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.maxY),
                           tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY),
                           radius: cornerRadius)
            pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
        } else {
            pathRef.move(to: CGPoint(x: bounds.minX, y: bounds.minY))
            pathRef.addArc(tangent1End: CGPoint(x: bounds.minX, y: bounds.maxY),
                           tangent2End: CGPoint(x: bounds.midX, y: bounds.maxY),
                           radius: cornerRadius)
            
            pathRef.move(to: CGPoint(x: bounds.maxX, y: bounds.maxY))
            pathRef.addArc(tangent1End: CGPoint(x: bounds.maxX, y: bounds.maxY),
                           tangent2End: CGPoint(x: bounds.maxX, y: bounds.midY),
                           radius: cornerRadius)
            pathRef.addLine(to: CGPoint(x: bounds.maxX, y: bounds.minY))
            addLine = true
        }
        
        layer.path = pathRef
        layer.strokeColor = UIColor.lightGray.cgColor
        layer.lineWidth = 1.0
        layer.fillColor = UIColor.clear.cgColor
        
        if addLine == true {
            let lineLayer: CALayer = CALayer()
            let lineHeight: CGFloat = (1 / UIScreen.main.scale)
            lineLayer.frame = CGRect(x: bounds.minX, y: bounds.size.height - lineHeight, width: bounds.size.width, height: lineHeight)
            lineLayer.backgroundColor = UIColor.clear.cgColor
//            layer.addSublayer(lineLayer)
            cell.contentView.layer.insertSublayer(layer, at: 0)
        }
        
        let backgroundView: UIView = UIView(frame: bounds)
        backgroundView.layer.insertSublayer(layer, at: 0)
        backgroundView.backgroundColor = .clear
        cell.backgroundView = backgroundView
    }
    
}
extension ElWalletHomeVC  {
    
    private func getElWalletViewAll() {
        let voucherVC = ElGrocerViewControllers.getElWalletVouchersVC()
        voucherVC.allVouchers = self.allVouchers
        voucherVC.voucherData = self.voucherData
            //TODO: viewModel should be assign by a method not like this
        voucherVC.viewModel = self.viewModel
        let navigationController = ElGrocerNavigationController(navigationBarClass: ElGrocerNavigationBar.self, toolbarClass: UIToolbar.self)
        navigationController.hideSeparationLine()
        navigationController.viewControllers = [voucherVC]
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true)
    }
    
    
}

