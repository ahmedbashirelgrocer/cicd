//
//  PaymentSelectionTableViewCell.swift
//  ElGrocerShopper
//
//  Created by Rashid Khan on 02/09/2022.
//  Copyright © 2022 elGrocer. All rights reserved.
//

import UIKit
import Adyen
import RxSwift
import RxCocoa

class PaymentSelectionTableViewCell: UITableViewCell {
    static let identifier: String = "PaymentSelectionTableViewCell"
    
    @IBOutlet weak var lblTitle: UILabel! {
        didSet {
            lblTitle.setH4RegDarkStyle()
        }
    }
    @IBOutlet weak var ivIcon: UIImageView!
    @IBOutlet weak var radioButton: UIImageView!
    
    private var viewModel: PaymentSelectionCellViewModelType!
    private var disposeBag = DisposeBag()
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
//        self.viewModel.inputs.selectedObserver.onNext(self.isSelected)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.disposeBag = DisposeBag()
    }
    
    func configure(viewModel: PaymentSelectionCellViewModelType) {
        self.viewModel = viewModel
        
        viewModel.outputs.icon
            .bind(to: self.ivIcon.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.outputs.title
            .bind(to: self.lblTitle.rx.text)
            .disposed(by: disposeBag)
        
        Observable.combineLatest(viewModel.outputs.isForAddNewCard, viewModel.outputs.selected)
            .filter { $0.0 == false }
            .map { (isCard, isSelected) -> Bool in return isSelected }
            .map { $0 ? UIImage(name: "RadioButtonFilled") : UIImage(name: "RadioButtonUnfilled") }
            .bind(to: self.radioButton.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.outputs.isForAddNewCard
            .filter { $0 }
            .map { _ in UIImage(name: "arrowForward") }
            .bind(to: self.radioButton.rx.image)
            .disposed(by: disposeBag)
        
        viewModel.outputs.isArbicSelected.subscribe(onNext: { [weak self] isArbic in
            self?.radioButton.transform = isArbic ? CGAffineTransform(scaleX: -1, y: 1) : CGAffineTransform(scaleX: 1, y: 1)
        }).disposed(by: disposeBag)
    }
}
