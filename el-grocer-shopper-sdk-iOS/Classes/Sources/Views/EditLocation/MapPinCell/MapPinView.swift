//
//  MapPinView.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by M Abubaker Majeed on 28/05/2023.
//

import UIKit
import SDWebImage

struct UserMapPinAdress {
    
    var nickName: String = ""
    var address : String = ""
    var addressImageUrl: URL?
    var addressLat: Double = 0.0
    var addressLng: Double = 0.0
    
}

protocol MapPinViewDelegate: AnyObject {
    func changeButtonClickedWith(_ currentDetails: UserMapPinAdress?) -> Void
    func tap(_ currentDetails: UserMapPinAdress) -> Void
}

extension MapPinViewDelegate {
    func tap(_ currentDetails: UserMapPinAdress) -> Void { }
}


class MapPinView: UIView {
    
    
    @IBOutlet weak var mapImageView: UIImageView!
    @IBOutlet weak var addressPimImage: UIImageView!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var addressChangeButton: UIButton! {
        didSet{
            addressChangeButton.setTitleColor(ApplicationTheme.currentTheme.themeBasePrimaryColor, for: UIControl.State())
            addressChangeButton.setTitle(localizedString("Change", comment: ""), for: UIControl.State())
        }
    }
    @IBOutlet weak var viewBG: AWView!
    
    weak var delegate: MapPinViewDelegate?
    
    weak var mapImage : UIImage? = nil
         var currentDetails: UserMapPinAdress? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if let viewBG = viewBG {
            viewBG.isUserInteractionEnabled = true
            viewBG.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapHandler)))
        }
    }

    func configureWith(detail : UserMapPinAdress) {
        
        self.currentDetails = detail
        
        if detail.addressLat == 0.0 &&  detail.addressLng == 0.0 {
            self.mapImageView.image = UIImage(name: "product_placeholder")
        }
        if detail.nickName.count > 0 {
            self.lblAddress.text = ""
            self.setlblAddressAttributedText(detail.nickName, address: detail.address)
        }else{
            self.lblAddress.text =  detail.address
        }
    
        if let imageUrl = detail.addressImageUrl {
            self.mapImageView.sd_setImage(with: imageUrl, placeholderImage: UIImage(name: "product_placeholder"))
        } else {
            
            self.getPinImageFromLatLng(lat: detail.addressLat, lng: detail.addressLng) { [weak self] url in
                self?.mapImageView.sd_setImage(with: url, placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0), completed: {[weak self] (image, error, cacheType, imageURL) in
                    guard let self = self else {
                        return
                    }
                    self.currentDetails?.addressImageUrl = imageURL
                    if cacheType == SDImageCacheType.none {
                        UIView.transition(with: self.mapImageView, duration: 0.33, options: UIView.AnimationOptions.transitionCrossDissolve, animations: {[weak self] () -> Void in
                            guard let self = self else {
                                return
                            }
                            self.mapImageView.image = image
                        }, completion: nil)
                    }
                })
                
                
                //self?.mapImageView.sd_setImage(with: url, placeholderImage: UIImage(name: "product_placeholder"))
            }
            
            //  self.mapImageView.sd_setImage(with:  self.getPinImageFromLatLng(lat: detail.addressLat, lng: detail.addressLng), placeholderImage: UIImage(name: "product_placeholder"))
        }
        
    }
    
    private func setlblAddressAttributedText(_ nickName: String, address: String) {
        let attrs1 = [NSAttributedString.Key.font : UIFont.SFProDisplayNormalFont(14), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
        let attrs2 = [NSAttributedString.Key.font : UIFont.SFProDisplayBoldFont(14), NSAttributedString.Key.foregroundColor : UIColor.newBlackColor()]
        let attributedString = NSMutableAttributedString(string: "" , attributes:attrs1 as [NSAttributedString.Key : Any])
        let nickName = nickName
        let attributedString1 = NSMutableAttributedString(string: nickName   , attributes:attrs2 as [NSAttributedString.Key : Any])
        attributedString.append(attributedString1)
        let attributedString2 = NSMutableAttributedString(string: "\n" + address  , attributes:attrs1 as [NSAttributedString.Key : Any])
        attributedString.append(attributedString2)
        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                self.lblAddress.attributedText = attributedString
            }
        }
    }
    
    @IBAction func changeButtonAction(_ sender: Any) {
        self.delegate?.changeButtonClickedWith(self.currentDetails)
    }
    
    @objc func tapHandler(_ sender: UITapGestureRecognizer) {
        self.delegate?.changeButtonClickedWith(self.currentDetails)
    }
}


extension MapPinView {
    
    
    private func getPinImageFromLatLng( lat : Double , lng : Double, _ completionHandler:@escaping (_ result: URL?) -> Void)  {
        
        
        ElGrocerApi.sharedInstance.getAddressImage(with: lat, lng: lng) { result in
            switch result {
            case .success(let dictionary):
                guard let data = dictionary["data"] as? String, data.count > 0 else{
                    completionHandler(nil)
                    return
                }
                completionHandler(URL.init(string: data))
                
            case .failure(_):
                completionHandler(nil)
            }
        }
        
//        let staticMapUrl: String = "http://maps.google.com/maps/api/staticmap?markers=color:blue%7C\(lat),\(lng)&center=\(lat),\(lng)&\("zoom=15&size=\(343)x\(100)")&maptype=roadmap&key=\(sdkManager.kGoogleMapsApiKey)&sensor=true"
//        return NSURL(string: staticMapUrl)! as URL
    }
    
    
    
}
