//
//  OrderConfirmationViewController.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 13.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit
import MessageUI
import FirebaseAnalytics
import FirebaseCrashlytics
import FBSDKCoreKit

import Lottie
import RxSwift

class OrderConfirmationViewController : UIViewController, MFMailComposeViewControllerDelegate , MyBasketViewProtocol {
    
    private var viewModel: OrderConfirmationViewModelType!
    private var analyticsEventLogger: AnalyticsEngineType!
    private var disposeBag = DisposeBag()
    
    @IBOutlet weak var bgView: UIView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var scrollContentSize: NSLayoutConstraint!
    @IBOutlet var lottieAnimation: UIView!
    @IBOutlet weak var lblNewOrderSuccessMsg: UILabel! {
        didSet {
            lblNewOrderSuccessMsg.setH4SemiBoldStyle()
            lblNewOrderSuccessMsg.text =  localizedString("lbl_Hurray_Success_Msg", comment: "")
            lblNewOrderSuccessMsg.textColor = ApplicationTheme.currentTheme.labelSecondaryBaseColor
            
        }
    }
    @IBOutlet weak var groceryImage: UIImageView!
    @IBOutlet weak var lblGroceryName: UILabel!
    @IBOutlet weak var lblOrderNumber: UILabel!
    
    @IBOutlet weak var lblOrderDetail: UILabel! {
        didSet {
            lblOrderDetail.text =  localizedString("lbl_Order_Details", comment: "")
        }
    }
    @IBOutlet weak var lblOrderDetailArrow: UIImageView!
    @IBOutlet weak var lblOrderDetailNote: UILabel!
    @IBOutlet weak var lblFreshItemNote: UILabel!
    @IBOutlet weak var lblAddressNote: UILabel!
    @IBOutlet weak var viewBanner: BannerView! {
        didSet{
            viewBanner.layer.cornerRadius = 5
        }
    }
    
    // status view
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var lblEstimatedDelivery: UILabel! {
        didSet {
            lblEstimatedDelivery.text = localizedString("title_estimated_delivery", comment: "")
        }
    }
    @IBOutlet weak var lblDeliveryTime: UILabel!
    @IBOutlet weak var orderProgressView: UIProgressView!
    @IBOutlet weak var lblOrderStatus: UILabel!
    @IBOutlet weak var btnOrderStatusUserAction: AWButton!
    
    // PickerDetailView
    @IBOutlet weak var pickerDetailView: UIView!
    @IBOutlet weak var pickerImage: UIImageView!
    @IBOutlet weak var lblPickerDetail: UILabel!
    
    @IBOutlet weak var pickerChatImageView: UIImageView!
    @IBOutlet weak var lblPickerChat: UILabel!
    
    // constraints
    @IBOutlet weak var orderDetailTopContraint: NSLayoutConstraint!
    @IBOutlet weak var orderDetailHeightContstraint: NSLayoutConstraint!
    @IBOutlet weak var addressDetailTopWithOrderDetailBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var orderStatusViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var addressDetailTopWithOrderStatusBottomConstraint: NSLayoutConstraint!
    
    static func make(viewModel: OrderConfirmationViewModelType, analyticsEventLogger: AnalyticsEngineType = SegmentAnalyticsEngine()) -> OrderConfirmationViewController {
        let vc = ElGrocerViewControllers.orderConfirmationViewController()
        vc.viewModel = viewModel
        vc.analyticsEventLogger = analyticsEventLogger
        return vc
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.title =  localizedString("order_status", comment: "")
        self.navigationItem.hidesBackButton = true
        self.tableview?.isHidden = true
        self.bgView?.isHidden = true
        self.bindViews()
        self.setNavigationAppearance()
        self.checkForPushNotificationRegisteration()
        // Logging segment event for segment order confirmation screen
        SegmentAnalyticsEngine.instance.logEvent(event: ScreenRecordEvent(screenName: .orderConfirmationScreen))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.setNavigationAppearance()
        /*
        if isNeedToDoViewAllocation {
            
            (self.navigationController as? ElGrocerNavigationController)?.setWhiteBackgroundColor()
            (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
            (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(false)
                // cross is used against backbutton
            (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
            if let nav = (self.navigationController as? ElGrocerNavigationController) {
                if let bar = nav.navigationBar as? ElGrocerNavigationBar {
                    bar.chatButton.chatClick = {
                        Thread.OnMainThread {
                            guard self.order.grocery != nil else {return }
                            let groceryID = self.order.grocery.getCleanGroceryID()
                            let sendBirdDeskManager = SendBirdDeskManager(controller: self, orderId: self.order.dbID.stringValue, type: .orderSupport, groceryID)
                            sendBirdDeskManager.setUpSenBirdDeskWithCurrentUser()
                        }
                    }
                }
            }
            addBackButtonWithCrossIconLeftSide()
            self.addStatusHeader()
//            self.isNeedToDoViewAllocation = false
            
        }
   
        self.getOrderDetail()
        */
        
        //Todo: this should be removed; all data handling should be from view model.
        self.getOrderDetail()
    }
    
    private func setNavigationAppearance() {
        
        (self.navigationController as? ElGrocerNavigationController)?.setLogoHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setSearchBarHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setChatButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.setGreenBackgroundColor()
        (self.navigationController as? ElGrocerNavigationController)?.setBackButtonHidden(true)
        (self.navigationController as? ElGrocerNavigationController)?.addRightCrossButton(false, false)
        
        if let nav = (self.navigationController as? ElGrocerNavigationController) {
            if let bar = nav.navigationBar as? ElGrocerNavigationBar {
                bar.chatButton.chatClick = {
                    Thread.OnMainThread {
                        guard self.order.grocery != nil else {return }
                        let groceryID = self.order.grocery.getCleanGroceryID()
                        let sendBirdDeskManager = SendBirdDeskManager(controller: self, orderId: self.viewModel.orderIdForPublicUse, type: .orderSupport, groceryID)
                        sendBirdDeskManager.setUpSenBirdDeskWithCurrentUser()
                    }
                }
            }
        }
        
    }
    private func bindViews() {
        
       //
        
        self.viewModel.outputs.error.subscribe(onNext: { [weak self] loading in
            guard let self = self else { return }
            self.backButtonClick()
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.loading.subscribe(onNext: { [weak self] loading in
            guard let self = self else { return }
            loading
            ? _ = SpinnerView.showSpinnerViewInView(self.view)
            : SpinnerView.hideSpinnerView()
            self.bgView.isHidden = loading
            
        }).disposed(by: disposeBag)
        self.viewModel.outputs.isNewOrder.subscribe(onNext: { [weak self] isNeedOrder in
            guard let self = self else { return }
            if isNeedOrder {
                LottieAniamtionViewUtil.showAnimation(onView:  self.lottieAnimation, withJsonFileName: "OrderConfirmationSmiles", removeFromSuper: false, loopMode: .playOnce) { isloaded in }
                self.orderDetailTopContraint.priority = UILayoutPriority.init(990)
                self.addressDetailTopWithOrderDetailBottomConstraint.priority = UILayoutPriority.init(1000)
                self.addressDetailTopWithOrderStatusBottomConstraint.priority = UILayoutPriority.init(100)
                
            } else {
                self.orderDetailTopContraint.priority = UILayoutPriority.init(1000)
            }
            self.statusView.isHidden = isNeedOrder
            
            DispatchQueue.main.async {
                self.view.layoutIfNeeded()
                self.view.setNeedsLayout()
            }
            
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.groceryName
            .bind(to: self.lblGroceryName.rx.text)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.orderNumber.subscribe(onNext: { orderNumber in
            self.lblOrderNumber.text = localizedString("order_number_label", comment: "") + orderNumber
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.groceryUrl.subscribe { [weak self] url in
            self?.groceryImage.sd_setImage(with: url, placeholderImage: UIImage(name: ""), context: nil)
        }.disposed(by: disposeBag)
        
        self.lblOrderDetailNote.attributedText = setBoldForText(CompleteValue: localizedString("Msg_Edit_Order", comment: ""), textForAttribute: localizedString("lbl_Order_Details", comment: ""))
        
        self.lblFreshItemNote.attributedText = setBoldForText(CompleteValue: localizedString("order_note_label_complete", comment: ""), textForAttribute: localizedString("order_Note_Bold_Price_May_Vary", comment: ""))
        
        self.viewModel.outputs.address
            .bind(to: self.lblAddressNote.rx.text)
            .disposed(by: disposeBag)
        
        
        self.viewModel.outputs.orderDeliveryDateString
            .bind(to: self.lblDeliveryTime.rx.attributedText)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.orderProgressValue
            .bind(to: self.orderProgressView.rx.progress)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.orderStatusString
            .bind(to: self.lblOrderStatus.rx.text)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.picketName
            .bind(to: self.lblPickerDetail.rx.text)
            .disposed(by: disposeBag)
        
        self.viewModel.outputs.picketName.subscribe { [weak self] pickerName in
            
            var picker : String = pickerName
            picker = picker.replacingOccurrences(of: "\n" + localizedString("txt_Picker", comment: ""), with: "")
            self?.pickerDetailView.isHidden = picker.count == 0
        }.disposed(by: disposeBag)
        
        
        self.viewModel.outputs.banners.subscribe(onNext: { [weak self] banners in
            guard let self = self else { return }
            self.viewBanner.bannerType = .post_checkout
            if let banners = banners {
                self.viewBanner.banners = banners
            }
            self.viewBanner.isHidden = banners == nil || banners?.count ?? 0 == 0
            if !self.viewBanner.isHidden {
                
            }
        }).disposed(by: disposeBag)
        
        self.viewModel.outputs.orderStatus.subscribe(onNext: {  [weak self] status in
            guard let self = self else { return }
            self.orderStatusViewHeightConstraint.constant = 110
            if status == OrderStatus.inSubtitution {
                self.orderStatusViewHeightConstraint.constant = 180
                self.orderProgressView.progressTintColor = ApplicationTheme.currentTheme.promotionYellowColor
                self.lblOrderStatus.textColor = ApplicationTheme.currentTheme.promotionYellowColor
            }else if status == OrderStatus.canceled {
                self.orderStatusViewHeightConstraint.constant = 180
                self.orderProgressView.progressTintColor = ApplicationTheme.currentTheme.redInfoColor
                self.lblOrderStatus.textColor = ApplicationTheme.currentTheme.redInfoColor
            }else if status != .enRoute {
                self.addressDetailTopWithOrderStatusBottomConstraint.priority = UILayoutPriority.init(1000.0)
            }
            if self.pickerDetailView.isHidden == false {
                self.addressDetailTopWithOrderStatusBottomConstraint.priority = UILayoutPriority.init(600.0)
                self.scrollContentSize.constant = 880
            }else {
                self.scrollContentSize.constant = 730
            }
            
            DispatchQueue.main.async {
                self.view.layoutIfNeeded()
                self.view.setNeedsLayout()
            }
        }).disposed(by: disposeBag)
        
        self.viewBanner.bannerTapped = { [weak self] banner in
        
            guard let self = self, let campaignType = banner.campaignType, let bannerDTODictionary = banner.dictionary as? NSDictionary else { return }
            
            let bannerCampaign = BannerCampaign.createBannerFromDictionary(bannerDTODictionary)
            
            switch campaignType {
            case .brand:
                bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: sdkManager.isGrocerySingleStore ? [ElGrocerUtility.sharedInstance.activeGrocery!] : (HomePageData.shared.groceryA ?? [ElGrocerUtility.sharedInstance.activeGrocery!]))
                break
                
            case .retailer:
                bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: sdkManager.isGrocerySingleStore ? [ElGrocerUtility.sharedInstance.activeGrocery!] : (HomePageData.shared.groceryA ?? [ElGrocerUtility.sharedInstance.activeGrocery!]))
                break
                
            case .web:
                ElGrocerUtility.sharedInstance.showWebUrl(banner.url ?? "", controller: self)
                break
                
            case .priority:
                bannerCampaign.changeStoreForBanners(currentActive: nil, retailers: sdkManager.isGrocerySingleStore ? [ElGrocerUtility.sharedInstance.activeGrocery!] : (HomePageData.shared.groceryA ?? [ElGrocerUtility.sharedInstance.activeGrocery!]))
                break
            }
           
        }
        
        self.viewModel.outputs.isArbic.subscribe (onNext: { [weak self] isArbic in
            self?.lblOrderDetailArrow.transform = isArbic ? CGAffineTransform(scaleX: -1, y: 1) : CGAffineTransform(scaleX: 1, y: 1)
            //self?.view.semanticContentAttribute = isArbic ? .forceRightToLeft : .forceLeftToRight
        }).disposed(by: disposeBag)
        
        // lblOrderDetailArrow
        
        /*
         
         if let slotString = order?.getDeliveryTimeAttributedString() {
             self.lblSelfCollection.attributedText = slotString
         }else{
             self.lblSelfCollection.text = ""
         }
         
         */
        
     
        
        //localizedString("order_number_label", comment: "") + self.order.dbID.stringValue
        
        
//        self.viewModel.outputs.groceryName.subscribe(onNext: { string in
//            self.lblGroceryName.text = string
//        }).disposed(by: disposeBag)
            
        
        /*
        //self.lblBanners.visibility = .gone
       // self.lottieAnimation.visibility = .gone
        self.viewBanner.roundCorners(corners: [.topLeft, .topRight, .bottomLeft, .bottomRight], radius: 8)
        self.lblGroceryName.text = self.order.grocery.name
        self.lblOrderNumber.text = localizedString("order_number_label", comment: "") + self.order.dbID.stringValue
       
        let addressString = ElGrocerUtility.sharedInstance.getFormattedAddress(order.deliveryAddress) + order.deliveryAddress.address
        self.lblAddressNote.text = addressString
        
        if let imageUrlString = self.grocery.imageUrl, let url = URL.init(string: imageUrlString) {
            self.groceryImage.sd_setImage(with: url)
        }
        self.viewBanner.bannerTapped = { [weak self] banner in
        
            guard let self = self, let campaignType = banner.campaignType, let bannerDTODictionary = banner.dictionary as? NSDictionary else { return }
            
            let bannerCampaign = BannerCampaign.createBannerFromDictionary(bannerDTODictionary)
            
            switch campaignType {
            case .brand:
                bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: [ElGrocerUtility.sharedInstance.activeGrocery!])
                break
                
            case .retailer:
                bannerCampaign.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: [ElGrocerUtility.sharedInstance.activeGrocery!])
                break
                
            case .web:
                ElGrocerUtility.sharedInstance.showWebUrl(banner.url ?? "", controller: self)
                break
                
            case .priority:
                bannerCampaign.changeStoreForBanners(currentActive: nil, retailers: [ElGrocerUtility.sharedInstance.activeGrocery!])
                break
            }
           
        }
        LottieAniamtionViewUtil.showAnimation(onView:  self.lottieAnimation, withJsonFileName: "OrderConfirmationSmiles", removeFromSuper: false, loopMode: .playOnce) { isloaded in }*/
     
    }
    @IBAction func orderDetailButtonAction(_ sender: Any) {
        self.goToOrderDetailAction("")
    }
    @IBAction func orderStatusUserAction(_ sender: Any) {
        let substitutionsProductsVC = ElGrocerViewControllers.substitutionsProductsViewController()
        let orderId = self.viewModel.orderIdForPublicUse
        substitutionsProductsVC.orderId = orderId
        ElGrocerUtility.sharedInstance.isNavigationForSubstitution = true
        self.navigationController?.pushViewController(substitutionsProductsVC, animated: true)
    }
    @IBAction func pickerChatAction(_ sender: Any) {
        guard (self.order.picker?.dbID.stringValue.count ?? 0) > 0 else {return}
        Thread.OnMainThread { [weak self] in
            self?.callSendBirdChat(pickerID: self?.order.picker?.dbID.stringValue ?? "")
        }
       
    }
    
    
    
    //Warning:-
    // Following needs to remove once other dependency remove all other UI part will be removed in future
    // Please dont use following properties in near future update (addComent data: 13feb 2023)
    
    var shouldScroll : Bool = false
    var isNeedToDoViewAllocation : Bool = true
    var orderType : OrderType = .CandC
    var statusType : OrderStatus = .delivered
    var currentHeaderHeight = orderStatusHeaderMinHeight
    lazy var statusHeaderView : orderStatusHeaderView = {
        let nib = orderStatusHeaderView.loadFromNib()
        return nib!
    }()
    @IBOutlet var topHeaderView: UIView!
    @IBOutlet var tableview: UITableView!
    var order:Order!
    var orderDict:NSDictionary?
    var grocery:Grocery!
    var isNeedToRemoveActiveBasket : Bool = true
    var orderProducts:[Product]!
    var orderItems:[ShoppingBasketItem]!
    var isSummaryForGroceryBasket:Bool = false
    @IBOutlet var lblChatWithElgrocer: UILabel!
    
    @IBOutlet var backImage: UIImageView!
    
    // data for events
    var finalOrderItems:[ShoppingBasketItem] = []
    var finalProducts:[Product]!
    var availableProductsPrices:NSDictionary?
    var deliveryAddress:DeliveryAddress!
    var priceSum = 0.00
    var bannersList : [BannerCampaign] = []
    
    private func getCurrentDeliveryAddress() -> DeliveryAddress? {
        return DeliveryAddress.getActiveDeliveryAddress(DatabaseHelper.sharedInstance.mainManagedObjectContext)
    }
    
    @IBOutlet weak var titleLabel: UILabel!
   // @IBOutlet weak var itemsLabel: UILabel!
    @IBOutlet weak var orderNumberLabel: UILabel!
  //  @IBOutlet weak var totalPriceLabel: UILabel!
    
    @IBOutlet weak var trackOrderBtn: UIButton!
    //@IBOutlet weak var orderScheduleDetailbtn: UIButton!
    @IBOutlet weak var needAssistanceLable: UILabel!
    @IBOutlet weak var noteOrderLable: UILabel!
    @IBOutlet var editOrderStatus: UILabel!
    
    @IBOutlet weak var asistanceLable: UILabel!
    @IBOutlet weak var orderStatus: UILabel!
    @IBOutlet var lblOrderStatusAccepted: UILabel! {
        didSet{
            lblOrderStatusAccepted.text = localizedString("order_status_accepted", comment: "")
            lblOrderStatusAccepted.setCaptionTwoRegDarkStyle()
        }
        
    }
    @IBOutlet var lblOrderStatusOnTheWay: UILabel! {
        didSet{
            lblOrderStatusOnTheWay.text = localizedString("btn_on_my_way_txt", comment: "")
            lblOrderStatusOnTheWay.setCaptionTwoRegDarkStyle()
        }
        
    }
    @IBOutlet var orderStatusDelievered: UILabel! {
        didSet{
            orderStatusDelievered.text = localizedString("order_status_delivered", comment: "")
            orderStatusDelievered.setCaptionTwoRegDarkStyle()
        }
        
    }
    @IBOutlet var deliveryCheckOutView: UIView!
    @IBOutlet var cncCheckOutView: UIView!
    var tableBottom : NSLayoutConstraint?
    var smileSection: Int = 0
    
    func setup() {
        
        // Fixit: need to remove
        setUpTitleLabelAppearance()
        setUpDelevryScheduleDetail()
        setNoteOrderLable()
        setNeedAssistanceLable()
        setUpOrderNumberAppearance()
        setUpItemsLabelAppearance()
        setUpTotalAmountAppearance()
        setUpTrackOrderButtonAppearance()
        if isNeedToRemoveActiveBasket { resetLocalDBData()  }
        setOrderStatusLable()
        setRetailerImage()
        setOrderDetailImageForLanguage()
        setSmilePointSectionValue()
        
       
    }
    
    fileprivate func playLottieAnimation() {
        
       
    }
    
    
    
    func cellRegistration() {
        let orderCollectionDetailsCell = UINib(nibName: "OrderCollectionDetailsCell", bundle: Bundle.resource)
        self.tableview.register(orderCollectionDetailsCell, forCellReuseIdentifier: "OrderCollectionDetailsCell")
        
        let genericViewTitileTableViewCell = UINib(nibName: KGenericViewTitileTableViewCell, bundle: Bundle.resource)
        self.tableview.register(genericViewTitileTableViewCell, forCellReuseIdentifier: KGenericViewTitileTableViewCell)
        
        let warningCell = UINib(nibName: "warningAlertCell" , bundle: Bundle.resource)
        self.tableview.register(warningCell, forCellReuseIdentifier: "warningAlertCell")
        
        let OrderStatusDetailCell = UINib(nibName: "OrderStatusDetailCell" , bundle: Bundle.resource)
        self.tableview.register(OrderStatusDetailCell, forCellReuseIdentifier: "OrderStatusDetailCell")
        
        let CandCLocationCell = UINib(nibName: "CandCLocationCell" , bundle: Bundle.resource)
        self.tableview.register(CandCLocationCell, forCellReuseIdentifier: "CandCLocationCell")
        
        
        let genericBannersCell = UINib(nibName: KGenericBannersCell, bundle: Bundle.resource)
        self.tableview.register(genericBannersCell, forCellReuseIdentifier: KGenericBannersCell)
        
        let spaceTableViewCell = UINib(nibName: "SpaceTableViewCell", bundle: Bundle.resource)
        self.tableview.register(spaceTableViewCell, forCellReuseIdentifier: "SpaceTableViewCell")
        
        let shareCell = UINib(nibName: "shareCollectionDetailCell" , bundle: Bundle.resource)
        self.tableview.register(shareCell, forCellReuseIdentifier: "shareCollectionDetailCell")
        
        let smilePointTableCell = UINib(nibName: "smilePointTableCell", bundle: .resource)
        self.tableview.register(smilePointTableCell, forCellReuseIdentifier: "smilePointTableCell")
        
        tableBottom = self.tableview.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant:0)
        tableBottom?.isActive = true
    }
    
    func callSendBirdChat(pickerID : String){
        SendBirdManager().callSendBirdChat(pickerID: pickerID, orderId: self.order.dbID.stringValue, controller: self )
        
        
        let orderStatus = self.order.getOrderDynamicStatus()
        let status = orderStatus.getStatusKeyLogic()
        ElGrocerEventsLogger.sharedInstance.chatWithPickerClicked(orderId: self.order.dbID.stringValue, pickerID: pickerID , orderStatusID: status.status_id.stringValue)

    }
    
    func addStatusHeader () {
        
         return
        
        guard self.order != nil else {return}
        
        let data = order.getOrderDynamicStatus()
        //let dataStatus =  data.getStatusKeyLogic()
        guard self.order != nil else {return}
        statusHeaderView.chooseReplacmentAction = { [weak self] (isChooseReplacment) in
            self?.goForSubsiutionProcess()
        }
        let status = data.getMappingTypeWithOrderStatus()
        if status == .inSubtitution {
            currentHeaderHeight = orderStatusHeaderHeight
        }
        
        statusHeaderView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: currentHeaderHeight)
        if currentHeaderHeight == orderStatusHeaderMinHeight {
            statusHeaderView.btnOrderStatus.visibility = .goneY
        }
        statusHeaderView.clipsToBounds = true
        statusHeaderView.translatesAutoresizingMaskIntoConstraints = true
        self.view.addSubview(statusHeaderView)
        self.view.bringSubviewToFront(self.statusHeaderView)
                  
        self.statusHeaderView.loadOrderStatusLabel(status: self.order.getOrderDynamicStatus() , orderType: self.order.getOrderType(), self.order.getSlotFormattedString() , self.order.trackingUrl ?? "", orderId: self.order.dbID.stringValue)
        self.tableview.contentInset = UIEdgeInsets(top: currentHeaderHeight + 20, left: 0, bottom: 0, right: 0)
        
    }
    
    func setStatusProgress() {
        if self.order == nil {return}
        if ElGrocerUtility.sharedInstance.appConfigData == nil {return}
       let status =  self.order.getOrderDynamicStatus()
        statusHeaderView.setProgressAccordingToStatus(status, totalStep: ElGrocerUtility.sharedInstance.appConfigData.orderTotalSteps.intValue)
    }
    
    
    func updateTableViewBottom(_ value : CGFloat) {
        tableBottom?.constant = value
        DispatchQueue.main.async {
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
    }
    
   
    @IBOutlet var btnContinueShoppinglable: UILabel! {
        didSet{
            btnContinueShoppinglable.text = localizedString("lbl_Contnue_shopping", comment: "")
            btnContinueShoppinglable.setH4SemiBoldWhiteStyle()
        }
    }
    
    @IBOutlet var btnOrderDetail: UIButton!{
        didSet{
            btnOrderDetail.setTitle(localizedString("lbl_Order_Details", comment: ""), for: .normal)
        }
        
    }
    @IBOutlet var statusViewHeight: NSLayoutConstraint!
    

    
    @IBOutlet weak var imgViewRetailer: UIImageView!
    @IBOutlet weak var lblGrocerName: UILabel!
    
    @IBOutlet var lbl_CurrentStatusMsg: UILabel! {
        didSet{
            lbl_CurrentStatusMsg.setH3SemiBoldStyle()
            lbl_CurrentStatusMsg.text = localizedString("dialog_CandC_Msg", comment: "")
        }
    }
    @IBOutlet var btnAtTheStore: UIButton! {
        didSet{
            btnAtTheStore.setH4SemiBoldWhiteStyle()
            btnAtTheStore.setTitle(localizedString("btn_at_the_store_txt", comment: ""), for: UIControl.State())
            
        }
    }
    @IBOutlet var btnOnMyWay: UIButton! {
        didSet{
            btnOnMyWay.setH4SemiBoldWhiteStyle()
            btnOnMyWay.setTitle(localizedString("btn_on_my_way_txt", comment: ""), for: UIControl.State())
        }
    }
    
    
    
    /*@IBOutlet weak var inviteTitleLabel: UILabel!
    @IBOutlet weak var inviteDescriptionLabel: UILabel!
    @IBOutlet weak var referrerAmountLabel: UILabel!
    @IBOutlet weak var inviteFriendsBtn: UIButton!*/
    // MARK: Life cycle
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if #available(iOS 13, *) {
            return self.isDarkMode ? UIStatusBarStyle.lightContent :  UIStatusBarStyle.darkContent
        }else{
            return  UIStatusBarStyle.default
        }
    }
    
    private func setRightBarItem(_ image : UIImage) {
        
        let rightView = UIView.init(frame:  CGRect.init(x: 0, y: 0, width: 40, height: 40))
        rightView.backgroundColor = .clear
        let rightImageView = UIButton.init(frame:  CGRect.init(x: 0, y: 0, width: 40, height: 40))
        rightImageView.setImage(image, for: .normal)
        rightImageView.addTarget(self, action: #selector(editOrderCall), for: .touchUpInside)
        rightView.layer.cornerRadius =  rightView.frame.size.width/2
        rightView.clipsToBounds = true
        rightView.addSubview(rightImageView)
        rightView.backgroundColor = .clear
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(customView: rightView)
        
    }

    
    private func resetLocalDBData() {
        guard self.order != nil else {return}
        ElGrocerUtility.sharedInstance.resetBasketPresistence()
        self.deleteBasketFromServerWithGrocery(self.order.grocery)
    }
    
    @objc
    func editOrderCall () {
        self.orderEditHandler()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self);
    }
    
    
    override func crossButtonClick() {
        backButtonClick()
    }
    
    override func rightBackButtonClicked() {
        backButtonClick()
    }
    
    override func backButtonClick() {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
        
        if let vcA = self.navigationController?.viewControllers {
            elDebugPrint(vcA)
            if vcA.count == 1 {
                //from home
                self.navigationController?.dismiss(animated: true, completion: nil)
            }else if vcA.count == 3 {
                //edit order
                guard sdkManager.isSmileSDK else {
                    self.navigationController?.dismiss(animated: false)
                    return
                }
                let appDelegate = SDKManager.shared
                appDelegate.rootViewController?.dismiss(animated: false, completion: nil)
                (appDelegate.rootViewController as? UINavigationController)?.popToRootViewController(animated: false)
            }else {
                // simple place order
                self.navigationController?.popToRootViewController(animated: false)
            }
        }
        
        let sdkManage = SDKManager.shared
        if let tab = sdkManage.currentTabBar  {
            ElGrocerUtility.sharedInstance.resetTabbar(tab)
            tab.selectedIndex = sdkManager.isGrocerySingleStore ? 1 : 0
        }
    }
    

    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    

   
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.addBackButtonWithCrossIconRightSide(ApplicationTheme.currentTheme.newBlackColor)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.post(name: Notification.Name(rawValue: kOrderUpdateNotificationKey), object: nil)
        UserDefaults.removeBannerView(topControllerName: FireBaseScreenName.PurchaseOrder.rawValue)
        
    }
    
    func updateNavButtonsForCandC() {
        self.addBackButtonWithCrossIconLeftSide()
    }
    
    func setOrderDetailImageForLanguage() {
        if ElGrocerUtility.sharedInstance.isArabicSelected() {
            self.backImage.transform = CGAffineTransform(scaleX: -1, y: 1)
            self.backImage.semanticContentAttribute = UISemanticContentAttribute.forceLeftToRight
        }
    }
    
    func getBanners() {
        let location =  BannerLocation.post_checkout.getType()
        self.viewBanner.bannerType = BannerLocation.post_checkout
        let retailer_ids = sdkManager.isGrocerySingleStore ? [ElGrocerUtility.sharedInstance.activeGrocery?.dbID ?? ""] :  ElGrocerUtility.sharedInstance.groceries.map { $0.dbID }
        
        ElGrocerApi.sharedInstance.getBanners(for: location, retailer_ids: retailer_ids) { result in
            switch result {
            case .success(let data):
                self.viewBanner.banners = data.map{ $0.toBannerDTO() }
            case .failure(_):
                break
            }
        }
        return
        
        
        /*
        ElGrocerApi.sharedInstance.getBannersFor(location: location , retailer_ids: retailer_ids, store_type_ids: nil , retailer_group_ids: nil , category_id: nil , subcategory_id: nil, brand_id: nil, search_input: nil) { (result) in
            switch result {
                case .success(let response):
                    let bannerA = BannerCampaign.getBannersFromResponse(response)
                    self.bannersList = bannerA
                    self.tableview.reloadDataOnMain()
                case.failure(let error):
                    elDebugPrint(error.jsonValue)
                    //error.showErrorAlert()
            }
        }*/
    }
    
    
    @objc func getOrderDetail () {
      
       // let _ = SpinnerView.showSpinnerViewInView(self.view)
        
        var orderID = self.viewModel.orderIdForPublicUse
        if self.order != nil {
            orderID = self.order.dbID.stringValue
        }else if self.orderDict != nil , let orderIdString = self.orderDict?["id"] as? NSNumber {
            orderID = orderIdString.stringValue
        }
        
        OrderStatusMedule().getOrderDetailWithCustomTracking(orderID) { (result) in
            switch result {
                case .success(let response):
                    // elDebugPrint(response)
                    if let orderDict = response["data"] as? NSDictionary {
                        let latestOrderObj = Order.insertOrReplaceOrderFromDictionary(orderDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        self.order = latestOrderObj
                        self.grocery = self.order.grocery
                    }
                    
                    SpinnerView.hideSpinnerView()
                case .failure(let _):
                    self.perform(#selector(self.getOrderDetail), with: nil, afterDelay: 2)
                    
            }
        }
        /*
        ElGrocerApi.sharedInstance.getorderDetails(orderId: self.order.dbID.stringValue ) { (result) in
            switch result {
                case .success(let response):
                   // elDebugPrint(response)
                    if let orderDict = (response["data"] as? NSDictionary)?["order"] as? NSDictionary {
                        let latestOrderObj = Order.insertOrReplaceOrderFromDictionary(orderDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                        self.order = latestOrderObj
                        self.grocery = self.order.grocery
                        self.setRetailerImage()
                        if self.order.isCandCOrder() {
                            self.updateNavButtonsForCandC()
                        }
                        if self.order.isCandCOrder() {
                            if (self.order.status.intValue == OrderStatus.pending.rawValue ||  self.order.status.intValue == OrderStatus.accepted.rawValue ) {
                                self.statusViewHeight.constant = 141
                                self.updateTableViewBottom(-155)
                                self.deliveryCheckOutView.isHidden = true
                                self.cncCheckOutView.isHidden = false
                            }else{
                                self.statusViewHeight.constant = .leastNormalMagnitude
                                self.updateTableViewBottom(-85)
                                self.deliveryCheckOutView.isHidden = false
                                self.cncCheckOutView.isHidden = true
                            }
                            
                        }else{
                            self.statusViewHeight.constant = .leastNormalMagnitude
                            self.deliveryCheckOutView.isHidden = false
                            self.cncCheckOutView.isHidden = true
                            self.updateTableViewBottom(-85)
                        }
                        
                        DispatchQueue.main.async {
                            self.view.layoutIfNeeded()
                            self.view.setNeedsLayout()
                            self.tableview.reloadData()
                        }
                    }
                   
                    SpinnerView.hideSpinnerView()
                case .failure(let _):
                    self.perform(#selector(self.getOrderDetail), with: nil, afterDelay: 2)
                
            }
        }
        */
    }

    // MARK: Appearance
    
    func setUpTitleLabelAppearance() {
        
        self.titleLabel.textColor = UIColor.colorWithHexString(hexString: "4A4A4A")
        self.titleLabel.font = UIFont.SFProDisplaySemiBoldFont(15.0)
        self.titleLabel.text = localizedString("order_confirmation_text", comment: "")
        
        self.lblGrocerName.setBody2SemiboldGreenStyle()
        self.btnContinueShoppinglable.text = localizedString("lbl_Contnue_shopping", comment: "")
    }
    func setUpDelevryScheduleDetail() {
        guard self.order != nil else {return}
        if let slotString = self.order.getDeliveryTimeAttributedString() {
            self.lblDeliveryTime.attributedText = slotString
        }else{
            if order.deliverySlot == nil {
                let prefixText = localizedString("lbl_Arring_Slot", comment: "")
                let timeSlot = localizedString("order_schedule_InstantTime_lable", comment: "")
                let scheduleStr = self.getDeleveryScheduleAttributedString(prefixText: prefixText, SuffixBold: timeSlot  , attachedImage: nil)
                self.lblDeliveryTime.attributedText = scheduleStr
            }else{
                var slotTimeStr = ""
                if let selectedSlot = order.deliverySlot {
                    slotTimeStr = selectedSlot.getSlotFormattedString(isDeliveryMode: order.isDeliveryOrder())
                    if  selectedSlot.isToday() {
                        let name =    localizedString("today_title", comment: "") // + " " + ( selectedSlot.estimatedDeliveryDate!.dataMonthDateInUTCString() ?? "")
                        slotTimeStr = String(format: "%@ (%@)", name ,slotTimeStr)
                    }else if selectedSlot.isTomorrow()  {
                        
                        let name =    localizedString("tomorrow_title", comment: "") // + " " + ( selectedSlot.estimatedDeliveryDate!.dataMonthDateInUTCString() ?? "")
                        slotTimeStr = String(format: "%@ (%@)", name,slotTimeStr)
                    }else{
                        slotTimeStr = String(format: "%@ (%@)", selectedSlot.start_time?.getDayName() ?? "" ,slotTimeStr)
                    }
                }
                let prefixText = localizedString("lbl_Arring_Slot", comment: "")
                let scheduleStr = self.getDeleveryScheduleAttributedString(prefixText: prefixText, SuffixBold: slotTimeStr  , attachedImage: nil)
                self.lblDeliveryTime.attributedText = scheduleStr
            }
            
        }

    }
    func setSmilePointSectionValue () {
        guard self.order != nil else {
            return
        }
        if let orderPayments = order!.orderPayments {
            for payment in orderPayments {
                let amount = payment["amount"] as? NSNumber ?? NSNumber(0)
                let paymentTypeId = payment["payment_type_id"] as? Int
                
                if (paymentTypeId ?? 0) == 4, amount != 0 {
                    self.smileSection = 1
                }
            }
        }
    }
    func setOrderStatusLable() {
        guard self.order != nil else {return}
        var statusPart  : NSMutableAttributedString = NSMutableAttributedString.init(string: "")
        if order.deliverySlot != nil && order.status.intValue == 0{
            let dict2 = [NSAttributedString.Key.foregroundColor: ApplicationTheme.currentTheme.labelPrimaryBaseTextColor ,NSAttributedString.Key.font:UIFont.SFProDisplayNormalFont(11)]
            statusPart = NSMutableAttributedString(string:String(format:"%@",localizedString("order_status_schedule_order", comment: "")), attributes:dict2)
        }else{
            let dict2 = [NSAttributedString.Key.foregroundColor: ApplicationTheme.currentTheme.labelPrimaryBaseTextColor,NSAttributedString.Key.font:UIFont.SFProDisplayNormalFont(11.0)]
           statusPart = NSMutableAttributedString(string:String(format:"%@",localizedString("order_status_pending", comment: "")), attributes:dict2)
        }
        
         self.orderStatus.attributedText = statusPart
 
        
    }
    
    
    
    func setRetailerImage() {
        
     
       
        guard self.order != nil else {return}
        //OrderConfirmationNewChat
        self.lblGrocerName.attributedText =  NSMutableAttributedString().bold(localizedString("lbl_Order_Confirm_Msg", comment: ""), UIFont.SFProDisplaySemiBoldFont(16) , color: ApplicationTheme.currentTheme.labelPrimaryBaseTextColor).bold(self.grocery.name ?? "", UIFont.SFProDisplaySemiBoldFont(16) , color: ApplicationTheme.currentTheme.labelPrimaryBaseTextColor).bold( " " + localizedString("lbl_Order_Confirm_Msg_last", comment: ""), UIFont.SFProDisplaySemiBoldFont(16) , color: ApplicationTheme.currentTheme.labelPrimaryBaseTextColor)
        self.imgViewRetailer.image = UIImage(name: "order_Confirmed")
        
        
    }
    
    
    
    func setBoldForText(CompleteValue : String , textForAttribute: String) -> NSMutableAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: CompleteValue)
        let range: NSRange = attributedString.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        let attrs = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
        attributedString.addAttributes(attrs, range: range)
        return attributedString
    }
    
    
    func setNoteOrderLable() {
        
        
//        "order_Note_lable" = "NOTE : Fresh Fruits & Vegetables, Meat and Seafood items ";
//        "order_Note_Bold_Price_May_Vary" = "prices may vary";
//        "order_Note_reason" = "due to exact weights";
  //    normal( , 11)
        
       
        let stringColor = UIColor.newBlackColor()
        let boldStringColor =   UIColor.newBlackColor() //.colorWithHexString(hexString: "4c4b44")

        self.noteOrderLable.attributedText = setBoldForText(CompleteValue: localizedString("order_note_label_complete", comment: ""), textForAttribute: localizedString("order_Note_Bold_Price_May_Vary", comment: ""))
        //NSMutableAttributedString().normal(localizedString("order_Note_lable", comment: "") , .SFProDisplayNormalFont(12), color: stringColor).bold(localizedString("order_Note_Bold_Price_May_Vary", comment: "") , .SFProDisplaySemiBoldFont(12), color: .newBlackColor()).normal(localizedString("order_Note_reason", comment: "") , .SFProDisplayNormalFont(12), color: stringColor)
        

        
        self.editOrderStatus.attributedText = NSMutableAttributedString().normal(localizedString("edit_Notice_intial", comment: "") , .SFProDisplayNormalFont(12), color: stringColor).bold(localizedString("edit_Notice_Center", comment: "") , .SFProDisplaySemiBoldFont(12), color: .newBlackColor()).normal(localizedString("edit_Notice_last", comment: "") , .SFProDisplayNormalFont(12), color: stringColor)

    }
    func setNeedAssistanceLable () {

        let clickAbleText = localizedString("launch_live_chat_text", comment: "")
        let initialText   = localizedString("need_assistance_lable", comment: "")
        self.needAssistanceLable.text = initialText
        
        self.lblChatWithElgrocer.text = clickAbleText
        
      //  let clickAbleText = localizedString("launch_live_chat_text", comment: "")
        // let finalStr = initialText + clickAbleText
       // self.needAssistanceLable.attributedText = self.getAttributedStringForAssitance(initialText, clickAble: clickAbleText)
    }
    fileprivate func trackPWEvent() {
        
        var priceSum = 0.00
        for product in self.orderProducts {
            
            let item = self.shoppingItemForProduct(product)
            if let notNilItem = item {
                priceSum += product.price.doubleValue * notNilItem.count.doubleValue
            }
        }
        
        let price = NSString(format: "%.2f", priceSum) as String
        // PushWooshTracking.updatePlaceOrderEventWithOrder(self.order, totalPrice: price, currency: kProductCurrencyAEDName, storeId: self.grocery.dbID)
    }

    @IBAction func openIntercomAction(_ sender: Any) {

        ElGrocerUtility.sharedInstance.logEventToFirebaseWithEventName("open_help_from_meun")
        //// Intercom.presentMessageComposer(nil)
         // ZohoChat.showChat(self.order.dbID.stringValue)
        var groceryID = self.order.grocery.getCleanGroceryID()
        let sendBirdManager = SendBirdDeskManager(controller: self, orderId: self.order.dbID.stringValue, type: .orderSupport, groceryID)
        sendBirdManager.setUpSenBirdDeskWithCurrentUser()
        
    }

    func setUpItemsLabelAppearance() {
        guard self.orderItems != nil else {return}
        
        var itemsCount = 0
        for item in self.orderItems {
            
            itemsCount += item.count.intValue
        }
        
        let countLabel = itemsCount == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")
        
       // let itemStr = self.getAttributedString(countLabel, description: "\(itemsCount)")
        //self.itemsLabel.attributedText = itemStr
        
    }
    
    func setUpOrderNumberAppearance() {
        
        guard self.order != nil else {return}
        
        let semiBold = UIFont.SFProDisplaySemiBoldFont(16)
        self.orderNumberLabel.attributedText =  NSMutableAttributedString().normal(localizedString("order_confirmation_number_label", comment: "") + " ", semiBold , color: .disableButtonColor()).bold("\(self.order.dbID.intValue)" , semiBold , color: .newBlackColor())
    }
    
    func setUpTotalAmountAppearance() {
        
        guard self.orderProducts != nil else {return}
        guard self.order != nil else {return}
        var priceSum = 0.00
        for product in self.orderProducts {
            
            let item = self.shoppingItemForProduct(product)
            if let notNilItem = item {
                priceSum += product.price.doubleValue * notNilItem.count.doubleValue
            }
        }
        
        var discountedPrice = 0.0

        if discountedPrice == 0 {
            discountedPrice = priceSum
        }
       
        let serviceFee = self.order.grocery.serviceFee + self.order.grocery.deliveryFee
        if serviceFee > 0 {
            discountedPrice = discountedPrice + serviceFee
        }
    
        let price = NSString(format: "%@ %.2f",CurrencyManager.getCurrentCurrency() , discountedPrice) as String
        
        let priceStr = self.getAttributedString(localizedString("grand_total", comment: ""), description: price)
        
       // self.totalPriceLabel.attributedText = priceStr
    }
    
    // MARK: Actions
    
    @IBAction func atTheStoreHandler(_ sender: UIButton) {
        
        self.setCollectorStatus(self.order, isOnTheWay: false, button: sender)
        
//        let SDKManager = SDKManager.shared
//        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "dialog_car_green") , header: localizedString("dialog_CandC_Title", comment: "") , detail: localizedString("dialog_CandC_Msg", comment: "")  ,localizedString("btn_at_the_store_txt", comment: "") ,localizedString("btn_on_my_way_txt", comment: "") , withView: SDKManager.window! , true) { (buttonIndex) in
//            if buttonIndex == 0 {
//                self.setCollectorStatus(self.order, isOnTheWay: false , button: sender)
//            }
//            if buttonIndex == 1 {
//
//            }
//        }
    }
    
    @IBAction func onMyWayHandler(_ sender: UIButton) {
        
        self.setCollectorStatus(self.order, isOnTheWay: true , button: sender)
        
//        let SDKManager = SDKManager.shared
//        let _ = NotificationPopup.showNotificationPopupWithImage(image: UIImage(name: "dialog_car_green") , header: localizedString("dialog_CandC_Title", comment: "") , detail: localizedString("dialog_CandC_Msg", comment: "")  ,localizedString("btn_at_the_store_txt", comment: "") ,localizedString("btn_on_my_way_txt", comment: "") , withView: SDKManager.window! , true) { (buttonIndex) in
//            if buttonIndex == 0 {
//
//            }
//            if buttonIndex == 1 {
//                self.setCollectorStatus(self.order, isOnTheWay: true, button: sender)
//            }
//        }
        
        
    }
    
    // MARK: Helpers
    
    fileprivate func shoppingItemForProduct(_ product:Product) -> ShoppingBasketItem? {
        
        for item in self.orderItems {
            
            if product.dbID == item.productId {
                
                return item
            }
        }
        
        return nil
    }
    
    fileprivate func getAttributedString(_ title:String, description:String) -> NSMutableAttributedString {
        
        let dict1 = [NSAttributedString.Key.foregroundColor: UIColor.disableButtonColor(),NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(16)]
        
        let dict2 = [NSAttributedString.Key.foregroundColor: UIColor.newBlackColor(),NSAttributedString.Key.font:UIFont.SFProDisplaySemiBoldFont(16.0)]
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4.0

        
        let titlePart = NSMutableAttributedString(string:String(format:"%@\n",title), attributes:dict1)
        titlePart.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, titlePart.length))
        
        let descriptionPart = NSMutableAttributedString(string:description, attributes:dict2)
        
        let attttributedText = NSMutableAttributedString()
        
        attttributedText.append(titlePart)
        attttributedText.append(descriptionPart)
        
        return attttributedText
    }

    fileprivate func getAttributedStringForAssitance(_ initail:String, clickAble:String) -> NSMutableAttributedString {

        let dict1 = [NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString(hexString: "9B9B9B"),NSAttributedString.Key.font:UIFont.SFProDisplayNormalFont(11.0)]

        let dict2 = [NSAttributedString.Key.foregroundColor: UIColor.colorWithHexString(hexString: "429D39 "),NSAttributedString.Key.font:UIFont.SFProDisplayBoldFont(11.0)]


        let titlePart = NSMutableAttributedString(string:String(format:"%@",initail), attributes:dict1)
        let descriptionPart = NSMutableAttributedString(string:clickAble, attributes:dict2)

        let attttributedText = NSMutableAttributedString()
        attttributedText.append(titlePart)
        attttributedText.append(NSAttributedString(string: " "))// adding  space
        attttributedText.append(descriptionPart)
        attttributedText.append(NSAttributedString(string: " "))// adding  space
        let semiBold = UIFont.SFProDisplaySemiBoldFont(10.0)
        if let image = UIImage(name: "liveChat-Order") {
            let image1Attachment = NSTextAttachment()
            var y = -(semiBold.ascender-semiBold.capHeight/2-image.size.height/2)
            y = -1.0
            image1Attachment.bounds = CGRect(x: 0, y: y, width: image.size.width, height: image.size.height).integral
            image1Attachment.image = image
            attttributedText.append(NSAttributedString(attachment: image1Attachment))
        }

        return attttributedText
    }

    fileprivate func getDeleveryScheduleAttributedString( prefixText:String, SuffixBold:String , attachedImage : UIImage?) -> NSMutableAttributedString {

        let semiBold = UIFont.SFProDisplayNormalFont(14)
        let extraBold = UIFont.SFProDisplaySemiBoldFont(14)
        let dict1 = [NSAttributedString.Key.foregroundColor: UIColor.newBlackColor() , NSAttributedString.Key.font: semiBold]
        let dict2 = [NSAttributedString.Key.foregroundColor: UIColor.newBlackColor() , NSAttributedString.Key.font:extraBold]
        let attttributedText = NSMutableAttributedString()
        if let image = attachedImage {
            let image1Attachment = NSTextAttachment()
            var y = -(semiBold.ascender-semiBold.capHeight/2-image.size.height/2)
            y = -1.5
            image1Attachment.bounds = CGRect(x: 0, y: y, width: image.size.width, height: image.size.height).integral
            image1Attachment.image = image
            let image1String = NSAttributedString(attachment: image1Attachment)
            attttributedText.append(image1String)
            attttributedText.append(NSAttributedString(string: " "))// adding  space
        }
        let prefixPart = NSMutableAttributedString(string:String(format:"%@",prefixText), attributes:dict1)
        let descriptionPart = NSMutableAttributedString(string:SuffixBold , attributes:dict2)
        attttributedText.append(prefixPart)
        attttributedText.append(NSAttributedString(string: " "))// adding  space
        attttributedText.append(descriptionPart)
        return attttributedText
    }


    func setUpTrackOrderButtonAppearance() {
        
     //   self.trackOrderBtn.layer.cornerRadius = 5.0
        self.trackOrderBtn.clipsToBounds = true
        self.trackOrderBtn.setTitle(localizedString("order_confirmation_Edit_order_button", comment: ""), for: UIControl.State())
        
        self.trackOrderBtn.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(17)
        
        self.btnOrderDetail.titleLabel?.font =  .SFProDisplayBoldFont(14)
        self.btnOrderDetail.titleLabel?.textColor = ApplicationTheme.currentTheme.buttonTextWithClearBGColor
       
//
//        let currentLang = LanguageManager.sharedInstance.getSelectedLocale()
//        if currentLang == "ar" {
//            self.trackOrderBtn.imageEdgeInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: -100)
//        }else{
//            self.trackOrderBtn.imageEdgeInsets = UIEdgeInsets(top: 0,left: -100,bottom: 0,right: 0)
//        }
    }
    
    // MARK: Actions
    
    @objc
    func orderEditHandler() {
        
        
        if !self.order.isCandCOrder() {
            
            let currentAddress = getCurrentDeliveryAddress()
            let defaultAddressId = currentAddress?.dbID
            
            let orderAddressId = DeliveryAddress.getAddressIdForDeliveryAddress(self.order.deliveryAddress)
           elDebugPrint("Order Address ID:%@",orderAddressId)
            
            guard defaultAddressId == orderAddressId else {
                ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description: localizedString("edit_Order_change_location_message", comment: ""),positiveButton: localizedString("ok_button_title", comment: ""),negativeButton: nil, buttonClickCallback: nil).show()
                return
            }
        }
        
      
        
        self.createBasketAndNavigateToViewForEditOrder()
 
    }

    
    private func createBasketAndNavigateToViewForEditOrder(){
        
        let spinner = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.ChangeOrderStatustoEdit(order_id: self.order.dbID.stringValue ) { [weak self](result) in
           
            guard let self = self else {return}
            
            if self.order.status.intValue == OrderStatus.inEdit.rawValue {
                self.editOrderSuccess(self.order)
            }else{
                switch result {
                case .success(let data):
                    self.order.status = NSNumber(value: OrderStatus.inEdit.rawValue)
                    self.editOrderSuccess(self.order)
                case .failure(let error):
                    spinner?.removeFromSuperview()
                    error.showErrorAlert()
                }
            }
        }
        
    }
    
    
    
    func editOrderSuccess(_ order : Order) {
        
        func proceedWithOrder(_ proceedOrder : Order) {
            var order = proceedOrder
            func processDataForDeliveryMode() {
                let groceryID = ElGrocerUtility.sharedInstance.cleanGroceryID(order.grocery.dbID)
                ElGrocerApi.sharedInstance.getGroceryDetail(groceryID, lat: "\(order.deliveryAddress.latitude)", lng: "\(order.deliveryAddress.longitude)") { (result) in
                    switch result {
                        case .success(let responseObject):
                            let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                            if  let groceryDict = responseObject["data"] as? NSDictionary {
                                if groceryDict.allKeys.count > 0 {
                                        let grocery =  Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)[0]
                                        order.grocery = grocery
                                        if let finalOrder = Order.getOrderFrom(order.dbID, context: context) {
                                            order = finalOrder
                                        }
                                        ElGrocerUtility.sharedInstance.activeGrocery = order.grocery
                                        ElGrocerUtility.sharedInstance.isDeliveryMode = !order.isCandCOrder()
                                        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                                            self.deleteBasketFromServerWithGrocery(grocery)
                                        }
                                        UserDefaults.setEditOrder(order)
                                        
                                        
                                        let orderProducts = ShoppingBasketItem.getBasketProductsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        let orderItems = ShoppingBasketItem.getBasketItemsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        
                                        for product in orderProducts {
                                            //get shopping item for product (to get count)
                                            let item = self.shoppingItemForProduct(product, orderItems: orderItems)
                                            if let notNilItem = item {
                                                let itemCount = notNilItem.count.intValue
                                                ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: order.grocery, brandName:item?.brandName, quantity: itemCount  , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                            }
                                        }
                                        DatabaseHelper.sharedInstance.saveDatabase()
                                        ElGrocerUtility.sharedInstance.delay(0.5) {
                                            SpinnerView.hideSpinnerView()
                                            self.navigateToBasket(order)
                                        }
                                        
                                    }
                            }
                        case .failure(let error):
                            error.showErrorAlert()
                    }
                }
            }
            func processDataForCandCMode() {
                ElGrocerApi.sharedInstance.getcAndcRetailerDetail(nil, lng: nil , dbID: order.grocery.dbID , parentID: nil) { (result) in
                    switch result {
                        case .success(let responseObject):
                            let context = DatabaseHelper.sharedInstance.mainManagedObjectContext
                            if  let groceryDict = responseObject["data"] as? NSDictionary {
                               // if let groceryDict = response["retailers"] as? [NSDictionary] {
                                    if groceryDict.count > 0 {
                                        let grocery =  Grocery.insertOrReplaceGroceriesFromDictionary(responseObject, context: context)[0]
                                        order.grocery = grocery
                                        if let finalOrder = Order.getOrderFrom(order.dbID, context: context) {
                                            order = finalOrder
                                        }
                                        ElGrocerUtility.sharedInstance.activeGrocery = order.grocery
                                        ElGrocerUtility.sharedInstance.isDeliveryMode = !order.isCandCOrder()
                                        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                                            self.deleteBasketFromServerWithGrocery(grocery)
                                        }
                                        UserDefaults.setEditOrder(order)
                                        
                                        let orderProducts = ShoppingBasketItem.getBasketProductsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        let orderItems = ShoppingBasketItem.getBasketItemsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                        
                                        for product in orderProducts {
                                            //get shopping item for product (to get count)
                                            let item = self.shoppingItemForProduct(product, orderItems: orderItems)
                                            if let notNilItem = item {
                                                let itemCount = notNilItem.count.intValue
                                                ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: order.grocery, brandName:item?.brandName, quantity: itemCount  , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                                            }
                                        }
                                        DatabaseHelper.sharedInstance.saveDatabase()
                                        ElGrocerUtility.sharedInstance.delay(0.5) {
                                            SpinnerView.hideSpinnerView()
                                            self.navigateToBasket(order)
                                        }
                                        
                                    }
                               // }
                            }
                        case .failure(let error):
                            error.showErrorAlert()
                    }
                }
            }
            
            GoogleAnalyticsHelper.trackEditOrderClick(false)
            if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                self.deleteBasketFromServerWithGrocery(grocery)
            }
            ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
            if  order.isCandCOrder() {
                processDataForCandCMode()
            }else{
                processDataForDeliveryMode()
            }
            
        }
        let _  = SpinnerView.showSpinnerViewInView(self.view)
        ElGrocerApi.sharedInstance.getOrdersProductsPossition(order.dbID.stringValue) {  (result) -> Void in
            SpinnerView.hideSpinnerView()
            switch result {
                case .success(let orderDict):
                    let orderGroceryId = Grocery.getGroceryIdForGrocery(order.grocery)
                    Order.addProductToOrder(orderDict: orderDict, groceryId: NSNumber(value: Double(orderGroceryId) ?? -1 ) , order: order , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    DatabaseHelper.sharedInstance.saveDatabase()
                    if let finalOrder = Order.getOrderFrom(order.dbID, context:  DatabaseHelper.sharedInstance.mainManagedObjectContext) {
                        proceedWithOrder(finalOrder)
                    }
                case .failure(let error):
                    error.showErrorAlert()
                    self.backButtonClick()
            }
            
        }
        
    }
    
    private func shoppingItemForProduct(_ product:Product , orderItems : [ShoppingBasketItem]) -> ShoppingBasketItem? {
        
        for item in orderItems {
            
            if product.dbID == item.productId {
                return item
            }
        }
        
        return nil
    }
 
    /*
    func editOrderSuccess(_ data : NSDictionary?) {
        
      
        GoogleAnalyticsHelper.trackEditOrderClick(true)
        
        if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
            self.deleteBasketFromServerWithGrocery(grocery)
        }
        //remove items currently added to grocery basket
        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        var newGrocery : Grocery?
        var isCurrentActive : Bool  = false
        if ElGrocerUtility.sharedInstance.groceries.count > 0{
            
            let orderGroceryId = Grocery.getGroceryIdForGrocery(self.order.grocery)
            
            let index = ElGrocerUtility.sharedInstance.groceries.firstIndex(where: { $0.dbID == orderGroceryId})
            if (index != nil) {
                let grocery = ElGrocerUtility.sharedInstance.groceries[index!]
                
                if (grocery.dbID != ElGrocerUtility.sharedInstance.activeGrocery?.dbID){
                    
                    ElGrocerUtility.sharedInstance.activeGrocery = grocery
                    
                    if let grocery = ElGrocerUtility.sharedInstance.activeGrocery {
                        self.deleteBasketFromServerWithGrocery(grocery)
                    }
                    
                } else {
                    isCurrentActive = true
                }
                
                newGrocery = ElGrocerUtility.sharedInstance.activeGrocery
            }
            
        }
        //add products from order to basket
        for product in self.orderProducts {
            //get shopping item for product (to get count)
            let item = self.shoppingItemForProduct(product)
            if let notNilItem = item {
                let itemCount = notNilItem.count.intValue
                ShoppingBasketItem.addOrUpdateProductInBasket(product, grocery: self.order.grocery, brandName:item?.brandName, quantity: itemCount  , context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            }
        }
        DatabaseHelper.sharedInstance.saveDatabase()
        UserDefaults.setEditOrder(self.order)
       // Analytics.logEvent("Edit_Order", parameters:nil)
        Analytics.setUserProperty(self.order.grocery.name, forName: "store_name")
        FireBaseEventsLogger.trackEditOrder()
        if  newGrocery != nil {
            if !isCurrentActive {
//                ElGrocerUtility.sharedInstance.activeGrocery = newGrocery
//                NotificationCenter.default.post(name: Notification.Name(rawValue: kUpdateGroceryNotificationKey), object: newGrocery)
            }
        }else{
            if !isCurrentActive {
                ElGrocerAlertView.createAlert(localizedString("basket_active_from_other_grocery_title", comment: ""),description: localizedString("reorder_change_location_message", comment: ""),positiveButton: localizedString("ok_button_title", comment: ""),negativeButton: nil, buttonClickCallback: nil).show()
                return
            }
        }
        self.navigateToBasket()
    
        
    }
    */
    
    func navigateToBasket(_ order : Order) {

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
        }
        
        
        let basketController = ElGrocerViewControllers.myBasketViewController()
        basketController.isFromOrderbanner = false
        basketController.isNeedToHideBackButton = true
        basketController.order = order
        basketController.showShoppingBasket(delegate: self, shouldShowGroceryActiveBasket: true, selectedGroceryForItems: nil, notAvailableProducts: nil, availableProductsPrices: nil)
        basketController.edgesForExtendedLayout = UIRectEdge.init(rawValue: 0)
        basketController.hidesBottomBarWhenPushed = true
        DispatchQueue.main.async {
            SpinnerView.hideSpinnerView()
            self.navigationController?.pushViewController(basketController, animated: true)
        }
    }
    
    
    func shoppingBasketViewCheckOutTapped(_ isGroceryBasket:Bool, grocery: Grocery?, notAvailableItems:[Int]?, availableProductsPrices:NSDictionary?) {
        
        elDebugPrint("")
    }
    
    @IBAction func editOrderHandler(_ sender: AnyObject) {
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: kProductUpdateNotificationKey), object: nil)
           self.editOrderCall()
    }
    
    @IBAction func continueShoppingAction(_ sender: Any) {
        
        self.tabBarController?.selectedIndex = 0
        //self.tabBarController?.tabBar.isHidden = false
        //hide tabbar
        self.hideTabBar()
        if let vcNav = self.navigationController?.viewControllers {
            if vcNav.count > 0 {
                if vcNav[0] is OrdersViewController {
                    self.navigationController?.dismiss(animated: true, completion: nil)
                    return
                }
                self.navigationController?.setViewControllers([vcNav[0]], animated: true)
                return
            }
        }
        self.navigationController?.popToRootViewController(animated: true)
        
    }
    
    
    
    func goToOrders() {
        if UserDefaults.isUserLoggedIn() {
            ElGrocerUtility.sharedInstance.delay(0.1) { [weak self] in
                guard let self = self else {return}
                self.showOrderVC()
            }
            ElGrocerUtility.sharedInstance.delay(0.2) { [weak self] in
                guard let self = self else {return}
               // elDebugPrint(self)
                
                let SDKManager = SDKManager.shared
                if let nav = SDKManager.rootViewController as? UINavigationController {
                    if nav.viewControllers.count > 0 {
                        if  nav.viewControllers[0] as? UITabBarController != nil {
                            let tababarController = nav.viewControllers[0] as! UITabBarController
                            tababarController.selectedIndex = 4
                            return
                        }
                    }
                }
//                let SDKManager = SDKManager.shared
//                if SDKManager.window!.rootViewController as? UITabBarController != nil {
//                    let tababarController = SDKManager.window!.rootViewController as! UITabBarController
//                    tababarController.selectedIndex = 4
//                }
            }
            
        }
        
    }
    
    fileprivate func showOrderVC(){
        
        let ordersController = ElGrocerViewControllers.ordersViewController()
        let navigationController = ElGrocerNavigationController.init(rootViewController: ordersController)
        navigationController.modalPresentationStyle = .fullScreen
        self.navigationController?.present(navigationController, animated: true, completion: { });
        
    }
    
    
    func setCollectorStatus (_ currentOrder : Order , isOnTheWay : Bool , button : UIButton ) {
   
        let status = isOnTheWay ? "1" : "2"
        ElGrocerApi.sharedInstance.updateCollectorStatus(orderId: currentOrder.dbID.stringValue , collector_status: status, shopper_id: currentOrder.shopperID?.stringValue ?? "" , collector_id: currentOrder.collector?.dbID.stringValue ?? "") { (result) in
            switch result {
                case .success( _):
                    let msg = localizedString("status_Update_Msg", comment: "")
                    if isOnTheWay {
                        self.btnOnMyWay.setImage(UIImage(name: "statusCheckTickIcon"), for: UIControl.State())
                        self.btnOnMyWay.tintColor = .white
                        self.btnAtTheStore.setImage(nil, for: UIControl.State())
                        self.btnOnMyWay.setBackgroundColor(ApplicationTheme.currentTheme.buttonEnableSecondaryDarkBGColor, forState: UIControl.State())
                        self.btnAtTheStore.setBackgroundColor(ApplicationTheme.currentTheme.buttonEnableBGColor, forState: UIControl.State())
                    }else{
                        self.btnAtTheStore.setBackgroundColor(ApplicationTheme.currentTheme.buttonEnableSecondaryDarkBGColor, forState: UIControl.State())
                        self.btnOnMyWay.setBackgroundColor(ApplicationTheme.currentTheme.buttonEnableBGColor, forState: UIControl.State())
                        self.btnAtTheStore.setImage(UIImage(name: "statusCheckTickIcon"), for: UIControl.State())
                        self.btnOnMyWay.setImage(nil, for: UIControl.State())
                        self.btnAtTheStore.tintColor = .white
                    }
                    ElGrocerUtility.sharedInstance.showTopMessageView(msg , image: UIImage(name: "White-info") , -1 , false) { (sender , index , isUnDo) in  }
                case .failure(let error):
                    error.showErrorAlert()
                
            }
        }
        
        
        
    }
    
    
    // MARK: Push Notification Registeration
    
    func checkForPushNotificationRegisteration() {
        ElGrocerUtility.sharedInstance.delay(1) {
            let isRegisteredForRemoteNotifications = UIApplication.shared.isRegisteredForRemoteNotifications
            
            let askDate = (UserDefaults.notificationAskDate ?? Date()).addingTimeInterval(60 * 60 * 24)
            let currentDate = Date()
            
            if isRegisteredForRemoteNotifications == false, askDate < currentDate {
                let SDKManager = SDKManager.shared
                UserDefaults.notificationAskDate = currentDate
                _ = NotificationPopup.showNotificationPopup(self, withView: SDKManager.window!)
            }
        }
    }
    
    func deleteBasketFromServerWithGrocery(_ grocery:Grocery?){
        
        guard UserDefaults.isUserLoggedIn() else {return}
        ElGrocerApi.sharedInstance.deleteBasketFromServerWithGrocery(grocery) { (result) in
            switch result {
            case .success(let responseDict):
               elDebugPrint("Delete Basket Response:%@",responseDict)
            case .failure(let error):
               elDebugPrint("Delete Basket Error:%@",error.localizedMessage)
            }
        }
        
        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        ShoppingBasketItem.clearActiveGroceryShoppingBasket(DatabaseHelper.sharedInstance.mainManagedObjectContext)//
        DatabaseHelper.sharedInstance.saveDatabase()
        ElGrocerUtility.sharedInstance.resetBasketPresistence()
        
    }
    
    @IBAction func goToOrderDetailAction(_ sender: Any) {
        
      
        let controller = ElGrocerViewControllers.orderDetailsViewController()
        controller.order = self.order
        controller.isCommingFromOrderConfirmationScreen = true
        controller.mode = .dismiss
        self.navigationController?.pushViewController(controller, animated: true)
        
        // Logging segment event for order details clicked
        SegmentAnalyticsEngine.instance.logEvent(event: OrderDetailsClickedEvent(order: order))
        
    }
    
    func goForSubsiutionProcess() {
        
        if (self.order.status.intValue == OrderStatus.inSubtitution.rawValue) {
            let substitutionsProductsVC = ElGrocerViewControllers.substitutionsProductsViewController()
            let orderId = self.order.dbID.stringValue ?? ""
            substitutionsProductsVC.orderId = orderId
            ElGrocerUtility.sharedInstance.isNavigationForSubstitution = true
            self.navigationController?.pushViewController(substitutionsProductsVC, animated: true)
            
            // Logging segment event for choose replacement clicked
            SegmentAnalyticsEngine.instance.logEvent(event: ChooseReplacementClickedEvent(order: self.order, grocery: self.grocery))
        }
    }

    
    
    func getImageForLocation() { }
   
    func checkIfPickerAvailable(deliveryMode : OrderType , statusId : Int) -> Bool{
        if deliveryMode == .CandC{
          let isPickerAvailable = !(statusId == OrderStatus.pending.rawValue || statusId == OrderStatus.canceled.rawValue) && !(statusId >= OrderStatus.enRoute.rawValue && statusId <= OrderStatus.delivered.rawValue || statusId == OrderStatus.STATUS_READY_TO_DELIVER.rawValue )
            return isPickerAvailable
        }else{
            let isPickerAvailable = statusId >= OrderStatus.enRoute.rawValue && statusId <= OrderStatus.delivered.rawValue || statusId == OrderStatus.canceled.rawValue || statusId == OrderStatus.STATUS_READY_TO_DELIVER.rawValue
            
            return isPickerAvailable
        }
    }

}

extension OrderConfirmationViewController:NotificationPopupProtocol {
    
    func enableUserPushNotification(){
        //UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
        let SDKManager = SDKManager.shared
        SDKManager.registerForNotifications()
    }
}


extension OrderConfirmationViewController {
    
    
    func logFirstOrderEvents () {
        
        let offSet =  0
        
        ElGrocerApi.sharedInstance.getOrdersHistoryList(limit: 5 , offset: offSet ) { (result) -> Void in
            SpinnerView.hideSpinnerView()
            switch result {
                case .success(let orderDict):
                 let result = Order.getOrderCount(orderDict, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
                    let count = result.0
                    let ordersss = result.1
                    if count == 1 {
                        if let data = ordersss {
                            FireBaseEventsLogger.trackFirstOrder(data)
                        }
                    }
                case .failure(_): break
                   // error.showErrorAlert()
            }
        }
        
        
        
        
    }
    
    
   
    

    
}

extension OrderConfirmationViewController : UITableViewDelegate , UITableViewDataSource {
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard self.order != nil else { return 0 }
        if self.order.isCandCOrder() {
            return 4 + smileSection
        }
        return 1 + smileSection
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        guard self.order != nil else { return .leastNormalMagnitude }
        
        if self.order.isCandCOrder() {
            if indexPath.section == 0 && smileSection == 1{
                return smilePointTableCellHeight
            }
            if indexPath.section == 0 + smileSection {
                return KWarningAlertCellHeight
            }else if indexPath.section == 1 + smileSection {
                if indexPath.row == 0{
                    return 56
                }else{
                    var isPickerAvailable = self.order.picker != nil
                    let status = self.order.getOrderDynamicStatus()
                    let id = status.getMappingTypeWithOrderStatus().rawValue
                    isPickerAvailable = self.checkIfPickerAvailable(deliveryMode: .CandC, statusId: id)
                    var orderDetailIndex = 1
                    if isPickerAvailable {
                        orderDetailIndex = 2
                    }
                    if order.isCandCOrder(){
                        if indexPath.row == orderDetailIndex + 1 {
                            let height = ElGrocerUtility.sharedInstance.dynamicHeight(text: order?.pickUp?.details ?? "", font: UIFont.SFProDisplaySemiBoldFont(14), width: ScreenSize.SCREEN_WIDTH - 90)
                            
                            return 60 + height
                        }
                    }
                    
                    
                    
                    return 80
                }
            }else if indexPath.section == 2 + smileSection {
                return kCandCLocationCellHeight
            }
            return ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner()
        }else{
            
            if indexPath.section == 0 && smileSection == 1{
                return smilePointTableCellHeight
            }
            
            let status = self.order.getOrderDynamicStatus()
            let orderStatus = status.getMappingTypeWithOrderStatus()
            
            if indexPath.row == 0 {
                return KWarningAlertCellHeight
            }else if indexPath.row == 1 {
                
                if orderStatus == .pending{
                    return KWarningAlertCellHeight
                }else{
                    return 80
                }
            }else if indexPath.row == 2{
                return 80
            }
            else if indexPath.row == 3 {
                if self.checkIfPickerAvailable(deliveryMode: .delivery, statusId: orderStatus.rawValue){
                    return ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner()
                }
                return 80
            }
            return ElGrocerUtility.sharedInstance.getTableViewCellHeightForBanner()
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.order != nil else { return 0 }
        let status = self.order.getOrderDynamicStatus()
        if self.order.isDeliveryOrder() {
            if section == 0 && smileSection == 1 {
                return 1
            }
            
            let orderStatus = status.getMappingTypeWithOrderStatus()
            
            if  self.checkIfPickerAvailable(deliveryMode: .delivery, statusId: orderStatus.rawValue){
                return 3 + (self.bannersList.count > 0 ? 1 : 0)
            }
            return 4 + (self.bannersList.count > 0 ? 1 : 0)
        }else{
            
            if section == 0 && self.smileSection == 1 {
                return 1
            }
            if section == 0 + smileSection {
                
                if status.getMappingTypeWithOrderStatus().rawValue < OrderStatus.accepted.rawValue  {
                    return 3
                }
                return 2
            }else if section == 1 + smileSection {
                let id = status.getMappingTypeWithOrderStatus().rawValue
                let isPickerAvailable = self.checkIfPickerAvailable(deliveryMode: .CandC, statusId: id)
                if isPickerAvailable{
                    return 6
                }
                return 5
            }else if section == 2 + smileSection{
                return 1
            }
            return 1
        }
       
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && smileSection == 1 {
            let smilepoints = UserDefaults.getSmilesPoints()
            SmilesEventsLogger.smilesImpressionEvent(isSmileslogin: true, smilePoints: smilepoints)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard self.order != nil else {
            let cell : SpaceTableViewCell = tableView.dequeueReusableCell(withIdentifier: "SpaceTableViewCell", for: indexPath) as! SpaceTableViewCell
            return cell
        }
        
        if self.order.isDeliveryOrder() {
            
            if indexPath.section == 0 && smileSection == 1 {
                let cell : smilePointTableCell = tableView.dequeueReusableCell(withIdentifier: "smilePointTableCell", for: indexPath) as! smilePointTableCell
                cell.ConfigurePaidWithSmile()
                return cell
            }
            
            let status = self.order.getOrderDynamicStatus()
            let orderStatus = status.getMappingTypeWithOrderStatus()
            
            if indexPath.row == 0 {
                if orderStatus != .pending{

                    let cell = tableView.dequeueReusableCell(withIdentifier: "warningAlertCell", for: indexPath) as! warningAlertCell
                    let text = localizedString("order_note_label_complete", comment: "")//+ localizedString("order_Note_Bold_Price_May_Vary", comment: "") + localizedString("order_Note_reason", comment: "")
                    cell.ConfigureCell(text: text, highlightedText: localizedString("order_Note_Bold_Price_May_Vary", comment: ""))
                    return cell
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "warningAlertCell", for: indexPath) as! warningAlertCell
                let text = localizedString("Msg_Edit_Order", comment: "")
                cell.ConfigureCell(text: text, highlightedText: localizedString("lbl_Order_Details", comment: ""))
                return cell
            }else if indexPath.row == 1 {
                
                if self.checkIfPickerAvailable(deliveryMode: .delivery, statusId: orderStatus.rawValue){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStatusDetailCell", for: indexPath) as! OrderStatusDetailCell
                    cell.setAppearence(cellType: .orderDetailButton)
                    cell.configureStoreNameAndOrderId(self.order.grocery.name ?? "", self.order.dbID.stringValue)
                    cell.orderdetailAction = { [weak self](isOrderDetail) in
                        guard let self = self else {return}
                        self.goToOrderDetailAction("")
                    }
                    return cell
                }
                
                if self.order != nil && self.order.picker != nil && orderStatus != .pending {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStatusDetailCell", for: indexPath) as! OrderStatusDetailCell
                    cell.setAppearence(cellType: .chatButton)
                    cell.configurePickerName(self.order.picker?.name ?? "")
                    cell.chatwithPickerAction = { [weak self](isChat) in
                        guard let self = self else {return}
                        if let pickerID = self.order.picker?.dbID.stringValue{
                            self.callSendBirdChat(pickerID: pickerID)
                        }
                    }
                    return cell
                }else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "warningAlertCell", for: indexPath) as! warningAlertCell
                    let text = localizedString("order_note_label_complete", comment: "") //+ localizedString("order_Note_Bold_Price_May_Vary", comment: "") + localizedString("order_Note_reason", comment: "")
                    cell.ConfigureCell(text: text, highlightedText: localizedString("order_Note_Bold_Price_May_Vary", comment: ""))
                    return cell
                }
            }else if indexPath.row == 2 {
                
                if self.checkIfPickerAvailable(deliveryMode: .delivery, statusId: orderStatus.rawValue){
                    let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStatusDetailCell", for: indexPath) as! OrderStatusDetailCell
                    cell.setAppearence(cellType: .location)
                    let addressString = ElGrocerUtility.sharedInstance.getFormattedAddress(self.order.deliveryAddress) + self.order.deliveryAddress.address
                    cell.configureLocationName(addressString)
                    return cell
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStatusDetailCell", for: indexPath) as! OrderStatusDetailCell
                cell.setAppearence(cellType: .orderDetailButton)
                cell.configureStoreNameAndOrderId(self.order.grocery.name ?? "", self.order.dbID.stringValue)
                cell.orderdetailAction = { [weak self](isOrderDetail) in
                    guard let self = self else {return}
                    self.goToOrderDetailAction("")
                }
                return cell
            }else if indexPath.row == 3 {
                
                if  self.checkIfPickerAvailable(deliveryMode: .delivery, statusId: orderStatus.rawValue){
                    let cell : GenericBannersCell = tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
                    cell.configured(bannersList)
                    cell.bannerList.bannerCampaignClicked = { [weak self] (banner) in
                        guard let self = self  else {   return   }
                        
                        if let bidid = banner.resolvedBidId {
                            TopsortManager.shared.log(.clicks(resolvedBidId: bidid))
                        }

                        if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                            ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                        }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                            banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: ElGrocerUtility.sharedInstance.groceries)
                        }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue {
                            banner.changeStoreForBanners(currentActive: nil, retailers: ElGrocerUtility.sharedInstance.groceries)
                        }
                    }
                    return cell
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStatusDetailCell", for: indexPath) as! OrderStatusDetailCell
                cell.setAppearence(cellType: .location)
                let addressString = ElGrocerUtility.sharedInstance.getFormattedAddress(self.order.deliveryAddress) + self.order.deliveryAddress.address
                cell.configureLocationName(addressString)
                return cell
            }else {
                let cell : GenericBannersCell = tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
                cell.configured(bannersList)
                cell.bannerList.bannerCampaignClicked = { [weak self] (banner) in
                    guard let self = self  else {   return   }
                    
                    if let bidid = banner.resolvedBidId {
                        TopsortManager.shared.log(.clicks(resolvedBidId: bidid))
                    }

                    if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                        ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                    }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                        // self.showWebUrl(banner.url)
                        banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: ElGrocerUtility.sharedInstance.groceries)
                    }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue {
                        banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: ElGrocerUtility.sharedInstance.groceries)
                    }
                }
                return cell
            }
            
       
        }else{
            if indexPath.section == 0 && smileSection == 1 {
                let cell : smilePointTableCell = tableView.dequeueReusableCell(withIdentifier: "smilePointTableCell", for: indexPath) as! smilePointTableCell
                cell.ConfigurePaidWithSmile()
                return cell
            }
            if indexPath.section == 0 + smileSection {
                
                let status = self.order.getOrderDynamicStatus()
                if status.getMappingTypeWithOrderStatus().rawValue < OrderStatus.accepted.rawValue {
                        let cell = tableView.dequeueReusableCell(withIdentifier: "warningAlertCell", for: indexPath) as! warningAlertCell
                        if indexPath.row == 0 {
                            let text = localizedString("lbl_Alert_Arrive_on_time", comment: "")
                            cell.ConfigureCell(text: text, highlightedText: localizedString("lbl-collection-TimeLimit-alert", comment: ""))
                        }
                        if indexPath.row == 1 {
                            let text = localizedString("Msg_Edit_Order", comment: "")
                            cell.ConfigureCell(text: text, highlightedText: localizedString("lbl_Order_Details", comment: ""))
                        }
                        if indexPath.row == 2 {
                            let text = localizedString("order_note_label_complete", comment: "") //+ localizedString("order_Note_Bold_Price_May_Vary", comment: "") + localizedString("order_Note_reason", comment: "")
                            cell.ConfigureCell(text: text, highlightedText: localizedString("order_Note_Bold_Price_May_Vary", comment: ""))
                        }
                        return cell
                }else{
                        let cell = tableView.dequeueReusableCell(withIdentifier: "warningAlertCell", for: indexPath) as! warningAlertCell
                        if indexPath.row == 0 {
                            let text = localizedString("lbl_Alert_Arrive_on_time", comment: "")
                            cell.ConfigureCell(text: text, highlightedText: localizedString("lbl-collection-TimeLimit-alert", comment: ""))
                        }
                        if indexPath.row == 1 {
                            let text = localizedString("order_note_label_complete", comment: "") //+ localizedString("order_Note_Bold_Price_May_Vary", comment: "") + localizedString("order_Note_reason", comment: "")
                            cell.ConfigureCell(text: text, highlightedText: localizedString("order_Note_Bold_Price_May_Vary", comment: ""))
                        }
                        return cell
                }
  
            }else if indexPath.section == 1 + smileSection{
                
                
                if indexPath.row == 0{
                    let cell = tableView.dequeueReusableCell(withIdentifier: "shareCollectionDetailCell", for: indexPath) as! shareCollectionDetailCell
                    cell.currentOrder = self.order
                    return  cell
                }
                
                let cell = tableView.dequeueReusableCell(withIdentifier: "OrderStatusDetailCell", for: indexPath) as! OrderStatusDetailCell
                
                var isPickerAvailable = self.order.picker != nil
                let status = self.order.getOrderDynamicStatus()
                let id = status.getMappingTypeWithOrderStatus().rawValue
                isPickerAvailable = self.checkIfPickerAvailable(deliveryMode: .CandC, statusId: id)
                
                
                var orderDetailIndex = 1
                if isPickerAvailable {
                    orderDetailIndex = 2
                }
                //if id == OrderStatus.pending.rawValue || id == OrderStatus.canceled.rawValue{
                    if isPickerAvailable && indexPath.row == 1 {
                        cell.setAppearence(cellType: .chatButton)
                        cell.configurePickerName(self.order.picker?.name ?? "")
                        cell.chatwithPickerAction = { [weak self](isChat) in
                            guard let self = self else {return}
                            if let pickerID = self.order.picker?.dbID.stringValue{
                                self.callSendBirdChat(pickerID: pickerID)
                            }
                        }
                    }else if indexPath.row == orderDetailIndex {
                        cell.setAppearence(cellType: .orderDetailButton)
                        cell.configureStoreNameAndOrderId(self.order.grocery.name ?? "", self.order.dbID.stringValue)
                        cell.orderdetailAction = { [weak self](isOrderDetail) in
                            guard let self = self else {return}
                            self.goToOrderDetailAction("")
                        }
                    }else if indexPath.row == orderDetailIndex + 1 {
                        cell.setAppearence(cellType: .location)
                        cell.configureCandCLocation(order?.pickUp?.details ?? "")
                    }else if indexPath.row == orderDetailIndex + 2 {
                        cell.setAppearence(cellType: .collectorDetails)
                        cell.configureCandCCollectorDetails(order.collector?.name ?? "", phoneNumber: order.collector?.phone_number ?? "")
                    }else if indexPath.row == orderDetailIndex + 3 {
                        cell.setAppearence(cellType: .carDetails)
                        cell.configureCandCCarDetails(order?.vehicleDetail?.plate_number ?? "", model: order?.vehicleDetail?.vehicleModel_name ?? "", type: order?.vehicleDetail?.company ?? "", color: order?.vehicleDetail?.color_name ?? "")
                    }
                        return cell
                //}
                
                
            }else if indexPath.section == 2 + smileSection{
                let cell = tableView.dequeueReusableCell(withIdentifier: "CandCLocationCell", for: indexPath) as! CandCLocationCell
                cell.currentOrder = self.order
                cell.setMap()
                cell.setPickUpImage()
                return cell
            }
            
        
            let cell : GenericBannersCell = tableView.dequeueReusableCell(withIdentifier: "GenericBannersCell", for: indexPath) as! GenericBannersCell
            cell.configured(bannersList)
            cell.bannerList.bannerCampaignClicked = { [weak self] (banner) in
                guard let self = self  else {   return   }
                
                if let bidid = banner.resolvedBidId {
                    TopsortManager.shared.log(.clicks(resolvedBidId: bidid))
                }

                if banner.campaignType.intValue == BannerCampaignType.web.rawValue {
                    ElGrocerUtility.sharedInstance.showWebUrl(banner.url, controller: self)
                }else if banner.campaignType.intValue == BannerCampaignType.brand.rawValue {
                    banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: ElGrocerUtility.sharedInstance.groceries)
                }else if banner.campaignType.intValue == BannerCampaignType.retailer.rawValue {
                    banner.changeStoreForBanners(currentActive: ElGrocerUtility.sharedInstance.activeGrocery, retailers: ElGrocerUtility.sharedInstance.groceries)
                }
            }
            return cell
            
           
            
            
           /* if indexPath.row == 0 {
                let cell : OrderCollectionDetailsCell =  tableView.dequeueReusableCell(withIdentifier: "OrderCollectionDetailsCell", for: indexPath) as! OrderCollectionDetailsCell
                cell.configureData(self.order)
                return cell
            }else if indexPath.row == 1 {
                let cell : GenericViewTitileTableViewCell = self.tableview.dequeueReusableCell(withIdentifier: KGenericViewTitileTableViewCell , for: indexPath) as! GenericViewTitileTableViewCell
                cell.isTitleOnly = true
                cell.configureCell(title: localizedString("lbl_BestOffers", comment: ""))
                return cell
            }else{
               
               
                
            } */
            
        }
    }
    
    
    
}

extension OrderConfirmationViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
            var y = -scrollView.contentOffset.y
            if shouldScroll{
                y = -scrollView.contentOffset.y
                let height = max(y, currentHeaderHeight)
                if height < currentHeaderHeight + 15{
                    if currentHeaderHeight == orderStatusHeaderHeight{
                        self.statusHeaderView.btnOrderStatus.visibility = .visible
                    }else{
                        self.statusHeaderView.btnOrderStatus.visibility = .goneY
                    }
                    self.statusHeaderView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH, height: currentHeaderHeight)
                    self.statusHeaderView.bGWidthConstraint.constant = 0
                    self.statusHeaderView.bGTopConstraint.constant = 0
                    self.statusHeaderView.cardBGView.clipsToBounds = true
//                    self.statusHeaderView.setNeedsLayout()
//                    self.statusHeaderView.layoutIfNeeded()
                }else{
                    self.statusHeaderView.bGWidthConstraint.constant = -32
                    self.statusHeaderView.bGTopConstraint.constant = 16
                    if currentHeaderHeight == orderStatusHeaderHeight{
                        self.statusHeaderView.btnOrderStatus.visibility = .visible
                    }else{
                        self.statusHeaderView.btnOrderStatus.visibility = .goneY
                    }
                    self.statusHeaderView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: height)
                    self.statusHeaderView.cardBGView.clipsToBounds = false
//                    self.statusHeaderView.setNeedsLayout()
//                    self.statusHeaderView.layoutIfNeeded()
                }
        
            }else{
                shouldScroll = true
                y = -scrollView.contentOffset.y
                let height = max(y, currentHeaderHeight)
                scrollView.contentOffset.y = -height
                self.statusHeaderView.bGWidthConstraint.constant = -32
                self.statusHeaderView.bGTopConstraint.constant = 16
                if currentHeaderHeight == orderStatusHeaderMinHeight{
                    self.statusHeaderView.btnOrderStatus.visibility = .goneY
                }
                self.statusHeaderView.frame = CGRect(x: 0, y: 0, width: ScreenSize.SCREEN_WIDTH , height: currentHeaderHeight + 20)
                self.statusHeaderView.cardBGView.clipsToBounds = false
//                self.statusHeaderView.setNeedsLayout()
//                self.statusHeaderView.layoutIfNeeded()
               
            }
        
        
    }
}
