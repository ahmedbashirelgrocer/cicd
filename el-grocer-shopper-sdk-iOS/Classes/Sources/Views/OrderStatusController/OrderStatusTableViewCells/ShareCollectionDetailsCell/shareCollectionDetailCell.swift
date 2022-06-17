//
//  shareCollectionDetailCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 05/07/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit

class shareCollectionDetailCell: UITableViewCell , UIActivityItemSource {
    var currentOrder : Order?
    @IBOutlet var lblSelfCollectionDetails: UILabel!{
        didSet{
            lblSelfCollectionDetails.setH3SemiBoldDarkStyle()
            lblSelfCollectionDetails.text = localizedString("lbl_Self_collection_details", comment: "")
        }
    }
    @IBOutlet var lblShare: UILabel!{
        didSet{
            lblShare.setBody1BoldStyle()
            lblShare.text = localizedString("lbl_Share", comment: "")
        }
    }
    @IBOutlet var imgShare: UIImageView! {
        didSet {
            if ElGrocerUtility.sharedInstance.isArabicSelected() {
                imgShare.transform = CGAffineTransform(scaleX: -1, y: 1)
            }
        }
    }
    @IBOutlet var btnShare: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    @IBAction func btnShareAction(_ sender: Any) {
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
        let msg = String(format: localizedString("%@s asked you to help with the grocery collection from %@s. Follow this link to see the pickup details.", comment: ""), userProfile?.name ?? "" , self.currentOrder?.grocery.name ?? "" )
        let shareLint =  "https://www.elgrocer.com/order/cc-collect/\(orderID)"
        let shareMsg = "\(msg) \(shareLint)"
        return shareMsg
        
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, subjectForActivityType activityType: UIActivity.ActivityType?) -> String {
        return "Order Pickup Details"
    }
    
    
    
}
