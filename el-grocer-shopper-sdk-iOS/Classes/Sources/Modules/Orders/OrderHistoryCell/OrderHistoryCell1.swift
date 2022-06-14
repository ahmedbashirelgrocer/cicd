//
//  OrderHistoryCell.swift
//  ElGrocerShopper
//
//  Created by Adam Szeremeta on 13.07.2015.
//  Copyright (c) 2015 RST IT. All rights reserved.
//

import Foundation
import UIKit

let kOrderHistoryCell1Identifier = "OrderHistoryCell1"
let kOrderHistoryCell1Height: CGFloat = 135

protocol OrderHistoryCellProtocol : class {
    
    func orderHistoryCellDidTouchDelete(_ cell:OrderHistoryCell1) -> Void
}

class OrderHistoryCell1 : UITableViewCell {
    
    @IBOutlet weak var borderContainer: UIView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var deliveryAddressName: UILabel!
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var orderStatusIcon: UIImageView!
    @IBOutlet weak var orderStatusArrow: UIImageView!
    @IBOutlet weak var orderNumberLabel: UILabel!
    @IBOutlet weak var orderDateLabel: UILabel!
    @IBOutlet weak var groceryNameLabel: UILabel!
    @IBOutlet weak var groceryAddressLabel: UILabel!
    
    @IBOutlet weak var bottomContainer: UIView!
    
    @IBOutlet weak var deleteButton: UIButton!
    let kMaxCellTranslation: CGFloat = 80
    var currentTranslation:CGFloat = 0
    var panGesture:UIPanGestureRecognizer!
    
    var dateFormatter:DateFormatter!
    
    weak var delegate:OrderHistoryCellProtocol?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "hh:mm a - dd/MM/yyyy"
        
        let phoneLanguage = UserDefaults.getCurrentLanguage()
        if phoneLanguage == "ar" {
            dateFormatter.locale = Locale(identifier: "ar")
        }
        
        setUpContainerViewAppearance()
        setUpBottomContainerViewAppearance()
        setUpDeliveryAddressNameAppearance()
        setUpOrderStatusLabelAppearance()
        setUpOrderNumberLabelAppearance()
        setUpOrderDateLabelAppearance()
        setUpGroceryNameLabelAppearance()
        setUpGroceryAddressLabelAppearance()
        setUpDeleteButtonAppearance()
        
        addPanGesture()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.currentTranslation = 0
        self.containerView.transform = CGAffineTransform.identity
    }
    
    // MARK: Appearance
    
    fileprivate func setUpBottomContainerViewAppearance() {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bottomContainer.bounds
        gradient.colors = [UIColor(red:0.91, green:0.91, blue:0.91, alpha:1.0).cgColor, UIColor.white.cgColor]
        self.bottomContainer.layer.insertSublayer(gradient, at: 0)
    }
    
    fileprivate func setUpContainerViewAppearance() {
        
        self.borderContainer.layer.cornerRadius = 10
        self.borderContainer.layer.borderColor = UIColor.darkBorderGrayColor().cgColor
        self.borderContainer.layer.borderWidth = 1
        self.borderContainer.layer.shadowOffset = CGSize(width: 1, height: 1)
        self.borderContainer.layer.shadowRadius = 2
        self.borderContainer.layer.shadowOpacity = 1
        self.borderContainer.layer.shadowColor = UIColor.borderGrayColor().cgColor
    }
    
    fileprivate func setUpDeliveryAddressNameAppearance() {
        
        self.deliveryAddressName.textColor = UIColor.black
        self.deliveryAddressName.font = UIFont.bookFont(12.0)
    }
    
    fileprivate func setUpOrderStatusLabelAppearance() {
        
        self.orderStatusLabel.textColor = UIColor.black
        self.orderStatusLabel.font = UIFont.bookFont(18.0)
    }
    
    fileprivate func setUpOrderNumberLabelAppearance() {
        
        self.orderNumberLabel.textColor = UIColor(red:0.70, green:0.70, blue:0.70, alpha:1.0)
        self.orderNumberLabel.font = UIFont.bookFont(9.0)
    }
    
    fileprivate func setUpOrderDateLabelAppearance() {
        
        self.orderDateLabel.textColor = UIColor.black
        self.orderDateLabel.font = UIFont.SFProDisplaySemiBoldFont(12.0)
    }
    
    fileprivate func setUpGroceryNameLabelAppearance() {
        
        self.groceryNameLabel.textColor = UIColor.black
        self.groceryNameLabel.font = UIFont.bookFont(12.0)
    }
    
    fileprivate func setUpGroceryAddressLabelAppearance() {
        
        self.groceryAddressLabel.textColor = UIColor.black
        self.groceryAddressLabel.font = UIFont.bookFont(13.0)
    }
    
    fileprivate func setUpDeleteButtonAppearance() {
        
        self.deleteButton.backgroundColor = UIColor.redValidationErrorColor()
        self.deleteButton.setTitleColor(UIColor.white, for: UIControl.State())
        self.deleteButton.titleLabel?.font = UIFont.boldFont(15.0)
        self.deleteButton.setTitle(NSLocalizedString("dashboard_location_delete_button", comment: ""), for: UIControl.State())
    }
    
    // MARK: Data
    
    fileprivate func loadOrderStatusLabel(_ order: Order!) -> String {
        
        if order.deliverySlot != nil && order.status.intValue == 0{
            return NSLocalizedString("order_status_schedule_order", comment: "")
        }else if order.status.intValue < OrderStatus.labels.count {
            return NSLocalizedString(OrderStatus.labels[order.status.intValue], comment: "")
        } else {
            return NSLocalizedString("order_status_unknown", comment: "")
        }
    }
    
    func configureWithOrder(_ order:Order) {
        
        self.deliveryAddressName.text = order.deliveryAddress.locationName
        self.orderStatusLabel.text = loadOrderStatusLabel(order)
        
        switch order.status.intValue {
        case OrderStatus.pending.rawValue:
            
            if order.deliverySlot != nil {
                
                self.orderStatusIcon.image = UIImage(named: "schedule-icon")
                self.orderStatusLabel.textColor = UIColor(red:0.01, green:0.51, blue:0.23, alpha:1.0)
                let image = ElGrocerUtility.sharedInstance.getImageWithName("arrow-schedule")
                self.orderStatusArrow.image = image
                
            }else{
                self.orderStatusIcon.image = UIImage(named: "Pending-icon")
                self.orderStatusLabel.textColor = UIColor(red:1.00, green:0.00, blue:0.00, alpha:1.0)
                let image = ElGrocerUtility.sharedInstance.getImageWithName("arrow-pending")
                self.orderStatusArrow.image = image
            }
            
        case OrderStatus.accepted.rawValue:
            self.orderStatusIcon.image = UIImage(named: "accpted-icon")
            self.orderStatusLabel.textColor = UIColor(red:0.52, green:0.34, blue:0.65, alpha:1.0)
            let image = ElGrocerUtility.sharedInstance.getImageWithName("arrow-accepted")
            self.orderStatusArrow.image = image
            
        case OrderStatus.enRoute.rawValue:
            self.orderStatusIcon.image = UIImage(named: "enroute-icon")
            self.orderStatusLabel.textColor = UIColor(red:0.16, green:0.67, blue:0.89, alpha:1.0)
            let image = ElGrocerUtility.sharedInstance.getImageWithName("arrow-enroute")
            self.orderStatusArrow.image = image
            
        case OrderStatus.completed.rawValue:
            self.orderStatusIcon.image = UIImage(named: "completed-icons")
            self.orderStatusLabel.textColor = UIColor(red:0.31, green:0.65, blue:0.28, alpha:1.0)
            let image = ElGrocerUtility.sharedInstance.getImageWithName("arrow-completed")
            self.orderStatusArrow.image = image
            
        case OrderStatus.canceled.rawValue:
            self.orderStatusIcon.image = UIImage(named: "cancel-icon")
            self.orderStatusLabel.textColor = UIColor.black
            let image = ElGrocerUtility.sharedInstance.getImageWithName("arrow-black")
            self.orderStatusArrow.image = image
            
        default:
            self.orderStatusIcon.image = UIImage(named: "delivered-icon")
            self.orderStatusLabel.textColor = UIColor(red:0.2, green:0.2, blue:0.2, alpha:1.0)
            let image = ElGrocerUtility.sharedInstance.getImageWithName("delivered-arrow")
            self.orderStatusArrow.image = image
        }
        
       // self.orderNumberLabel.text = "ORN: #\(order.dbID.integerValue)"
        self.orderNumberLabel.text = String(format: "%@ %d",NSLocalizedString("orn_number", comment: ""),order.dbID.intValue)
        self.orderDateLabel.text = self.dateFormatter.string(from: order.orderDate as Date)
        
        self.groceryNameLabel.text = order.grocery.name
        self.groceryAddressLabel.text = order.grocery.address
        
        //user can only delete completed orders
        self.panGesture.isEnabled = (order.status.intValue == OrderStatus.completed.rawValue)
    }
    
    // MARK: PanGesture
    
    func addPanGesture() {
        
        self.panGesture = UIPanGestureRecognizer(target: self, action: #selector(OrderHistoryCell1.handlePanGesture(_:)))
        self.panGesture.cancelsTouchesInView = true
        self.panGesture.delegate = self
        
        self.addGestureRecognizer(self.panGesture)
    }
    
    @objc func handlePanGesture(_ recognizer: UIPanGestureRecognizer) {
        
        switch recognizer.state {
            
        case .changed:
            
            let translation = recognizer.translation(in: self.borderContainer)
            var xOffset: CGFloat = self.currentTranslation + translation.x
            
            if xOffset < -kMaxCellTranslation {
                xOffset = -kMaxCellTranslation
            } else if xOffset > 0 {
                xOffset = 0
            }
            
            self.containerView.transform = CGAffineTransform(translationX: xOffset, y: 0)
            
        case .ended:
            
            let translation = recognizer.translation(in: self.borderContainer)
            var xOffset: CGFloat = self.currentTranslation + translation.x
            
            if xOffset <= -kMaxCellTranslation / 2 {
                xOffset = -kMaxCellTranslation
            } else {
                xOffset = 0
            }
            
            UIView.animate(withDuration: 0.33, animations: { () -> Void in
                
                self.containerView.transform = CGAffineTransform(translationX: xOffset, y: 0)
                self.currentTranslation = xOffset
            })
            
        default:
            break
        }
    }
    
    // MARK: Actions
    
    @IBAction func onDeleteButtonClick(_ sender: AnyObject) {
        
        self.delegate?.orderHistoryCellDidTouchDelete(self)
    }
    
    // MARK: UIGestureRecognizerDelegate
    
    override func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
    
}
