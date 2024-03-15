//
//  RXHeadingTableViewCell.swift
//  Pods
//
//  Created by Abdul Saboor on 21/02/2024.
//

import UIKit
import RxSwift
import RxDataSources

class RXHeadingTableViewCell: RxUITableViewCell {

    
    @IBOutlet var lblHeading: UILabel! {
        didSet {
            lblHeading.setH4SemiBoldStyle()
        }
    }
    
    private var viewModel: RXHeadingTableViewCellViewModel!
    
    override func configure(viewModel: Any) {
        let viewModel = viewModel as! RXHeadingTableViewCellViewModel
        
        self.viewModel = viewModel
        self.bindViews()
        setInitialAppearance()
        
    }
    
    func setInitialAppearance() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    func bindViews() {
        viewModel.outputs.title
            .bind(to: self.lblHeading.rx.text)
            .disposed(by: disposeBag)
    }
    
    
}
