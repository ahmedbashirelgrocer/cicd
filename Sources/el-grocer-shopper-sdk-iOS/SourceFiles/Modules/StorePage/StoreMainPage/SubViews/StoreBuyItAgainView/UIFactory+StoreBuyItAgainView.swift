//
//  File.swift
//  
//
//  Created by saboor Khan on 14/05/2024.
//

import UIKit

extension UIFactory {
    
    static func makeStoreBuyItAgainView(presenter: StoreBuyItAgainViewType) -> StoreBuyItAgainView {
        let view = StoreBuyItAgainView(presenter: presenter)
        return view
    }
    
}
