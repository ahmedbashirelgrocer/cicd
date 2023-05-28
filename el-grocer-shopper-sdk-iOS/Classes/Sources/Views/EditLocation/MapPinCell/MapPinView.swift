//
//  MapPinView.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 28/05/2023.
//

import UIKit

struct UserMapPinAdress {
    
    var address : String = ""
    var addressImageUrl: URL?
    var addressLat: Double = 0.0
    var addressLng: Double = 0.0
    
}

protocol MapPinViewDelegate: AnyObject {
    func changeButtonClickedWith(_ currentDetails: UserMapPinAdress?) -> Void
}



class MapPinView: UIView {
    
    
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var addressPimImage: UIImageView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var addressChangeButton: UIButton!
    
    weak var delegate: MapPinViewDelegate?
    
    weak var mapImage : UIImage? = nil
         var currentDetails: UserMapPinAdress? = nil
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    func configureWith(detail : UserMapPinAdress) {
        
        self.currentDetails = detail
        
        if detail.addressLat == 0.0 &&  detail.addressLng == 0.0 {
            self.mapImageView.image = UIImage(name: "product_placeholder")
        }
        self.lblAddress.text = detail.address
        
        if let imageUrl = detail.addressImageUrl {
            self.mapImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(name: "product_placeholder"))
        } else {
            self.mapImageView.sd_setImage(with:  self.getPinImageFromLatLng(lat: detail.addressLat, lng: detail.addressLng), placeholderImage: UIImage(name: "product_placeholder"))
        }
        
    }
    
    @IBAction func changeButtonAction(_ sender: Any) {
        self.delegate?.changeButtonClickedWith(self.currentDetails)
    }
    

}


extension MapPinView {
    
    
    private func getPinImageFromLatLng( lat : Double , lng : Double) -> URL {
        
        let staticMapUrl: String = "http://maps.google.com/maps/api/staticmap?markers=color:blue%7C\(lat),\(lng)&center=\(lat),\(lng)&\("zoom=15&size=\(343)x\(100)")&maptype=roadmap&key=\(sdkManager.kGoogleMapsApiKey)&sensor=true"
        return NSURL(string: staticMapUrl)! as URL
    }
    
    
    
}
