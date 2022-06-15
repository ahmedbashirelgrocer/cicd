//
//  OrderCollectionDetailsCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 18/02/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import MapKit
import SDWebImage

let KOrderCollectionDetailsCell : CGFloat = 430 + 83 //-> 83 for top bottom paddings

class OrderCollectionDetailsCell: UITableViewCell , UIActivityItemSource {
    
    var currentOrder : Order?

    @IBOutlet var backGroundView: AWView!{
        didSet{
            backGroundView.layer.borderWidth = 1
            backGroundView.layer.cornerRadius = 8
            backGroundView.layer.borderColor = UIColor.newBorderGreyColor().cgColor
        }
    }
    @IBOutlet var allertBackGroundView: UIView!{
        didSet{
            allertBackGroundView.layer.cornerRadius = 8
        }
    }
    @IBOutlet var lblAlert: UILabel!
    @IBOutlet var imgAlert: UIImageView!{
        didSet{
            imgAlert.image = UIImage(named: "infoAlertIcon")
        }
    }
    @IBOutlet var imgSelfCollection: UIImageView!{
        didSet{
            imgSelfCollection.image = UIImage(named: "ClockIcon")
        }
    }
    @IBOutlet var lblSelfCollection: UILabel!
    @IBOutlet var imgCollectionLocation: UIImageView!{
        didSet{
            imgCollectionLocation.image = UIImage(named: "LocationPinIconBlack")
        }
    }
    @IBOutlet var lblCollectionLocation: UILabel!
    @IBOutlet var imgOrderPlacedBy: UIImageView!{
        didSet{
            imgOrderPlacedBy.image = UIImage(named: "ProfileIcon")
        }
    }
    @IBOutlet var lblOrderPlacedBy: UILabel!
    @IBOutlet var imgOrderCollectorDetails: UIImageView!{
        didSet{
            imgOrderCollectorDetails.image = UIImage(named: "CartCollectorProfileIcon")
        }
    }
    @IBOutlet var lblOrderCollectorDetails: UILabel!
    @IBOutlet var imgCarDetails: UIImageView!{
        didSet{
            imgCarDetails.image = UIImage(named: "CarDetailsProfileIcon")
        }
    }
    @IBOutlet var lblCarDetails: UILabel!
    @IBOutlet var btnGetDirections: AWButton!{
        didSet{
            btnGetDirections.layer.cornerRadius = 22
        }
    }
    
    @IBOutlet var lbl_CollectionDetail: UILabel! {
        
        didSet{
            lbl_CollectionDetail.text = NSLocalizedString("lbl_Self_collection_details_order_details", comment: "")
            lbl_CollectionDetail.setH3SemiBoldStyle()
        }

    }
    @IBOutlet var lblShare: UILabel! {
        didSet{
            lblShare.text = NSLocalizedString("lbl_Share", comment: "")
            lblShare.setBody1BoldStyle()
        }
    }

    @IBOutlet var mapView: UIImageView!{
        didSet{
            mapView.layer.cornerRadius = 8
        }
    }
    
    @IBOutlet var mapImagView: UIImageView!{
        didSet{
            mapImagView.layer.cornerRadius = 8

        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupInitialAppearance()
        setupFontsAndColors()
        assignAlertValue()
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    //MARK: Appearence
    func setupInitialAppearance(){
        //buttons
        self.btnGetDirections.setTitle(NSLocalizedString("btn_get_Directions", comment: ""), for: .normal)
        //labels
        self.assignAlertValue()
        self.lblSelfCollection.text = NSLocalizedString("lbl_self_collection_heading", comment: "")
        self.lblCollectionLocation.text = NSLocalizedString("title_self_collection_point", comment: "")
        self.lblOrderPlacedBy.text = NSLocalizedString("lbl_Order_Placed_by_heading", comment: "")
        self.lblOrderCollectorDetails.text = NSLocalizedString("lbl_Order_Collector_Details_heading", comment: "")
        self.lblCarDetails.text = NSLocalizedString("lbl_car_Details_heading", comment: "")
    }
    func setupFontsAndColors(){
        //Labels
        self.lblAlert.font = UIFont.SFProDisplayNormalFont(12)
        self.lblAlert.textColor = UIColor.newBlackColor()
        self.lblSelfCollection.font = UIFont.SFProDisplayNormalFont(14)
        self.lblSelfCollection.textColor = UIColor.newBlackColor()
        self.lblCollectionLocation.font = UIFont.SFProDisplayNormalFont(14)
        self.lblCollectionLocation.textColor = UIColor.newBlackColor()
        self.lblOrderPlacedBy.font = UIFont.SFProDisplayNormalFont(14)
        self.lblOrderPlacedBy.textColor = UIColor.newBlackColor()
        self.lblOrderCollectorDetails.font = UIFont.SFProDisplayNormalFont(14)
        self.lblOrderCollectorDetails.textColor = UIColor.newBlackColor()
        self.lblCarDetails.font = UIFont.SFProDisplayNormalFont(14)
        self.lblCarDetails.textColor = UIColor.newBlackColor()
        // buttons
        self.btnGetDirections.titleLabel?.font = UIFont.SFProDisplaySemiBoldFont(17).withWeight(UIFont.Weight(600))
        self.btnGetDirections.titleLabel?.textColor = UIColor.white
    }
    func assignAlertValue(){
        lblAlert.attributedText = setBoldForText(CompleteValue: NSLocalizedString("lbl_Alert_Arrive_on_time", comment: ""), textForAttribute: NSLocalizedString("lbl_Bold_Alert_Arrive_on_time", comment: ""))
    }
    //for setting multiple font in a label
    func setBoldForText(CompleteValue : String , textForAttribute: String) -> NSMutableAttributedString {
        let attributedString: NSMutableAttributedString = NSMutableAttributedString(string: CompleteValue)
        let range: NSRange = attributedString.mutableString.range(of: textForAttribute, options: .caseInsensitive)
        let attrs = [NSAttributedString.Key.font : UIFont.SFProDisplaySemiBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
        attributedString.addAttributes(attrs, range: range)
        return attributedString
    }
    
    
    
    func configureData(_ order : Order?) {
        
        self.currentOrder = order
        
        let lat : Double = order?.pickUp?.latitude?.doubleValue ?? 0.0
        let long : Double = order?.pickUp?.longitude?.doubleValue ?? 0.0
        self.setMapImage(lat, long)
      
        if let slotString = order?.getDeliveryTimeAttributedString() {
            self.lblSelfCollection.attributedText = slotString
        }else{
            self.lblSelfCollection.text = ""
        }
  
        if let locationHeading =  order?.getAttributedString(prefixText: NSLocalizedString("title_self_collection_point", comment: "") + ":\n", SuffixBold: order?.pickUp?.details ?? "", attachedImage: nil) {
            self.lblCollectionLocation.attributedText = locationHeading
        }else{
            self.lblCollectionLocation.text = ""
        }
        
        
        if let orderPlaceBy =  order?.getAttributedString(prefixText: NSLocalizedString("lbl_Order_Placed_by_heading", comment: "") + ":\n", SuffixBold: order?.shopperName ?? "", attachedImage: nil , ", " + (order?.shopperPhone ?? "")  ) {
            self.lblOrderPlacedBy.attributedText = orderPlaceBy
        }else{
            self.lblOrderPlacedBy.text = ""
        }
        
        
        if let collectionDetail =  order?.getAttributedString(prefixText: NSLocalizedString("lbl_Order_Collector_Details_heading", comment: "") + ":\n", SuffixBold: order?.collector?.name ?? "", attachedImage: nil , ", " + (order?.collector?.phone_number ?? "") ) {
            self.lblOrderCollectorDetails.attributedText = collectionDetail
        }else{
            self.lblOrderCollectorDetails.text = ""
        }
        
        
        var vehicleDetails =  ", " + (order?.vehicleDetail?.vehicleModel_name ?? "")
        vehicleDetails = vehicleDetails  + ", " +  (order?.vehicleDetail?.company ?? "")
        vehicleDetails = vehicleDetails  + ", " +  (order?.vehicleDetail?.color_name ?? "")
        
        if let carDetail =  order?.getAttributedString(prefixText: NSLocalizedString("lbl_car_Details_heading", comment: "") + ":\n", SuffixBold: order?.vehicleDetail?.plate_number ?? "", attachedImage: nil , vehicleDetails  ) {
            self.lblCarDetails.attributedText = carDetail
        }else{
            self.lblCarDetails.text = ""
        }

        self.setPickUpPointImage(order?.pickUp?.photo_url)
 
    }
    
    
    func setMapImage(_ lat : Double , _  long : Double) {
        
        guard lat > 0 , long > 0 else {return}
 
        let staticMapUrl: String = "https://maps.google.com/maps/api/staticmap?key=AIzaSyA9ItTIGrVXvJASLZXsokP9HEz-jf1PF7c&markers=color:red|\(lat),\(long)&\("zoom=15&size=\( Int(self.mapView.frame.size.width))x\( Int(self.mapView.frame.size.height))")&sensor=true&&maptype=roadmap".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
 
        self.mapView.sd_setImage(with: URL(string: staticMapUrl), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0) , completed: {[weak self] (image, error, cacheType, imageURL) in
            guard image != nil else {return}
            if cacheType == SDImageCacheType.none {
                self?.mapView.image = image
            }
        })
        
    }
    
    
    func setPickUpPointImage(_ url : String?) {
        
        guard url != nil , url?.count ?? 0 > 0 else {return}
  
        self.mapImagView.sd_setImage(with: URL(string: url ?? ""), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0) , completed: {[weak self] (image, error, cacheType, imageURL) in
            guard image != nil else {return}
            if cacheType == SDImageCacheType.none {
                self?.mapImagView.image = image
            }
        })
        
    }
    
    @IBAction func shareAction(_ sender: Any) {
        
        let orderID : String = self.currentOrder?.dbID.stringValue ?? ""
        guard !orderID.isEmpty else {
            return
        }
        let shareLint =  "https://www.elgrocer.com/order/cc-collect/\(orderID)"
        self.showActivityViewWithShareLink(link: shareLint)
    }
    
    func showActivityViewWithShareLink(link : String) -> Void {
        //let recipeTitle = "Order Pickup Details"
        let items = [self]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        if let topVc = UIApplication.topViewController() {
            topVc.present(ac, animated: true)
        }
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return "Order Pickup Details"
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivity.ActivityType?) -> Any? {
        
        
        let userProfile = UserProfile.getUserProfile(DatabaseHelper.sharedInstance.mainManagedObjectContext)
        let orderID : String = self.currentOrder?.dbID.stringValue ?? ""
        guard !orderID.isEmpty else {
            return ""
        }
        let msg = String(format: NSLocalizedString("%@s asked you to help with the grocery collection from %@s. Follow this link to see the pickup details.", comment: ""), userProfile?.name ?? "" , self.currentOrder?.grocery.name ?? "" )
        let shareLint =  "https://www.elgrocer.com/order/cc-collect/\(orderID)"
        let shareMsg = "\(msg) \(shareLint)"
        return shareMsg
 
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Order Pickup Details"
    }
    
    
    
    
    
    //https://www.google.com/maps/search/?api=1&query=47.5951518,-122.3316393&query_place_id=ChIJKxjxuaNqkFQR3CK6O1HNNqY
    @IBAction func openDirection(_ sender: Any) {
        let lat = self.currentOrder?.pickUp?.latitude?.doubleValue ?? 0
        let long = self.currentOrder?.pickUp?.longitude?.doubleValue ?? 0 
        
        guard let url = URL(string: "https://www.google.com/maps/search/?api=1&query=\(lat),\(long)") else {
            return //be safe
        }
        
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
        
        
    }
    
}


