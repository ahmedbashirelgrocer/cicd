//
//  OrderHistoryCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 16/04/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

let kOrderHistoryCellIdentifier = "OrderHistoryCell"
let kOrderHistoryCellHeight: CGFloat = 335 + 35

class OrderHistoryCell: UITableViewCell {
    
    var buttonClicked: ((_ order : Order)->Void)?
    
    //MARK: Outlets
    @IBOutlet weak var mainContainerView: AWView!
    
    @IBOutlet weak var orderNumberLabel: UILabel! { // now delivery slot is showing
        didSet{
            orderNumberLabel.setBody3BoldUpperStyle(false)
            orderNumberLabel.isHidden = false
        }
    } // now static text delivery
    @IBOutlet weak var orderDateLabel: UILabel!{
        didSet{
            orderDateLabel.setCaptionOneRegDarkStyle()
            orderDateLabel.isHidden = false
        }
    } // now static text delivery
 //   @IBOutlet var imageClockIcon: UIImageView!
    
    @IBOutlet weak var fromLabel: UILabel!{
        didSet{
            fromLabel.setBody3RegSecondaryDarkStyle()
        }
    }
    @IBOutlet weak var groceryAddressLabel: UILabel!
    @IBOutlet weak var toLabel: UILabel!{
        didSet{
            toLabel.setBody3RegSecondaryDarkStyle()
        }
    }
    @IBOutlet weak var userAddressLabel: UILabel!
    
    @IBOutlet weak var quantityTitleLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!{
        didSet{
            quantityLabel.setCaptionOneRegDarkStyle()
        }
    }
    @IBOutlet weak var totalPriceTitleLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!{
        didSet{
            priceLabel.setBody3BoldUpperStyle(false)
        }
    }
    
    @IBOutlet weak var orderStatusLabel: UILabel!{
        didSet{
            orderStatusLabel.setBody3BoldUpperStyle(true)
        }
    }
    @IBOutlet weak var orderStatusIcon: UIImageView!
    
    @IBOutlet weak var productCollectionView: UICollectionView!
    @IBOutlet weak var viewOrderLabel: UILabel!
    @IBOutlet weak var nextArrow: UIImageView!
    
    @IBOutlet weak var statusViewWidth: NSLayoutConstraint!
    @IBOutlet var lblDeliverySlot: UILabel! // order number is shown here
    @IBOutlet var btnChoose: AWButton! {
        
        didSet{
            btnChoose.setH4SemiBoldWhiteStyle()
        }
        
    }
    
    @IBOutlet var lblEstimatedDelivery: UILabel!{
        didSet{
            lblEstimatedDelivery.setBody3RegSecondaryDarkStyle()
            lblEstimatedDelivery.text = NSLocalizedString("title_estimated_delivery", comment: "")
        }
    }
    @IBOutlet var progressView: UIProgressView! {
        
        didSet{
            
            progressView.progressTintColor = .navigationBarColor()
            progressView.layer.cornerRadius = 4
            progressView.clipsToBounds = true
            
        }
    }
    
    @IBOutlet var trackingView: UIView!
    @IBOutlet var lblOrderTracking: UILabel!
    @IBOutlet var lblTrackyourOrder: UILabel!{
        didSet{
            self.lblTrackyourOrder.text = NSLocalizedString("lbl_Track_your_order", comment: "")
        }
    }
   
    @IBAction func trackYourOrderAction(_ sender: Any) {
        if let trackingUrl = self.currentOrder?.trackingUrl {
            let statusId = self.currentOrder?.getOrderDynamicStatus().getStatusKeyLogic().status_id.stringValue ?? "-1000"
            TrackingNavigator.presentTrackingViewWith(trackingUrl, orderId: self.currentOrder?.dbID.stringValue ?? "", statusId: statusId)
        }
    }
    
    lazy var getdataFormmater : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd,yyyy hh:mm a"
        return formatter
    }()
    var orderProducts:[Any]?
    var orderItems:[ShoppingBasketItem]!
    var currentOrder : Order? = nil
    var dateFormatter:DateFormatter!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.backgroundColor = UIColor.clear
        self.selectionStyle = UITableViewCell.SelectionStyle.none
        
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "hh:mm a - dd/MM/yyyy"
        
        let phoneLanguage = UserDefaults.getCurrentLanguage()
        if phoneLanguage == "ar" {
            dateFormatter.locale = Locale(identifier: "ar")
        }
        
        let orderProductCellNib = UINib(nibName: "OrderProductCell", bundle:nil)
        self.productCollectionView.register(orderProductCellNib, forCellWithReuseIdentifier: kOrderProductCellIdentifier)
        
        self.setUpOrderDateLabelAppearance()
        self.setUpOrderNumberLabelAppearance()
        self.setUpOrderStatusLabelAppearance()
        self.setUpQuantityLabelAppearance()
        self.setUpPriceLabelAppearance()
        self.setUpViewOrderLabelAppearance()
        self.setUpUserAddressLabelAppearance()
        self.setUpGroceryAddressLabelAppearance()
    }
    
    private func setUpOrderDateLabelAppearance() {
//        self.orderDateLabel.textColor = UIColor(red: 135.0 / 255.0, green: 135.0 / 255.0, blue: 135.0 / 255.0, alpha: 0.50)
//        self.orderDateLabel.font = UIFont.openSansSemiBoldFont(13.0)
        
    }
    
    private func setUpOrderNumberLabelAppearance() {
//        self.orderNumberLabel.textColor = UIColor.black
//        self.orderNumberLabel.font = UIFont.openSansSemiBoldFont(13.0)
//
//
//        self.lblDeliverySlot.textColor = UIColor(red: 135.0 / 255.0, green: 135.0 / 255.0, blue: 135.0 / 255.0, alpha: 0.50)
//        self.lblDeliverySlot.font = UIFont.openSansSemiBoldFont(13.0)
        
    }
    
    private func setUpOrderStatusLabelAppearance() {
//        self.orderStatusLabel.textColor = UIColor.white
//        self.orderStatusLabel.font = UIFont.openSansSemiBoldFont(13.0)
    }
    
    private func setUpGroceryAddressLabelAppearance() {
        
//        self.fromLabel.textColor = UIColor(red: 135.0 / 255.0, green: 135.0 / 255.0, blue: 135.0 / 255.0, alpha: 1)
//        self.fromLabel.font = UIFont.openSansSemiBoldFont(14.0)
//
//        self.groceryAddressLabel.textColor = UIColor.black
//        self.groceryAddressLabel.font = UIFont.openSansSemiBoldFont(13.0)
    }
    
    private func setUpUserAddressLabelAppearance() {
        
//        self.toLabel.textColor = UIColor(red: 135.0 / 255.0, green: 135.0 / 255.0, blue: 135.0 / 255.0, alpha: 1)
//        self.toLabel.font = UIFont.openSansSemiBoldFont(14.0)
//
//        self.userAddressLabel.textColor = UIColor.black
//        self.userAddressLabel.font = UIFont.openSansSemiBoldFont(13.0)
    }
    
    private func setUpQuantityLabelAppearance() {
        
//        self.quantityTitleLabel.textColor = UIColor(red: 135.0 / 255.0, green: 135.0 / 255.0, blue: 135.0 / 255.0, alpha: 1)
//        self.quantityTitleLabel.font = UIFont.openSansSemiBoldFont(14.0)
//
//        self.quantityLabel.textColor = UIColor.black
//        self.quantityLabel.font = UIFont.openSansSemiBoldFont(13.0)
    }
    
    private func setUpPriceLabelAppearance() {
        
//        self.totalPriceTitleLabel.textColor = UIColor(red: 135.0 / 255.0, green: 135.0 / 255.0, blue: 135.0 / 255.0, alpha: 1)
//        self.totalPriceTitleLabel.font = UIFont.openSansSemiBoldFont(14.0)
//
//        self.priceLabel.textColor = UIColor.navigationBarColor()
//        self.priceLabel.font = UIFont.openSansSemiBoldFont(13.0)
    }
    
    private func setUpViewOrderLabelAppearance() {
        
        self.viewOrderLabel.setBody3BoldUpperStyle() 
        let image = ElGrocerUtility.sharedInstance.getImageWithName("arrowForward")
        self.nextArrow.image = image
        self.nextArrow.image = self.nextArrow.image!.withRenderingMode(.alwaysTemplate)
        self.nextArrow.tintColor = UIColor.navigationBarColor()
    }
    
    // MARK: Data
    func configureWithOrder(_ order:Order) {
        
        self.currentOrder = order
        self.setButtonType(order)
        self.fromLabel.text = NSLocalizedString("from_title", comment: "")
       
        self.toLabel.text = ( self.currentOrder?.isCandCOrder() ?? false ? NSLocalizedString("lbl_order_collection_Address", comment: "") :  NSLocalizedString("delivery_address", comment: "")) + ":"
        
        self.quantityTitleLabel.text = NSLocalizedString("quantity_:", comment: "")
        self.totalPriceTitleLabel.text = NSLocalizedString("total_price_:", comment: "")
        self.viewOrderLabel.text = NSLocalizedString("lbl_Order_Details", comment: "")
        self.userAddressLabel.text = self.currentOrder?.pickUp != nil  ? self.currentOrder?.pickUp?.details :  ElGrocerUtility.sharedInstance.getFormattedAddress(order.deliveryAddress)
        self.groceryAddressLabel.text = order.grocery.name
        self.orderDateLabel.text = ""
        //MARK: time is handled in orderNumberLabel
        self.orderNumberLabel.text = order.getSlotFormattedString()
        
        self.lblDeliverySlot.text = NSLocalizedString("order_lbl_numner", comment: "") + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: order.dbID.stringValue)
        
        let string = NSMutableAttributedString(string: self.lblDeliverySlot.text ?? "")
        string.setColorForText(NSLocalizedString("order_lbl_numner", comment: "") , with: .secondaryBlackColor())
        string.setColorForText(" # " , with: .secondaryBlackColor())
        string.setFontForText(NSLocalizedString("order_lbl_numner", comment: "") , with: .SFProDisplayNormalFont(14))
        
        string.setFontForText(" # " , with: .SFProDisplayNormalFont(14))
        string.setColorForText(String(format: "%d",order.dbID.intValue) , with: UIColor.newBlackColor())
        string.setFontForText(String(format: "%d",order.dbID.intValue) , with: .SFProDisplaySemiBoldFont(14))
        
        self.lblDeliverySlot.attributedText = string
        
        if order.status.intValue == OrderStatus.inSubtitution.rawValue {
             self.mainContainerView.borderColor = .elGrocerYellowColor()
            self.progressView.progressTintColor = UIColor.elGrocerYellowColor()
        }else{
            self.mainContainerView.borderColor = .elGrocerOrderBorderColor()
            self.progressView.progressTintColor = UIColor.navigationBarColor()
            
        }
        
        //
        let status = order.getOrderDynamicStatus()
        let statusString : String = ElGrocerUtility.sharedInstance.isArabicSelected() ? status.nameAr : status.nameEn
        let statusUppercased = statusString.uppercased()
        self.orderStatusLabel.text = statusUppercased
        let data = status.getStatusKeyLogic()
        
        if data.service_id.intValue == Int(OrderType.delivery.rawValue){
            self.lblEstimatedDelivery.text = NSLocalizedString("title_Estimated_delivery", comment: "")
        }else{
            self.lblEstimatedDelivery.text = NSLocalizedString("lbl_self_collection_time", comment: "")
        }
        
        switch data.status_id.intValue {
        case OrderStatus.pending.rawValue:
            
            if order.deliverySlot != nil {
                let orderStatusIcon = ElGrocerUtility.sharedInstance.getImageWithName("icHalfflagViolet")
                self.orderStatusIcon.image = orderStatusIcon
                self.orderStatusLabel.textColor = UIColor.navigationBarColor()
            }else{
                let orderStatusIcon = ElGrocerUtility.sharedInstance.getImageWithName("icHalfflagYellow")
                self.orderStatusIcon.image = orderStatusIcon
                self.orderStatusLabel.textColor = UIColor.navigationBarColor()
            }
            
        case OrderStatus.accepted.rawValue:
            let orderStatusIcon = ElGrocerUtility.sharedInstance.getImageWithName("icHalfflagGreen")
            self.orderStatusIcon.image = orderStatusIcon
            self.orderStatusLabel.textColor = UIColor.navigationBarColor()
        
        case OrderStatus.inSubtitution.rawValue:
            let orderStatusIcon = ElGrocerUtility.sharedInstance.getImageWithName("icHalfflagOrange")
            self.orderStatusIcon.image = orderStatusIcon
            self.orderStatusLabel.textColor = UIColor.elGrocerYellowColor()
            
        case OrderStatus.enRoute.rawValue:
            let orderStatusIcon = ElGrocerUtility.sharedInstance.getImageWithName("icHalfflagBlue")
            self.orderStatusIcon.image = orderStatusIcon
            self.orderStatusLabel.textColor = UIColor.navigationBarColor()
            
        case OrderStatus.completed.rawValue:
            self.lblEstimatedDelivery.text = ""
            let orderStatusIcon = ElGrocerUtility.sharedInstance.getImageWithName("icHalfflagGray")
            self.orderStatusIcon.image = orderStatusIcon
            self.orderStatusLabel.textColor = UIColor.navigationBarColor()
            
        case OrderStatus.delivered.rawValue:
                self.lblEstimatedDelivery.text = ""
                let orderStatusIcon = ElGrocerUtility.sharedInstance.getImageWithName("icHalfflagGray")
                self.orderStatusIcon.image = orderStatusIcon
                self.orderStatusLabel.textColor = UIColor.navigationBarColor()
            
        case OrderStatus.canceled.rawValue:
            let orderStatusIcon = ElGrocerUtility.sharedInstance.getImageWithName("icHalfflagRed")
            self.orderStatusIcon.image = orderStatusIcon
            self.orderStatusLabel.textColor = UIColor.redInfoColor()
            self.lblEstimatedDelivery.text  = ""
            self.orderNumberLabel.text = ""
            
        default:
            let orderStatusIcon = ElGrocerUtility.sharedInstance.getImageWithName("icHalfflagYellow")
            self.orderStatusIcon.image = orderStatusIcon
            self.orderStatusLabel.textColor = UIColor.navigationBarColor()
        }
        if order.itemsPossition.count > 0 {
            self.orderProducts = order.itemsPossition
        }else if order.itemImages.count > 0 {
            self.orderProducts = order.itemImages
        }else{
            self.orderProducts = ShoppingBasketItem.getBasketProductsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext ) as [Product]
            self.orderItems = ShoppingBasketItem.getBasketItemsForOrder(order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        }
        self.productCollectionView.reloadData()
        self.setSummaryData()
        if let trackingUrl =  order.trackingUrl {
            trackingView.isHidden = trackingUrl.count == 0
        }else {
            trackingView.isHidden = true
        }
    }
    
    func setButtonType (_ order : Order) {
        
        if order.status.intValue == OrderStatus.payment_pending.rawValue {
            self.btnChoose.setTitle(NSLocalizedString("lbl_Payment_Confirmation", comment: ""), for: .normal)
        }else if order.status.intValue == OrderStatus.inSubtitution.rawValue {
            self.btnChoose.setTitle(NSLocalizedString("choose_substitutions_title", comment: ""), for: .normal)
        }else {
            self.btnChoose.setTitle(NSLocalizedString("order_confirmation_Edit_order_button", comment: ""), for: .normal)
        }
    }

    
//    private func loadOrderStatusLabel(_ order: Order!) -> String {
//
////        if order.status.intValue == -1 {
////            return NSLocalizedString("lbl_Payment_Pending", comment: "")
////        }
////        if order.deliverySlot != nil && order.status.intValue == 0 {
////            return NSLocalizedString("order_status_schedule_order", comment: "")
////        }else if ((order.status.intValue < OrderStatus.labels.count)) {
////            return NSLocalizedString(OrderStatus.labels[order.status.intValue], comment: "")
////        } else {
////            return NSLocalizedString("order_status_unknown", comment: "")
////        }
//    }
    
    private func setSummaryData() {
        
       
        
        
        if self.orderProducts is [Product] {
            var summaryCount = 0
            var priceSum = 0.00
            for product in self.orderProducts ?? [] {
                
                let item = self.shoppingItemForProduct(product as! Product)
                if let notNilItem = item {
                    summaryCount += notNilItem.count.intValue
                    priceSum += (product as AnyObject).price.doubleValue * notNilItem.count.doubleValue
                    
                }
            }
            
            
            if let totalValue = self.currentOrder?.totalValue {
                if totalValue > 0 {
                    priceSum = totalValue
                }
                
            }
            
            
            let serviceFee = ElGrocerUtility.sharedInstance.getFinalServiceFee(currentGrocery: self.currentOrder!.grocery, totalPrice: priceSum)
            
            var grandTotal = priceSum + serviceFee
            if let price = Double(self.currentOrder?.priceVariance ?? "0") {
                grandTotal = grandTotal + price
            }
            
            if let totalProducts = self.currentOrder?.totalProducts {
                if totalProducts > 0 {
                    summaryCount = Int(totalProducts)
                }
            }
            
            //summary
            let countLabel = summaryCount == 1 ? NSLocalizedString("shopping_basket_items_count_singular", comment: "") : NSLocalizedString("shopping_basket_items_count_plural", comment: "")
            self.quantityLabel.text = "(" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(summaryCount) ") + countLabel + ")"
            
//            self.priceLabel.text = String(format:"%@ %.2f",CurrencyManager.getCurrentCurrency() , grandTotal)
            self.priceLabel.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: grandTotal)
            
        }else{
            var summaryCount = 0
            var priceSum = 0.00
            
            if let totalValue = self.currentOrder?.totalValue {
                if totalValue > 0 {
                    priceSum = totalValue
                }
                
            }
            var serviceFee = ElGrocerUtility.sharedInstance.getFinalServiceFee(currentGrocery: self.currentOrder!.grocery, totalPrice: priceSum)
            var grandTotal = priceSum + serviceFee
            if let price = Double(self.currentOrder?.priceVariance ?? "0") {
                grandTotal = grandTotal + price
            }
            
            if let totalProducts = self.currentOrder?.totalProducts {
                if totalProducts > 0 {
                    summaryCount = Int(totalProducts)
                }
            }
            
            //summary
            let countLabel = summaryCount == 1 ? NSLocalizedString("shopping_basket_items_count_singular", comment: "") : NSLocalizedString("shopping_basket_items_count_plural", comment: "")
            self.quantityLabel.text = "(" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(summaryCount) ") + countLabel + ")"
            
//            self.priceLabel.text = String(format:"%@ %.2f",CurrencyManager.getCurrentCurrency() ,grandTotal)
            self.priceLabel.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: grandTotal)
        }
        
       
    }
    
    // MARK: Helpers
    
    private func shoppingItemForProduct(_ product:Product) -> ShoppingBasketItem? {
        
        for item in self.orderItems {
            if product.dbID == item.productId {
                return item
            }
        }
        return nil
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        if let clouser = self.buttonClicked {
            if let order = self.currentOrder {
                 clouser(order)
            }
        }
        
    }
    
    func setProgressAccordingToStatus(_ status : DynamicOrderStatus? , totalStep : Float) {
        guard status != nil else {
            return
        }
        let progress : Float = status!.stepNumber.floatValue / totalStep
        self.progressView.setProgress(progress , animated: true)
    }
    
    
    
}

extension OrderHistoryCell: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.orderProducts?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: kOrderProductCellIdentifier, for: indexPath) as! OrderProductCell
        
        if self.orderProducts is [Product] {
            if let product = self.orderProducts?[indexPath.row] {
                cell.configureWithProduct(product as! Product)
            }
        }else if self.orderProducts is [String]{
            if let product = self.orderProducts?[indexPath.row] {
                cell.configureWithProductImage(product as? String)
            }
        }else if self.orderProducts is [NSDictionary]{
            if let product = self.orderProducts?[indexPath.row] {
                cell.configureWithProductImageDictionary(product as? NSDictionary)
            }
        }
        
        
    
        return cell
    }
}

extension OrderHistoryCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // create a cell size from the image size, and return the size
        let cellSize = CGSize(width: 95 + GlobalShadowSpace , height: 86 + GlobalShadowSpace)
        return cellSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 12 , bottom: 0, right: 12)
    }
}
extension NSMutableAttributedString{
    func setColorForText(_ textToFind: String, with color: UIColor) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.foregroundColor, value: color, range: range)
        }
    }
    func setFontForText(_ textToFind: String, with font: UIFont) {
        let range = self.mutableString.range(of: textToFind, options: .caseInsensitive)
        if range.location != NSNotFound {
            addAttribute(NSAttributedString.Key.font, value: font, range: range)
        }
    }
    
}
