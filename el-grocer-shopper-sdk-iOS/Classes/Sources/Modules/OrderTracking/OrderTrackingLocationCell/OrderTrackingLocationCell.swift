//
//  OrderTrackingLocationCell.swift
//  ElGrocerShopper
//
//  Created by Awais Arshad Chatha on 28/03/2018.
//  Copyright © 2018 elGrocer. All rights reserved.
//

import UIKit
import GoogleMaps

let kOrderTrackingLocationCellIdentifier = "OrderTrackingLocationCell"
let kOrderTrackingLocationCellHeight: CGFloat = 180

class OrderTrackingLocationCell: UITableViewCell {

    // MARK: Outlets
    @IBOutlet weak var mapView: GMSMapView!
    
    @IBOutlet weak var locationView: UIView!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var notesView: UIView!
    @IBOutlet weak var notesImgView: UIImageView!
    @IBOutlet weak var notesLabel: UILabel!
    
    @IBOutlet weak var mapViewBottomToSuperView: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        self.setUpLocationViewAppearance()
        self.setUpNotesViewAppearance()
    }
    
    // MARK: Appearance
    
    private func setUpLocationViewAppearance() {
        
        self.locationView.layer.cornerRadius = 15
        self.locationView.layer.masksToBounds = true
        self.locationView.layer.borderColor = UIColor.darkBorderGrayColor().cgColor
        self.locationView.layer.borderWidth = 1.5
        
        self.locationLabel.font = UIFont.SFProDisplayNormalFont(14.0)
        self.locationLabel.textColor = UIColor.black
        self.locationLabel.sizeToFit()
        self.locationLabel.numberOfLines = 2
    }
    
    private func setUpNotesViewAppearance() {
        
        self.notesView.layer.cornerRadius = 5
        self.notesView.layer.masksToBounds = true
        self.notesView.layer.borderColor = UIColor.darkBorderGrayColor().cgColor
        self.notesView.layer.borderWidth = 1.5
        
        self.notesLabel.font = UIFont.SFProDisplayNormalFont(14.0)
        self.notesLabel.textColor = UIColor.black
        self.notesLabel.sizeToFit()
        self.notesLabel.numberOfLines = 2
        
        self.notesImgView.image = UIImage(name: "Notes-Icon")
        self.notesImgView.image = self.notesImgView.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        self.notesImgView.tintColor = ApplicationTheme.currentTheme.themeBasePrimaryColor
    }
    
    private func hideNotesView(_ hidden:Bool){
        
        self.notesView.isHidden = hidden
        
        self.mapViewBottomToSuperView.constant = hidden ? 0 : 30
        
       /* collectionViewTopToSearchView.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
        collectionViewTopToSegmentView.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh
        
        tableViewTopToSearchView.priority = hidden ? UILayoutPriority.defaultHigh : UILayoutPriority.defaultLow
        tableViewTopToSegmentView.priority = hidden ? UILayoutPriority.defaultLow : UILayoutPriority.defaultHigh*/
    }
    
    func configureCellWithDeliveryAddress(_ deliveyAddress: DeliveryAddress, andWithNotes orderNote:String?){
        
        //self.locationLabel.text = address.locationName
        
        self.locationLabel.text = deliveyAddress.address
        
        let locCoordinates = CLLocationCoordinate2D(latitude: deliveyAddress.latitude, longitude: deliveyAddress.longitude)
        let camera = GMSCameraPosition.camera(withTarget: locCoordinates, zoom: 17)
        self.mapView.camera = camera
        self.mapView.settings.setAllGesturesEnabled(false)
        
        let marker = GMSMarker()
        marker.position = locCoordinates
        marker.icon =  UIImage(name:"icPin")
        marker.map = mapView
        
        let downwards = GMSCameraUpdate.scrollBy(x: -35, y: 35)
        mapView.animate(with: downwards)
        
        if orderNote != nil && orderNote?.isEmpty == false {
            self.hideNotesView(false)
            self.notesLabel.text = orderNote
        }else{
            self.hideNotesView(true)
        }
    }
    
}
