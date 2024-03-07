    //
    //  ApplyPromoVC.swift
    //  ElGrocerShopper
    //
    //  Created by Abdul Saboor on 20/04/2022.
    //  Copyright © 2022 elGrocer. All rights reserved.
    //

import UIKit

class ApplyPromoVC: UIViewController {
    
        //MARK: text PromoView outlets
    @IBOutlet var promoBGView: UIView! {
        didSet {
            promoBGView.isHidden = false
        }
    }
    @IBOutlet var promoTxtFieldBGView: AWView!
    @IBOutlet var lblPromoError: UILabel!{
        didSet{
            lblPromoError.setCaptionOneRegErrorStyle()
            lblPromoError.visibility = .gone
            lblPromoError.numberOfLines = 0
        }
    }
    @IBOutlet var promoTextField: UITextField!{
        didSet{
            promoTextField.setBody3RegStyle()
            promoTextField.setPlaceHolder(text: localizedString("promo_textfield_placeholder", comment: ""))
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                promoTextField.textAlignment = .right
            }else {
                promoTextField.textAlignment = .left
            }
        }
    }
    @IBOutlet var btnPromoApply: AWButton!{
        didSet{
            btnPromoApply.setTitle(localizedString("promo_code_alert_yes", comment: ""), for: UIControl.State())
            btnPromoApply.setTitleColor(ApplicationTheme.currentTheme.buttonTextWithClearBGColor, for: UIControl.State())
        }
    }
    @IBOutlet var btnPromoRemove: AWButton! {
        didSet {
            btnPromoRemove.setTitle(localizedString("txt_remove", comment: ""), for: UIControl.State())
            btnPromoRemove.isHidden = true
        }
    }
    @IBOutlet var promoActivityIndicator: UIActivityIndicatorView!{
        didSet{
            promoActivityIndicator.color = ApplicationTheme.currentTheme.themeBasePrimaryColor
            promoActivityIndicator.hidesWhenStopped = true
            promoActivityIndicator.isHidden = true
        }
    }
    @IBOutlet var promoBGViewHeightConstraint: NSLayoutConstraint!
        //MARK: text PromoView outlets end
    @IBOutlet var lblVCTitle: UILabel! {
        didSet {
            lblVCTitle.setH4SemiBoldStyle()
            lblVCTitle.text = localizedString("title_apply_promo", comment: "")
        }
    }
    @IBOutlet var btnClose: UIButton!
    @IBOutlet var tblView: UITableView! {
        didSet {
            tblView.backgroundColor = ApplicationTheme.currentTheme.tableViewBGWhiteColor
            tblView.contentInsetAdjustmentBehavior = .never
        }
    }
    lazy var titleHeaderView : PromoTitleView = {
        let view = PromoTitleView.loadFromNib()
        return view!
    }()
    typealias promoApplied = (_ promoApplied: Bool,_ promoCode: PromotionCode?)-> Void
    var isPromoApplied : promoApplied?
    var dismissWithoutPromoClosure: ((Bool)->())?
    var isDismisingWithPromoApplied: Bool = false
    var promoCodeArray: [PromotionCode] = []
    var extensionArray: [Bool] = []
    var priviousPaymentOption: PaymentOption?
    var previousGrocery: Grocery?
    var priviousPrice: Double?
    var priviousShoppingItems: [ShoppingBasketItem]?
    var priviousFinalizedProductA: [Product]?
    var priviousOrderId: String?
    var isGettingPromo: Bool = false
    var isFirstTime: Bool = true
    var promoCode: PromoCode?
    override func viewDidLoad() {
        super.viewDidLoad()
        registerTableView()
        getPromoCodeList()
        
            // Do any additional setup after loading the view.
    }
    
    func registerTableView() {
        self.tblView.delegate = self
        self.tblView.dataSource = self
        self.tblView.separatorStyle = .none
        self.tblView.allowsSelection = false
        self.tblView.rowHeight = UITableView.automaticDimension
        self.tblView.estimatedRowHeight = UITableView.automaticDimension
        self.tblView.bounces = false
        self.tblView.contentInset = UIEdgeInsets.init(top: -20, left: 0, bottom: 0, right: 0)
        
        
        let cell = UINib(nibName: "ApplyPromoCell", bundle: .resource)
        tblView.register(cell, forCellReuseIdentifier: "ApplyPromoCell")
        let NoPromoTableViewCell = UINib(nibName: "NoPromoTableViewCell", bundle: .resource)
        tblView.register(NoPromoTableViewCell, forCellReuseIdentifier: "NoPromoTableViewCell")
    }
    func checkPromoCodeIsFromTextOrList() {
        if self.priviousOrderId?.count ?? 0 > 0 {
            if let promocode = self.promoCode?.code {
                let promo = promoCodeArray.filter { (promo) -> Bool in
                    promo.code.elementsEqual(promocode)
                }
                if promo.count > 0 {
                    UserDefaults.setPromoCodeIsFromText(nil)
                    self.btnPromoRemove.isHidden = true
                    self.btnPromoApply.isHidden = false
                    self.isDismisingWithPromoApplied = false
                }else {
                    self.isDismisingWithPromoApplied = true
                    UserDefaults.setPromoCodeIsFromText(true)
                    self.btnPromoRemove.isHidden = false
                    self.btnPromoApply.isHidden = true
                    self.promoTextField.text = promocode
                    self.showPromoError(false, message: localizedString("txt_enjoy_promo", comment: ""),color: ApplicationTheme.currentTheme.labelPrimaryBaseTextColor)
                }
            }
            
        }else {
            if let promoCode = self.promoCode?.code {
                let promo = promoCodeArray.filter { (promo) -> Bool in
                    promo.code.elementsEqual(promoCode)
                }
                if promo.count == 0 {
                    self.isDismisingWithPromoApplied = true
                    self.btnPromoRemove.isHidden = false
                    self.btnPromoApply.isHidden = true
                    self.promoTextField.text = promoCode
                    self.showPromoError(false, message: localizedString("txt_enjoy_promo", comment: ""),color: ApplicationTheme.currentTheme.labelPrimaryBaseTextColor)
                }
            }
        }
        
    }
    @IBAction func btnCloseHandler(_ sender: Any) {
        self.dismiss(animated: true)
        elDebugPrint(self.isDismisingWithPromoApplied)
        if let dismissWithoutPromoClosure = self.dismissWithoutPromoClosure {
            dismissWithoutPromoClosure(self.isDismisingWithPromoApplied)
        }
    }
    @IBAction func btnPromoRemoveHandler(_ sender: Any) {
        UserDefaults.setPromoCodeValue(nil)
        UserDefaults.setPromoCodeIsFromText(nil)
        self.isDismisingWithPromoApplied = false
        self.promoTextField.text = ""
        self.btnPromoApply.isHidden = false
        self.btnPromoRemove.isHidden = true
        self.showPromoError(true, message: "")
        MixpanelEventLogger.trackCheckoutVoucherRemoved(code: promoCode?.code ?? "", id: String(promoCode?.promotionCodeRealizationID ?? -1))
        self.promoCode = nil
        if let isPromoApplied = self.isPromoApplied {
            isPromoApplied(false, nil)
        }
        self.tblView.reloadDataOnMain()
    }
    @IBAction func btnApplyPromoHandler(_ sender: Any) {
        if self.promoTextField.text != ""{
            FireBaseEventsLogger.ApplyPromoClick(index: -1000 , code: promoTextField.text ?? "")
            self.checkPromoCodeRealisation(self.promoTextField.text!, self.priviousOrderId, withAnimation: true)
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
extension ApplyPromoVC {
        // Api parsing
    func getPromoCodeList() {
        guard !isGettingPromo else {return}
        guard self.promoCodeArray.count % 10 == 0 || self.promoCodeArray.count == 0 else{
            return
        }
        if isFirstTime {
            SpinnerView.showSpinnerViewInView(self.view)
        }
        let promoHandler = PromotionCodeHandler()
        promoHandler.grocery = self.previousGrocery
        isGettingPromo = true
        let offset = self.promoCodeArray.count
       //  print("offset: \(offset)")
        promoHandler.getPromoList (limmit: 10, offset: offset){ promoCodeArray, error in
            self.isGettingPromo = false
            self.isFirstTime = false
            SpinnerView.hideSpinnerView()
            if error != nil {
                error?.showErrorAlert()
                return
            }
            if let array = promoCodeArray{
                    //                self.promoCodeArray = array
                for promo in array {
                    self.promoCodeArray.append(promo)
                    self.extensionArray.append(false)
                }
                self.tblView.reloadDataOnMain()
                self.checkPromoCodeIsFromTextOrList()
            }
        }
    }
    
    func checkPromoCodeRealisation (_ text : String , _ orderID : String? = nil, withAnimation: Bool = false) {
        guard let grocery = self.previousGrocery ,let price = self.priviousPrice, let shoppingItems = self.priviousShoppingItems, let paymentOption =  self.priviousPaymentOption else{
            return
        }
        if withAnimation {
            self.promoActivityIndicator.startAnimating()
            self.btnPromoApply.isHidden = true
        }else {
            SpinnerView.showSpinnerViewInView(self.view)
        }
        
        let promoHandler = PromotionCodeHandler(paymentOption: paymentOption, grocery: grocery, price: price, shoppingItems: shoppingItems, orderId: orderID)
        
        promoHandler.checkPromoCode(promoText: text,isFromText: withAnimation) { promoCode, error in
            
            
            SpinnerView.hideSpinnerView()
            
            if error != nil {
                MixpanelEventLogger.trackCheckoutPromoError(promoCode: text, error: error?.localizedMessage ?? "")
                self.isDismisingWithPromoApplied = false
                if let isPromoApplied = self.isPromoApplied {
                    isPromoApplied(false, nil)
                }
                if withAnimation {
                    self.showPromoError(false, message: error?.message ?? "")
                    self.animateFailureForPromo()
                }else {
                    error?.showErrorAlert()
                }
                return
            }
            let promoCodeToSet = PromoCode(code: promoCode?.code, promotionCodeRealizationID: promoCode?.id, value: promoCode?.valueCents, errorMessage: "")
            self.promoCode = promoCodeToSet
            self.isDismisingWithPromoApplied = true
            if let isPromoApplied = self.isPromoApplied {
                isPromoApplied(true, promoCode)
            }
            
            // Loggign segment event for promocode applied
            let promoCodeAppliedEvent = PromoCodeAppliedEvent(isApplied: true, promoCode: promoCode?.code, realizationId: promoCode?.promotionCodeRealizationId)
            SegmentAnalyticsEngine.instance.logEvent(event: promoCodeAppliedEvent)
            
            if withAnimation {
                MixpanelEventLogger.trackCheckoutPromoApplied(promoCode: promoCode!)
                self.showPromoError(true, message: "")
                self.animateSuccessForPromo()
            }else {
                MixpanelEventLogger.trackCheckoutVoucherApplied(code: promoCode?.code ?? "", id: String(promoCode?.id ?? -1))
                SpinnerView.hideSpinnerView()
                self.tblView.reloadDataOnMain()
            }
            
            ElGrocerUtility.sharedInstance.delay(0.2) {
                self.btnCloseHandler("")
            }
        }
    }
}
extension ApplyPromoVC {
        //promo code apply functions
    func showPromoError(_ isHidden : Bool , message : String,color: UIColor = .textfieldErrorColor()) {
        if isHidden{
            self.lblPromoError.visibility = .gone
            self.promoBGViewHeightConstraint.constant = 55
        }else{
            
            let height = ElGrocerUtility.sharedInstance.dynamicHeight(text: message, font: UIFont.SFProDisplayNormalFont(12), width: ScreenSize.SCREEN_WIDTH - 50)
            self.lblPromoError.textColor = color
            self.lblPromoError.visibility = .visible
            self.promoBGViewHeightConstraint.constant = 55 + height
            
            self.lblPromoError.text = message
            
            
        }
    }
    func animateSuccessForPromo(){
        self.btnPromoApply.isHidden = true
        self.promoActivityIndicator.stopAnimating()
        self.promoTxtFieldBGView.borderColor = ApplicationTheme.currentTheme.textFieldBorderActiveColor
        self.promoTxtFieldBGView.layer.borderWidth = 1
        self.btnPromoApply.tintColor = ApplicationTheme.currentTheme.buttonTextWithClearBGColor
        self.showPromoError(false, message: localizedString("txt_enjoy_promo", comment: ""),color: ApplicationTheme.currentTheme.labelPrimaryBaseTextColor)
        self.btnPromoRemove.isHidden = false
            //        self.btnPromoApply.setTitle("", for: UIControl.State())
            //        self.btnPromoApply.setImage(UIImage(named: "MyBasketPromoSuccess"), for: .normal)
    }
    
    func animateFailureForPromo(){
        self.btnPromoApply.isHidden = false
        self.promoActivityIndicator.stopAnimating()
        self.promoTxtFieldBGView.borderColor = UIColor.textfieldErrorColor()
        self.promoTxtFieldBGView.layer.borderWidth = 1
    }
}
extension ApplyPromoVC: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFirstTime {
            return 0
        }
        guard promoCodeArray.count > 0 else {
            return 1
        }
        return promoCodeArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        guard promoCodeArray.count > 0 else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoPromoTableViewCell", for: indexPath) as! NoPromoTableViewCell
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ApplyPromoCell", for: indexPath) as! ApplyPromoCell
        
            //        let promocodeDefault = UserDefaults.getPromoCodeValue()?.code ?? ""
        if (self.promoCode?.code ?? "") == promoCodeArray[indexPath.row].code {
            self.isDismisingWithPromoApplied = true
            cell.configureCell(promoCode: promoCodeArray[indexPath.row], isExpanded: extensionArray[indexPath.row], isApplied: true, grocery: self.previousGrocery)
            cell.showInfoMessage(isHidden: true, message: "")
            cell.btnRedeem.isHidden = false
        }else {
            cell.configureCell(promoCode: promoCodeArray[indexPath.row], isExpanded: extensionArray[indexPath.row], isApplied: false, grocery: self.previousGrocery)
            
            let infoMessageResult = PromotionCodeHandler.checkIfBrandProductAdded(products: self.priviousFinalizedProductA!, brandDict: promoCodeArray[indexPath.row].brands)
            cell.showInfoMessage(isHidden: !(infoMessageResult.isFound), message: infoMessageResult.brandName)
            
        }
        
        
        cell.isRedeemTapped = {[weak self] (promoCode,isApplied) in
            if isApplied {
                UserDefaults.setPromoCodeValue(nil)
                UserDefaults.setPromoCodeIsFromText(nil)
                self?.btnPromoRemoveHandler(self)
                
                // Logging segment event for promo code applied
                let promoCodeAppliedEvent = PromoCodeAppliedEvent(isApplied: false, promoCode: promoCode.code, realizationId: promoCode.promotionCodeRealizationId)
                SegmentAnalyticsEngine.instance.logEvent(event: promoCodeAppliedEvent)
                
                return
            }
            self?.checkPromoCodeRealisation(promoCode.code, self?.priviousOrderId, withAnimation: false)
            FireBaseEventsLogger.ApplyPromoClick(index: indexPath.row + 1, code: promoCode.code)
        }
        cell.isShowDetailsTapped = {[weak self] (isShowDetailsPressed) in
            if isShowDetailsPressed {
                self?.extensionArray[indexPath.row] = true
                self?.tblView.reloadDataOnMain()
            }else {
                self?.extensionArray[indexPath.row] = false
                self?.tblView.reloadDataOnMain()
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if let cell = cell as? ApplyPromoCell {
            DispatchQueue.main.async { [weak cell] in
                cell?.setBorderForPromo()
            }
        }
        
        // Logging segment event for Promo Code Viewed
        if indexPath.row < self.promoCodeArray.count {
            if !self.promoCodeArray[indexPath.row].isViewed {
                SegmentAnalyticsEngine.instance.logEvent(event: PromoCodeViewedEvent(promoCode: self.promoCodeArray[indexPath.row]))
                self.promoCodeArray[indexPath.row].isViewed = true
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        titleHeaderView.configureView(title: localizedString("title_available_promo", comment: ""))
        return titleHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
}
extension ApplyPromoVC: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let kLoadingDistance = 2 * kProductCellHeight + 8
        let y = scrollView.contentOffset.y + scrollView.bounds.size.height - scrollView.contentInset.bottom
        if y + kLoadingDistance > scrollView.contentSize.height && self.isGettingPromo == false {
            debugPrint("getlist")
            self.getPromoCodeList()
        }
    }
}
