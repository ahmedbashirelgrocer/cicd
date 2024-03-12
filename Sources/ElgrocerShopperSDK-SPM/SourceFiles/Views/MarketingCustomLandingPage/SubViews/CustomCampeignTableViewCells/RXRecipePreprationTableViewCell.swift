//
//  RXRecipePreprationTableViewCell.swift
//  Pods
//
//  Created by Abdul Saboor on 20/02/2024.
//

import UIKit
import RxSwift
import RxDataSources


class RXRecipePreprationTableViewCell: RxUITableViewCell {

    @IBOutlet var lblStepNum: UILabel! {
        didSet {
            lblStepNum.setBody3RegDarkStyle()
        }
    }
    @IBOutlet var lblStepDescription: UILabel!{
        didSet {
            lblStepDescription.setBody3RegDarkStyle()
        }
    }
    
    private var viewModel: RXRecipePreprationTableViewCellViewModel!

    
    // RXSwift Custom Campeign
    
    override func configure(viewModel: Any) {
        let viewModel = viewModel as! RXRecipePreprationTableViewCellViewModel
        
        self.viewModel = viewModel
        self.bindViews()
        self.setInitialAppearance()
    }
    
    func setInitialAppearance() {
        self.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
    }
    
    func bindViews() {
        viewModel.outputs.stepNum
            .bind(to: self.lblStepNum.rx.text)
            .disposed(by: disposeBag)
        viewModel.outputs.stepDetails
            .bind(to: self.lblStepDescription.rx.text)
            .disposed(by: disposeBag)
    }
    

}
