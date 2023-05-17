//
//  PorductBannerCell.swift
//  Pods
//
//  Created by Sarmad Abbas on 20/03/2023.
//

import UIKit

class PorductBannerCell: UICollectionViewCell {

    @IBOutlet weak var imageTapButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    var navigationHandeler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageTapButton.setTitle("", for: .normal)
        imageView.contentMode = .scaleToFill
    }
    
    @IBAction func imageDidTapped(_ sender: Any) {
        navigationHandeler?()
    }
    
}
