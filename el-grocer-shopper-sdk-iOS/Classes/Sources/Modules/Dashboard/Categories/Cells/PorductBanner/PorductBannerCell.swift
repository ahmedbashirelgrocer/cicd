//
//  PorductBannerCell.swift
//  Pods
//
//  Created by Sarmad Abbas on 20/03/2023.
//

import UIKit

class PorductBannerCell: UICollectionViewCell {
    
    @IBOutlet weak var bgView: AWView!
    
    @IBOutlet weak var imageTapButton: UIButton!
    
    @IBOutlet weak var imageView: UIImageView!
    
    
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingConstraint: NSLayoutConstraint!
    
    
    var navigationHandeler: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageTapButton.setTitle("", for: .normal)
        imageView.contentMode = .scaleToFill
    }
    
    @IBAction func imageDidTapped(_ sender: Any) {
        navigationHandeler?()
    }
    // UIView Helpers
    func setImageWithBannerType(_ type: bannerType) {
        type == .thin  ? setImageWithOutPadding() : setImageWithPadding()
    }
    
    private func setImageWithOutPadding() {
        topConstraint.constant = 0
        bottomConstraint.constant = 0
        leadingConstraint.constant = 0
        trailingConstraint.constant = 0
        self.bgView.cornarRadius = 0
        self.setNeedsLayout()
    }
    private func setImageWithPadding() {
        topConstraint.constant = 8
        bottomConstraint.constant = 8
        leadingConstraint.constant = 8
        trailingConstraint.constant = 8
        self.bgView.cornarRadius = 8
        self.setNeedsLayout()
    }
    
}
