//
//  DeliveryView.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 25/03/2017.
//  Copyright © 2017 RST IT. All rights reserved.
//

import UIKit

protocol DeliveryViewProtocol : class {
    
    func submitFeedBackWithOrderId(_ orderId:String, withIsOrderOnTime onTime:Bool, withIsAccurateItems itemsAccurate:Bool, andWithIsSamePrice samePrice:Bool)
    func updateViewWithoutSendingFeedback()
}

class DeliveryView: UIView {

    //MARK: Outlets
    @IBOutlet var imgBlured: UIImageView!
    
    @IBOutlet var titleLabel: UILabel!
    
    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var submitButton: UIButton!
    
    var isOnTime = false
    var isItemsProperly = false
    var isBillAmount = false
    
    
    weak var delegate:DeliveryViewProtocol?
    
    var titles = [String]()
    var orderId = ""
    
    // MARK: Life cycle
    
    override func awakeFromNib() {
        
        registerTableViewCell()
        
        titles =  [localizedString("delivery_view_on_time", comment: ""),localizedString("delivery_view_items_properly", comment: ""),localizedString("delivery_view_bill_amount", comment: "")]
        
        addTapGesture()
        
        setUpLabelAppearance()
        setUpButtonAppearance()
        setUpTableViewAppearence()
    }
    
    // MARK: Appearance
    
    fileprivate func setUpLabelAppearance(){
        
        self.titleLabel.font = UIFont.bookFont(14.0)
        self.titleLabel.textColor = UIColor.black
        self.titleLabel.text = localizedString("delivery_view_help_us", comment: "")
        self.titleLabel.sizeToFit()
        self.titleLabel.numberOfLines = 0
    }
    
    fileprivate func setUpButtonAppearance(){
        self.submitButton.layer.cornerRadius = 5
        self.setSubmitButtonEnabled(false)
    }
    
    fileprivate func setSubmitButtonEnabled(_ enabled:Bool) {
        
        self.submitButton.isEnabled = enabled
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.submitButton.alpha = enabled ? 1 : 0.3
        })
    }
    
    fileprivate func setUpTableViewAppearence(){
        
        self.tableView.separatorStyle = UITableViewCell.SeparatorStyle.singleLine
        self.tableView.separatorColor = UIColor.borderGrayColor()
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.tableView.tableFooterView = UIView()
    }
    
    // MARK: TAP Gesture
    
    fileprivate func addTapGesture() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapBlured))
        self.imgBlured.addGestureRecognizer(tapGesture)
    }
    
    //MARK: Remove PopUp
    
    @objc func tapBlured() {
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.alpha = 0
            
        }, completion: { (result:Bool) -> Void in
            
            self.removeFromSuperview()
        }) 
         self.delegate?.updateViewWithoutSendingFeedback()
    }
    
    // MARK: ShowPopUp
    
    class func showDeliveryView(_ delegate:DeliveryViewProtocol?, withView topView:UIView, andWithOrderId orderId:Int) -> DeliveryView {
        
        let view = Bundle.resource.loadNibNamed("DeliveryView", owner: nil, options: nil)![0] as! DeliveryView
        view.delegate = delegate
        view.imgBlured.image = topView.createBlurredSnapShot()
        view.alpha = 0
        
        topView.addSubviewFullscreen(view)
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            view.alpha = 1
        }, completion: { (result:Bool) -> Void in
            
            view.orderId = String(orderId)
        }) 
        return view
    }
    
    //MARK: Button Actions
    
    @IBAction func closeHandler(_ sender: AnyObject) {
        
        self.tapBlured()
    }
    
    @IBAction func submitHandler(_ sender: AnyObject) {
        
        
        UIView.animate(withDuration: 0.33, animations: { () -> Void in
            
            self.alpha = 0
            
        }, completion: { (result:Bool) -> Void in
            self.removeFromSuperview()
            self.delegate?.submitFeedBackWithOrderId(self.orderId, withIsOrderOnTime: self.isOnTime, withIsAccurateItems: self.isItemsProperly, andWithIsSamePrice: self.isBillAmount)
        }) 
    }
    
    //MARK: TableView Data Source
    
    func registerTableViewCell() {
        
        let deliveryCellNib  = UINib(nibName: "DeliveryCell", bundle: Bundle.resource)
        self.tableView.register(deliveryCellNib, forCellReuseIdentifier: kDeliveryCellIdentifier)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAtIndexPath indexPath: IndexPath) -> CGFloat {
        
       return kDeliveryCellHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        
        let cell:DeliveryCell = tableView.dequeueReusableCell(withIdentifier: kDeliveryCellIdentifier, for: indexPath) as! DeliveryCell
        
        let title = titles[(indexPath as NSIndexPath).row]
        cell.configureCellWithTitle(title, andWithSelectedIndex: (indexPath as NSIndexPath).row)
        cell.delegate = self
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
        
    }
}

extension DeliveryView:DeliveryCellProtocol {
    
    func tickButtonTapped(_ buttonIndex:Int){
        
       elDebugPrint("Tick Button Tag:",buttonIndex)
        self.setSubmitButtonEnabled(true)
        let selectedIndex = buttonIndex - tickButtonOffset
        
        switch selectedIndex {
            
        case 0:
          isOnTime = true
            
        case 1:
           isItemsProperly = true
            
        case 2:
            isBillAmount = true
            
        default:
            break
        }
    }
    
    func crossButtonTapped(_ buttonIndex:Int){
        
       elDebugPrint("Cross Button Tag:",buttonIndex)
        self.setSubmitButtonEnabled(true)
        let selectedIndex = buttonIndex - crossButtonOffset
        
        switch selectedIndex {
            
        case 0:
            isOnTime = false
            
        case 1:
            isItemsProperly = false
            
        case 2:
            isBillAmount = false
            
        default:
            break
        }
    }
}
