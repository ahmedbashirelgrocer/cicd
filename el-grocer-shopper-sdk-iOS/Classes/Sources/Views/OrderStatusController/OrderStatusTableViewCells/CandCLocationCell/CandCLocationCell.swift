//
//  CandCLocationCell.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 16/06/2021.
//  Copyright © 2021 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

// 3:4 ratio to get dynamic height
// 68 top distance of map view
// 51 lower distance from bottom
//375* 0.678 = 257.5 // 3:4 ration
let kCandCLocationCellHeight : CGFloat = 68 + 51 + (ScreenSize.SCREEN_WIDTH * 0.687) + (ScreenSize.SCREEN_WIDTH * 0.687)

class CandCLocationCell: UITableViewCell {

    @IBOutlet var btnGetDirections: AWButton!{
        didSet{
            btnGetDirections.setTitle(localizedString("btn_get_Directions", comment: ""), for: UIControl.State())
        }
    }
    @IBOutlet var collectionMap: AWImageView!
    @IBOutlet var pickUpLoactionImage: AWImageView!
    var currentOrder : Order!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
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
    
    func setPickUpImage() {
        self.setPickUpPointImage(currentOrder.pickUp?.photo_url)
    }
    
    func setMap() {
        let lat : Double = currentOrder.pickUp?.latitude?.doubleValue ?? 0.0
        let long : Double = currentOrder.pickUp?.longitude?.doubleValue ?? 0.0
        self.setMapImage(lat, long)
    }
    
    private func setMapImage(_ lat : Double , _  long : Double) {
        
        guard lat > 0 , long > 0 else {return}
        
        let staticMapUrl: String = "https://maps.google.com/maps/api/staticmap?key=AIzaSyA9ItTIGrVXvJASLZXsokP9HEz-jf1PF7c&markers=color:red|\(lat),\(long)&\("zoom=15&size=\( Int(self.collectionMap.frame.size.width))x\( Int(self.collectionMap.frame.size.height))")&sensor=true&&maptype=roadmap".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) ?? ""
        
        self.collectionMap.sd_setImage(with: URL(string: staticMapUrl), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0) , completed: {[weak self] (image, error, cacheType, imageURL) in
            guard image != nil else {return}
            if cacheType == SDImageCacheType.none {
                self?.collectionMap.image = image
            }
        })
        
    }
    
    
    private func setPickUpPointImage(_ url : String?) {
        
        guard url != nil , url?.count ?? 0 > 0 else {return}
        
        self.pickUpLoactionImage.sd_setImage(with: URL(string: url ?? ""), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 0) , completed: {[weak self] (image, error, cacheType, imageURL) in
            guard image != nil else {return}
            if cacheType == SDImageCacheType.none {
                self?.pickUpLoactionImage.image = image
            }
        })
        
    }

}
