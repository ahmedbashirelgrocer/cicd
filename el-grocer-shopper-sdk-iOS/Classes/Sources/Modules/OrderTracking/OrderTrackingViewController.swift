//
//  OrderTrackingViewController.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 26/03/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit

class OrderTrackingViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let kOrderPriceCellIdentifier = "OrderPriceCell"
    
    @IBOutlet weak var timeLineTableView: UITableView!
    
    // TimelinePoint, Timeline back color, title, description
    let data:[Int: [(TimelinePoint, UIColor, String, String?)]] = [0:[
        (TimelinePoint(color: UIColor.borderGrayColor(), filled: true), UIColor.borderGrayColor(), localizedString("order_status_pending", comment: ""), localizedString("order_traking_pending_message", comment: "")),
        (TimelinePoint(color: UIColor.borderGrayColor(), filled: true), UIColor.borderGrayColor(), localizedString("order_status_accepted", comment: ""), localizedString("order_traking_accept_message", comment: "")),
                                                                    (TimelinePoint(color: UIColor.borderGrayColor(), filled: true), UIColor.borderGrayColor(), localizedString("order_status_insubtitution", comment: "").uppercased(), localizedString("order_traking_in_substitution_message", comment: "")),
        (TimelinePoint(color: UIColor.borderGrayColor(), filled: true), UIColor.borderGrayColor(), localizedString("order_status_en_route", comment: ""), localizedString("order_traking_enroute_message", comment: "")),
        (TimelinePoint(color: UIColor.borderGrayColor(), filled: true), .clear, localizedString("order_status_completed", comment: ""), "Your order has been delivered. Thanks for shopping with elGrocer.")]
    ]
    
    var isOrderInSubtitution = false
    var orderCurrentStatus = 0
    
    var order:Order!
    var orderProducts:[Product]!
    var orderItems:[ShoppingBasketItem]!
    
    var titlesArray = [String]()
    var descriptionArray = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.title = localizedString("order_tracking_title", comment: "")
        addBackButton()
        
        self.registerTableViewCell()
        self.setTableViewAppearence()
        
        self.orderProducts = ShoppingBasketItem.getBasketProductsForOrder(self.order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        self.orderItems = ShoppingBasketItem.getBasketItemsForOrder(self.order, grocery: nil, context: DatabaseHelper.sharedInstance.mainManagedObjectContext)
        
        self.setOrderDataInView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerTableViewCell() {
        
        let timelineTableViewCellNib = UINib(nibName: "TimelineTableViewCell", bundle: Bundle.resource)
        self.timeLineTableView.register(timelineTableViewCellNib, forCellReuseIdentifier: kTimelineCellIdentifier)
        
        let settingCellNib = UINib(nibName: "SettingCell", bundle: Bundle.resource)
        self.timeLineTableView.register(settingCellNib, forCellReuseIdentifier: kSettingCellIdentifier)
        
        let orderTrackingLocationCellNib = UINib(nibName: "OrderTrackingLocationCell", bundle: Bundle.resource)
        self.timeLineTableView.register(orderTrackingLocationCellNib, forCellReuseIdentifier: kOrderTrackingLocationCellIdentifier)
        
        let orderTrackingProductCellNib = UINib(nibName: "OrderTrackingProductCell", bundle: Bundle.resource)
        self.timeLineTableView.register(orderTrackingProductCellNib, forCellReuseIdentifier: kOrderTrackingProductCellIdentifier)
    }
    
    fileprivate func setTableViewAppearence(){
        
        self.timeLineTableView.backgroundColor = UIColor.lightGrayBGColor()
        
        self.timeLineTableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.timeLineTableView.separatorColor = UIColor.borderGrayColor()
        self.timeLineTableView.separatorInset = UIEdgeInsets.zero
        
        self.timeLineTableView.tableFooterView = UIView()
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
    
    func setOrderStatusWithOrder(_ order:Order) {
        
        self.isOrderInSubtitution = false
        
        switch order.status.intValue {
        case OrderStatus.pending.rawValue:
            self.orderCurrentStatus = 0
            break
            
        case OrderStatus.accepted.rawValue:
            self.orderCurrentStatus = 1
            break
        
        case OrderStatus.inSubtitution.rawValue:
            self.orderCurrentStatus = 2
            self.isOrderInSubtitution = true
            break
            
        case OrderStatus.enRoute.rawValue:
            self.orderCurrentStatus = 3
            break
            
        case OrderStatus.completed.rawValue:
            self.orderCurrentStatus = 4
            break
            
        case OrderStatus.canceled.rawValue:
            break
            
        default:
            break
        }
    }
    
    // MARK: Data
    
    func setOrderDataInView() {
        
        self.setOrderStatusWithOrder(self.order)
        
        var summaryCount = 0
        var priceSum = 0.00
        for product in self.orderProducts {
            
            let item = self.shoppingItemForProduct(product)
            if let notNilItem = item {
                
                summaryCount += notNilItem.count.intValue
                priceSum += product.price.doubleValue * notNilItem.count.doubleValue
            }
        }
        
        titlesArray.append(localizedString("total_price", comment: ""))
        descriptionArray.append(String(format:"%@ %.2f", CurrencyManager.getCurrentCurrency() ,  priceSum))
    
        let serviceFee = self.order.grocery.serviceFee
        
        titlesArray.append(localizedString("service_price", comment: ""))
        descriptionArray.append(String(format:"%@ %.2f ", CurrencyManager.getCurrentCurrency() , serviceFee))
        
        let valueAddedTaxStr = String(format:"%@ %@",localizedString("vat_title", comment: ""),"(\(self.order.grocery.vat)%)")
        
        let itemsVat = priceSum - (priceSum / ((100 + Double(truncating: self.order.grocery.vat))/100))
       elDebugPrint("Value Added Tax Value:",itemsVat)
        
        let serviceVat = serviceFee - (serviceFee / ((100 + Double(truncating: self.order.grocery.vat))/100))
       elDebugPrint("Value Added Tax Value:",serviceVat)
        
        let vatTotal = itemsVat + serviceVat
        
        titlesArray.append(valueAddedTaxStr)
        descriptionArray.append(String(format:"%@ %.2f", CurrencyManager.getCurrentCurrency() , vatTotal))
        
        // Adjust the summary if a promo code was present in an order.
        if let promoCode = order.promoCode {
            
            let promoCodeValue = promoCode.valueCents / 100.0 as Double
            
            titlesArray.append(localizedString("promotion_discount_aed", comment: ""))
            descriptionArray.append(String(format:"%@ %.2f", CurrencyManager.getCurrentCurrency() , promoCodeValue))
            
            if priceSum - promoCodeValue <= 0.0 {
                priceSum = 0.0
            } else {
                priceSum = priceSum - promoCodeValue
            }
        }
        
        let grandTotal = priceSum + serviceFee
        
        titlesArray.append(localizedString("grand_total", comment: ""))
        descriptionArray.append(String(format:"%@ %.2f", CurrencyManager.getCurrentCurrency() , grandTotal))
    }
    
    // MARK: Button Actions
    
    override func backButtonClick() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Table view data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        var headerHeight : CGFloat = 0.0
        if section != 0 {
            headerHeight = 10
        }
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            guard let sectionData = data[section] else {
                return 0
            }
            return sectionData.count
        }else if section == 1 {
            return 2
        }else if section == 2 {
            return 1
        }else{
            return self.titlesArray.count
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        var rowHeight : CGFloat = 0.0
        switch indexPath.section {
        case 0:
            if indexPath.row == orderCurrentStatus {
                rowHeight = isOrderInSubtitution ? 140 : 110
            }else{
                rowHeight = 40
            }
            break
            
        case 1:
            rowHeight = indexPath.row == 0 ? kSettingCellHeight : kOrderTrackingLocationCellHeight
            break
        
        case 2:
            rowHeight = kOrderTrackingProductCellHeight
            break
            
        case 3:
            rowHeight = 20
            break
            
        default:
            break
        }
        
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: kTimelineCellIdentifier, for: indexPath) as! TimelineTableViewCell
            
            // Configure the cell...
            guard let sectionData = data[indexPath.section] else {
                return cell
            }
            
            let (timelinePoint, timelineBackColor, title, description) = sectionData[indexPath.row]
            var timelineFrontColor = UIColor.clear
            if (indexPath.row > 0) {
                timelineFrontColor = sectionData[indexPath.row - 1].1
            }
            
            cell.timelinePoint = timelinePoint
            cell.timeline.frontColor = timelineFrontColor
            cell.timeline.backColor = timelineBackColor
            cell.titleLabel.text = title
            cell.descriptionLabel.text = description
            
            if indexPath.row == orderCurrentStatus {
                cell.backgroundColor = ApplicationTheme.currentTheme.viewPrimaryBGColor
                cell.titleLabel.textColor = UIColor.white
                cell.descriptionLabel.textColor = UIColor.white
            }else{
                cell.backgroundColor = UIColor.white
                cell.titleLabel.textColor = UIColor.lightTextGrayColor()
                cell.descriptionLabel.textColor = UIColor.lightTextGrayColor()
            }
            
            cell.reviewButton.isHidden = true
            if self.isOrderInSubtitution {
                cell.reviewButton.isHidden = false
            }
            
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
            
            return cell
            
        }else if indexPath.section == 1 {
            
            if (indexPath.row == 0){
                
                let cell:SettingCell = tableView.dequeueReusableCell(withIdentifier: kSettingCellIdentifier, for: indexPath) as! SettingCell
                
                var title = localizedString("delivery_title", comment: "")
                
                if self.order.deliverySlot != nil {
                    
                    let dayStr = (self.order.deliverySlot!.start_time?.getDayName() ?? "").capitalized
                    let slotTimeStr = self.order.deliverySlot?.getSlotFormattedString(isDeliveryMode: self.order.isDeliveryOrder()) ?? ""
                    title.append(String(format: " %@ %@", dayStr,slotTimeStr))
                    
                }else{
                    title.append(" ASAP")
                }
                
                cell.configureCellWithTitle(title, withImage: "Pending")
                cell.itemTitle.font = UIFont.SFProDisplaySemiBoldFont(15.0)
                cell.contentView.backgroundColor = UIColor.white
                return cell
                
            }else{
                
                let cell:OrderTrackingLocationCell = tableView.dequeueReusableCell(withIdentifier: kOrderTrackingLocationCellIdentifier, for: indexPath) as! OrderTrackingLocationCell
                cell.configureCellWithDeliveryAddress(self.order.deliveryAddress, andWithNotes: self.order.orderNote)
                cell.contentView.backgroundColor = UIColor.white
                return cell
            }
            
        }else if indexPath.section == 2{
            
            let cell:OrderTrackingProductCell = tableView.dequeueReusableCell(withIdentifier: kOrderTrackingProductCellIdentifier, for: indexPath) as! OrderTrackingProductCell
            cell.configureCell(self.orderProducts)
            return cell
            
        }else{
            
            let cell = tableView.dequeueReusableCell(withIdentifier: kOrderPriceCellIdentifier, for: indexPath) as! PlaceOrderTableViewCell
            
            let title = self.titlesArray[indexPath.row]
            let description = self.descriptionArray[indexPath.row]
            cell.configureWithTitle(title, withDescription: description, andWithRowIndex: indexPath.row)
            cell.backgroundColor = UIColor.white
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: tableView.bounds.width)
            return cell
        }
    }
}
