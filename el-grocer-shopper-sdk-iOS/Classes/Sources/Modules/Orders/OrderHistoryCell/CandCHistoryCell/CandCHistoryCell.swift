//
//  CandCHistoryCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 18/06/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

let CandCHistoryCellHeight : CGFloat = 480 //565

class CandCHistoryCell: UITableViewCell {
    
    var buttonClicked: ((_ order : Order)->Void)?
    lazy var getdataFormmater : DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd,yyyy hh:mm a"
        return formatter
    }()
    var orderProducts:[Any]?
    var orderItems:[ShoppingBasketItem]!
    var currentOrder : Order? = nil
    var dateFormatter:DateFormatter!
    
    
    @IBOutlet weak var imgArrow: UIImageView!{
        didSet {
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                imgArrow.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
        }
    }
    @IBOutlet var mainContainerView: AWView!
    @IBOutlet var lblOrderNum: UILabel!
    @IBOutlet var lblViewDetails: UILabel!{
        didSet{
            lblViewDetails.setBody3BoldUpperButtonLabelStyle(true)
            lblViewDetails.text = localizedString("lbl_Order_Details", comment: "")
        }
    }
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var lblOrderStatus: UILabel!{
        didSet{
            lblOrderStatus.setBody3BoldUpperStyle(true)
        }
    }
    @IBOutlet var lblSelfCollection: UILabel!{
        didSet{
            lblSelfCollection.setBody3RegSecondaryDarkStyle()
            lblSelfCollection.text = localizedString("lbl_self_collection_time", comment: "")
        }
    }
    @IBOutlet var lblTime: UILabel!{
        didSet{
            lblTime.setBody3BoldUpperStyle(false)
        }
    }
    @IBOutlet var lblFrom: UILabel!{
        didSet{
            lblFrom.setBody3RegSecondaryDarkStyle()
            lblFrom.text = localizedString("from_title", comment: "")
        }
    }
    @IBOutlet var lblStoreName: UILabel!{
        didSet{
            lblStoreName.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var lblSelfCollectionPoint: UILabel!{
        didSet{
            lblSelfCollectionPoint.setBody3RegSecondaryDarkStyle()
            lblSelfCollectionPoint.text = localizedString("title_self_collection_point_cc_history_cell", comment: "")
        }
    }
    @IBOutlet var lblCollectionAddress: UILabel!{
        didSet{
            lblCollectionAddress.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var lblOrderCollectorDetails: UILabel!{
        didSet{
            lblOrderCollectorDetails.setBody3RegSecondaryDarkStyle()
            lblOrderCollectorDetails.text = localizedString("title_order_collector_details", comment: "")
        }
    }
    @IBOutlet var lblCollectorDetails: UILabel!{
        didSet{
            lblCollectorDetails.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var lblCarDetails: UILabel!{
        didSet{
            lblCarDetails.setBody3RegSecondaryDarkStyle()
            lblCarDetails.text = localizedString("title_car_details", comment: "")
        }
    }
    @IBOutlet var lblDetailsOfCar: UILabel!{
        didSet{
            lblDetailsOfCar.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var orderSummaryCollectionView: UICollectionView!
    @IBOutlet var btnEditOrder: AWButton!
    
    @IBOutlet var lblItemsCount: UILabel!{
        didSet{
            lblItemsCount.setBody3RegSecondaryDarkStyle()
        }
    }
    @IBOutlet var lblPrice: UILabel!{
        didSet{
            lblPrice.setBody3BoldUpperStyle(false)
        }
    }
 
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        registerCell()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func registerCell(){
        let orderProductCellNib = UINib(nibName: "OrderProductCell", bundle: Bundle.resource)
        self.orderSummaryCollectionView.register(orderProductCellNib, forCellWithReuseIdentifier: kOrderProductCellIdentifier)
    }
    
    func configureCandCOrder(_ order : Order) {
        self.currentOrder = order
        self.setButtonType(order)
        self.setBorderColor(order)
        self.setProductsImages()
        self.setOrderNumber()
        self.setOrderStatus()
        self.setDeliverySlot(order)
        self.setSummaryData()
        self.setStoreName()
        self.setAddressName()
        self.setCollectorDetail()
        self.setCarDetail()
    }
    
    func setDeliverySlot(_ order : Order){
        
        self.lblTime.text = order.getSlotFormattedString()
        
    }
    
    func setProgressAccordingToStatus(_ status : DynamicOrderStatus? , totalStep : Float) {
        guard status != nil else {
            return
        }
        let progress : Float = status!.stepNumber.floatValue / totalStep
        self.progressView.setProgress(progress , animated: true)
    }
    
    
    func setBorderColor(_ order : Order) {
        if order.status.intValue == OrderStatus.inSubtitution.rawValue {
            self.mainContainerView.borderColor = .elGrocerYellowColor()
            self.progressView.progressTintColor = UIColor.elGrocerYellowColor()
        }else{
            self.mainContainerView.borderColor = .newBorderGreyColor()
            self.progressView.progressTintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
        }
    }
    
    func setButtonType (_ order : Order) {
        
        if order.status.intValue == OrderStatus.payment_pending.rawValue {
            self.btnEditOrder.setTitle(localizedString("lbl_Payment_Confirmation", comment: ""), for: .normal)
        }else if order.status.intValue == OrderStatus.inSubtitution.rawValue {
            self.btnEditOrder.setTitle(localizedString("choose_substitutions_title", comment: ""), for: .normal)
        }else if order.status.intValue == OrderStatus.delivered.rawValue {
            self.btnEditOrder.setTitle(localizedString("lbl_repeat_order", comment: ""), for: .normal)
        }else {
            self.btnEditOrder.setTitle(localizedString("order_confirmation_Edit_order_button", comment: ""), for: .normal)
        }
    }
    
    
    func setProductsImages() {
        guard self.currentOrder != nil else {return }
        if self.currentOrder!.itemsPossition.count > 0 {
            self.orderProducts = self.currentOrder!.itemsPossition
        }else if self.currentOrder!.itemImages.count > 0 {
            self.orderProducts = self.currentOrder!.itemImages
        }else{
            self.orderProducts = ShoppingBasketItem.getBasketProductsForOrder(self.currentOrder!, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext ) as [Product]
            self.orderItems = ShoppingBasketItem.getBasketItemsForOrder(self.currentOrder!, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
            
        }
        self.orderSummaryCollectionView.reloadData()
    }
    
    func setCollectorDetail() {
        guard self.currentOrder != nil else {return }
        
        if let collectionDetail =  self.currentOrder?.getAttributedString(prefixText: "", SuffixBold: self.currentOrder!.collector?.name ?? "", attachedImage: nil , ", " + (self.currentOrder!.collector?.phone_number ?? "") ) {
            self.lblCollectorDetails.attributedText = collectionDetail
        }else{
            self.lblCollectorDetails.text = ""
        }
        
    }
    
    func setCarDetail() {
        guard self.currentOrder != nil else {return }
        
        var vehicleDetails =  ", " + (self.currentOrder?.vehicleDetail?.vehicleModel_name ?? "")
        vehicleDetails = vehicleDetails  + ", " +  (self.currentOrder?.vehicleDetail?.company ?? "")
        vehicleDetails = vehicleDetails  + ", " +  (self.currentOrder?.vehicleDetail?.color_name ?? "")
        
        if let carDetail =  self.currentOrder?.getAttributedString(prefixText: "" , SuffixBold: self.currentOrder?.vehicleDetail?.plate_number ?? "", attachedImage: nil , vehicleDetails  ) {
            self.lblDetailsOfCar.attributedText = carDetail
        }else{
            self.lblDetailsOfCar.text = ""
        }
    }
    
    func setStoreName() {
        self.lblStoreName.text = self.currentOrder!.grocery.name ?? ""
    }
    
    func setAddressName() {
        guard self.currentOrder != nil else {return}
        
        self.lblCollectionAddress.text = self.currentOrder?.pickUp != nil  ? self.currentOrder?.pickUp?.details :  ElGrocerUtility.sharedInstance.getFormattedAddress(self.currentOrder!.deliveryAddress)
    }
    
    func setOrderNumber() {
    
        self.lblOrderNum.text = localizedString("order_lbl_numner", comment: "") + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: self.currentOrder!.dbID.stringValue)
        let string = NSMutableAttributedString(string: self.lblOrderNum.text ?? "")
        string.setColorForText(localizedString("order_lbl_numner", comment: "") , with: .secondaryBlackColor())
        string.setColorForText(" # " , with: .secondaryBlackColor())
        string.setFontForText(localizedString("order_lbl_numner", comment: "") , with: .SFProDisplayNormalFont(14))
        string.setFontForText(" # " , with: .SFProDisplayNormalFont(14))
        string.setColorForText(String(format: "%d",self.currentOrder!.dbID.intValue) , with: UIColor.newBlackColor())
        string.setFontForText(String(format: "%d",self.currentOrder!.dbID.intValue) , with: .SFProDisplaySemiBoldFont(14))
        self.lblOrderNum.attributedText = string
        
    }
    
    func setOrderStatus() {
        if let status = self.currentOrder?.getOrderDynamicStatus() {
        let statusString : String = ElGrocerUtility.sharedInstance.isArabicSelected() ? status.nameAr : status.nameEn
        let statusUppercased = statusString.uppercased()
            self.lblOrderStatus.text = statusUppercased
        }else{
            self.lblOrderStatus.text = ""
        }
    }
    
   /* func setDeliverySlot() {
        
        guard self.currentOrder != nil else {return}
        
        
        if self.currentOrder!.deliverySlot != nil ,  self.currentOrder!.deliverySlot?.dbID != nil {
            self.lblTime.text  = self.currentOrder!.deliverySlot!.getSlotDisplayStringOnOrder(self.currentOrder!.grocery)
        }else if self.currentOrder!.deliverySlot?.startTime != nil , self.currentOrder!.deliverySlot?.endTime != nil  ,   self.currentOrder!.deliverySlot?.estimatedDeliveryDate != nil {
            let slotTimeStr =  "\(getdataFormmater.string(from: self.currentOrder!.deliverySlot!.estimatedDeliveryDate!))"
            self.lblTime.text  = slotTimeStr
        }else{
            self.lblTime.text = ""
            self.lblTime.text  =   localizedString("60_min", comment: "")
        }
    }*/
    
    
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
            if let price = self.currentOrder?.priceVariance {
                let priceDouble = Double(price) ?? 0.0
                grandTotal = grandTotal + priceDouble
            }
            if let totalProducts = self.currentOrder?.totalProducts {
                if totalProducts > 0 {
                    summaryCount = Int(totalProducts)
                }
            }
            //summary
            let countLabel = summaryCount == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")
            self.lblItemsCount.text = "(" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(summaryCount) ") + countLabel + ")"
//            self.lblPrice.text = String(format:"%@ %.2f",CurrencyManager.getCurrentCurrency() , grandTotal)
            self.lblPrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: grandTotal)
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
            if let price = self.currentOrder?.priceVariance {
                let priceDouble = Double(price) ?? 0.0
                grandTotal = grandTotal + priceDouble
            }
            if let totalProducts = self.currentOrder?.totalProducts {
                if totalProducts > 0 {
                    summaryCount = Int(totalProducts)
                }
            }
            //summary
            let countLabel = summaryCount == 1 ? localizedString("shopping_basket_items_count_singular", comment: "") : localizedString("shopping_basket_items_count_plural", comment: "")
            self.lblItemsCount.text = "(" + ElGrocerUtility.sharedInstance.setNumeralsForLanguage(numeral: "\(summaryCount) ") + countLabel + ")"
//            self.lblPrice.text = String(format:"%@ %.2f",CurrencyManager.getCurrentCurrency() ,grandTotal)
            self.lblPrice.text = ElGrocerUtility.sharedInstance.getPriceStringByLanguage(price: grandTotal)
        }
        
        
    }
    
    @IBAction func buttonAction(_ sender: Any) {
        if let clouser = self.buttonClicked {
            if let order = self.currentOrder {
                clouser(order)
            }
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

}
extension CandCHistoryCell: UICollectionViewDataSource {
    
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

extension CandCHistoryCell: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // create a cell size from the image size, and return the size
        let cellSize = CGSize(width: 95 + GlobalShadowSpace , height: 86 + GlobalShadowSpace)
        return cellSize
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 0, left: 12 , bottom: 0, right: 12)
    }
}
