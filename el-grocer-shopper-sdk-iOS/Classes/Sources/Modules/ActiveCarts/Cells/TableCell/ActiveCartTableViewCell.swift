//
//  ActiveCartTableViewCell.swift
//  Adyen
//
//  Created by Rashid Khan on 14/11/2022.
//

import UIKit
import RxSwift
import RxCocoa

class ActiveCartTableViewCell: RxUITableViewCell {

    private var viewModel: ActiveCartCellViewModelType!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func configure(viewModel: Any) {
        guard let viewModel = viewModel as? ActiveCartCellViewModelType else { return }
        
        self.viewModel = viewModel
        self.bindViews()
    }
}

private extension ActiveCartTableViewCell {
    func bindViews() { }
}
