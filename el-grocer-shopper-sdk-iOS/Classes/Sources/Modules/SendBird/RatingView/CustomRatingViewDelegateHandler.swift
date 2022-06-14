//
//  CustomRatingViewDelegateHandler.swift
//  ElGrocerShopper
//
//  Created by Abdul Saboor on 28/03/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit

protocol customRatingViewHandlerProtocol {
    func didUpdateRating(rating: Float)
}

class CustomRatingViewDelegateHandler: UIView {

    var rating: Float = 0.0
    var delegate: customRatingViewHandlerProtocol!

}
extension CustomRatingViewDelegateHandler: FloatRatingViewDelegate {

    func floatRatingView(_ ratingView: FloatRatingView, didUpdate rating: Float) {
        print(String(format: "%.2f", ratingView.rating))
        self.rating = rating
        self.delegate.didUpdateRating(rating: rating)
    }

    func floatRatingView(_ ratingView: FloatRatingView, isUpdating rating: Float){
        print(String(format: "%.2f", ratingView.rating))
    }
}
