//
//  UIImageView+Factory.swift
//  el-grocer-shopper-sdk-iOS
//
//  Created by Sarmad Abbas on 04/09/2023.
//

import Foundation
import UIKit

public extension UIFactory {
    static func makeImageView(with image: UIImage? = nil,
                              tintColor: UIColor = .black,
                              contentMode: UIView.ContentMode = .scaleAspectFit,
                              renderingMode: UIImage.RenderingMode = .alwaysOriginal) -> ImageView {
        
        let view = ImageView()
        view.tintColor = tintColor
        view.contentMode = contentMode
        view.image = image?.withRenderingMode(renderingMode)
        return view
    }
    
    static func makeImageView(with imageNamed: String,
                              in bundle: Bundle,
                              tintColor: UIColor = .black,
                              contentMode: UIView.ContentMode = .scaleAspectFit,
                              renderingMode: UIImage.RenderingMode = .alwaysOriginal) -> ImageView {
        
        makeImageView(with: UIImage(named: imageNamed, in: bundle, compatibleWith: nil),
                      tintColor: tintColor,
                      contentMode: contentMode,
                      renderingMode: renderingMode)
    }
}
