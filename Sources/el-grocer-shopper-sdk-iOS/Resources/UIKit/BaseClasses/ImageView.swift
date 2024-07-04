//
//  ImageView.swift
//  iOSApp
//
//  Created by Abbas on 07/06/2021.
//

import UIKit

public class ImageView: UIImageView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }

    override init(image: UIImage?) {
        super.init(image: image)
        makeUI()
    }

    override init(image: UIImage?, highlightedImage: UIImage?) {
        super.init(image: image, highlightedImage: highlightedImage)
        makeUI()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        makeUI()
    }

    func makeUI() {
        layer.masksToBounds = true
        contentMode = .center
        translatesAutoresizingMaskIntoConstraints = false
        updateUI()
    }

    func updateUI() {
        setNeedsDisplay()
    }
}
