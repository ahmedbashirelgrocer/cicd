//
//  GenericBannerCollectionViewCell.swift
//  ElGrocerShopper
//
//  Created by M Abubaker Majeed on 28/07/2020.
//  Copyright © 2020 elGrocer. All rights reserved.
//

import UIKit
import SDWebImage

let KGenericBannerCollectionViewCell = "GenericBannerCollectionViewCell"
class GenericBannerCollectionViewCell: UICollectionViewCell {

    @IBOutlet var bannerImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    override func prepareForReuse() {
        super.prepareForReuse()
        self.bannerImage.sd_cancelCurrentImageLoad()
        self.bannerImage.image = productPlaceholderPhoto
    }
    
    func setImage(_ url : String? ) {
        
       // elDebugPrint("bannerurls :  \(url)")
        
        if url != nil && url?.range(of: "http") != nil {
            
            self.bannerImage.sd_setImage(with: URL(string: url!), placeholderImage: productPlaceholderPhoto, options: SDWebImageOptions(rawValue: 2), completed: {[weak self] (image, error, cacheType, imageURL) in
                guard let self = self else {
                    return
                }
                if cacheType == SDImageCacheType.none {
                    self.bannerImage.image = image
                }
            })
        }
    }

}
